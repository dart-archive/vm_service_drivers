/*
 * Copyright (c) 2015, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package org.dartlang.vm.service;

import com.google.common.collect.Maps;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;

import de.roderick.weberknecht.WebSocket;
import de.roderick.weberknecht.WebSocketEventHandler;
import de.roderick.weberknecht.WebSocketException;
import de.roderick.weberknecht.WebSocketMessage;

import org.dartlang.vm.service.consumer.BreakpointConsumer;
import org.dartlang.vm.service.consumer.Consumer;
import org.dartlang.vm.service.consumer.GetInstanceConsumer;
import org.dartlang.vm.service.consumer.GetLibraryConsumer;
import org.dartlang.vm.service.consumer.GetObjectConsumer;
import org.dartlang.vm.service.consumer.VersionConsumer;
import org.dartlang.vm.service.element.Instance;
import org.dartlang.vm.service.element.Library;
import org.dartlang.vm.service.element.Obj;
import org.dartlang.vm.service.element.RPCError;
import org.dartlang.vm.service.element.Sentinel;
import org.dartlang.vm.service.element.Version;
import org.dartlang.vm.service.internal.RequestSink;
import org.dartlang.vm.service.internal.VmServiceConst;
import org.dartlang.vm.service.internal.WebSocketRequestSink;
import org.dartlang.vm.service.logging.Logging;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Internal {@link VmService} base class containing non-generated code.
 */
abstract class VmServiceBase implements VmServiceConst {

  /**
   * Connect to the VM observatory service via the specified URI
   * 
   * @return an API object for interacting with the VM service (not {@code null}).
   */
  public static VmService connect(final String url) throws IOException {

    // Validate URL
    URI uri;
    try {
      uri = new URI(url);
    } catch (URISyntaxException e) {
      throw new IOException("Invalid URL: " + url, e);
    }
    String wsScheme = uri.getScheme();
    if (!"ws".equals(wsScheme) && !"wss".equals(wsScheme)) {
      throw new IOException("Unsupported URL scheme: " + wsScheme);
    }

    // Create web socket and observatory
    WebSocket webSocket;
    try {
      webSocket = new WebSocket(uri);
    } catch (WebSocketException e) {
      throw new IOException("Failed to create websocket: " + url, e);
    }
    final VmService vmService = new VmService();

    // Setup event handler for forwarding responses
    webSocket.setEventHandler(new WebSocketEventHandler() {
      @Override
      public void onClose() {
        Logging.getLogger().logInformation("VM connection closed: " + url);
      }

      @Override
      public void onMessage(WebSocketMessage message) {
        Logging.getLogger().logInformation("VM message: " + message.getText());
        vmService.processResponse(message.getText());
      }

      @Override
      public void onOpen() {
        Logging.getLogger().logInformation("VM connection open: " + url);
      }

      @Override
      public void onPing() {
      }

      @Override
      public void onPong() {
      }
    });

    // Establish WebSocket Connection
    try {
      webSocket.connect();
    } catch (WebSocketException e) {
      throw new IOException("Failed to connect: " + url, e);
    }
    vmService.requestSink = new WebSocketRequestSink(webSocket);

    // Check protocol version
    final CountDownLatch latch = new CountDownLatch(1);
    final String[] errMsg = new String[1];
    vmService.getVersion(new VersionConsumer() {
      @Override
      public void onError(RPCError error) {
        String msg = "Failed to determine protocol version: " + error.getCode() + "\n  message: "
            + error.getMessage() + "\n  details: " + error.getDetails();
        Logging.getLogger().logInformation(msg);
        errMsg[0] = msg;
      }

      @Override
      public void received(Version response) {
        int major = response.getMajor();
        int minor = response.getMinor();
        if (major != VmService.versionMajor || minor != VmService.versionMinor) {
          if (major == 2 || major == 3) {
            Logging.getLogger().logInformation(
                "Difference in protocol version: client=" + VmService.versionMajor + "."
                    + VmService.versionMinor + " vm=" + major + "." + minor);
          } else {
            String msg = "Incompatible protocol version: client=" + VmService.versionMajor + "."
                + VmService.versionMinor + " vm=" + major + "." + minor;
            Logging.getLogger().logError(msg);
            errMsg[0] = msg;
          }
        }
        latch.countDown();
      }
    });
    try {
      if (!latch.await(5, TimeUnit.SECONDS)) {
        throw new IOException("Failed to determine protocol version");
      }
      if (errMsg[0] != null) {
        throw new IOException(errMsg[0]);
      }
    } catch (InterruptedException e) {
      throw new RuntimeException("Interrupted while waiting for response", e);
    }

    return vmService;
  }

  /**
   * Connect to the VM observatory service on the given local port.
   * 
   * @return an API object for interacting with the VM service (not {@code null}).
   */
  public static VmService localConnect(int port) throws IOException {
    return connect("ws://localhost:" + port + "/ws");
  }

  /**
   * A mapping between {@link String} ids' and the associated {@link Consumer} that was passed when
   * the request was made. Synchronize against {@link #consumerMapLock} before accessing this field.
   */
  private final Map<String, Consumer> consumerMap = Maps.newHashMap();

  /**
   * The object used to synchronize access to {@link #consumerMap}.
   */
  private final Object consumerMapLock = new Object();

  /**
   * The unique ID for the next request.
   */
  private final AtomicInteger nextId = new AtomicInteger();

  /**
   * The channel through which observatory requests are made.
   */
  RequestSink requestSink;

  /**
   * The [addBreakpoint] RPC is used to add a breakpoint at a specific line of some script. This
   * call works for protocol versions 2.1 and 3.0
   */
  public void addBreakpoint(String isolateId, String scriptId, int line, BreakpointConsumer consumer) {
    JsonObject params = new JsonObject();
    params.addProperty("isolateId", isolateId);
    params.addProperty("scriptId", scriptId);
    params.addProperty("line", line);
    request("addBreakpoint", params, consumer);
  }

  /**
   * Disconnect from the VM observatory service.
   */
  public void disconnect() {
    requestSink.close();
  }

  /**
   * Return the instance with the given identifier.
   */
  public void getInstance(String isolateId, String instanceId, final GetInstanceConsumer consumer) {
    getObject(isolateId, instanceId, new GetObjectConsumer() {

      @Override
      public void onError(RPCError error) {
        consumer.onError(error);
      }

      @Override
      public void received(Obj response) {
        if (response instanceof Instance) {
          consumer.received((Instance) response);
        } else {
          onError(RPCError.unexpected("Instance", response));
        }
      }

      @Override
      public void received(Sentinel response) {
        onError(RPCError.unexpected("Instance", response));
      }
    });
  }

  /**
   * Return the library with the given identifier.
   */
  public void getLibrary(String isolateId, String libraryId, final GetLibraryConsumer consumer) {
    getObject(isolateId, libraryId, new GetObjectConsumer() {

      @Override
      public void onError(RPCError error) {
        consumer.onError(error);
      }

      @Override
      public void received(Obj response) {
        if (response instanceof Library) {
          consumer.received((Library) response);
        } else {
          onError(RPCError.unexpected("Library", response));
        }
      }

      @Override
      public void received(Sentinel response) {
        onError(RPCError.unexpected("Library", response));
      }
    });
  }

  public abstract void getObject(String isolateId, String objectId, GetObjectConsumer consumer);

  /**
   * Sends the request and associates the request with the passed {@link Consumer}.
   */
  protected void request(String method, JsonObject params, Consumer consumer) {

    // Assemble the request
    String id = Integer.toString(nextId.incrementAndGet());
    JsonObject request = new JsonObject();
    request.addProperty(ID, id);
    request.addProperty(METHOD, method);
    request.add(PARAMS, params);

    // Cache the consumer to receive the response
    synchronized (consumerMapLock) {
      consumerMap.put(id, consumer);
    }

    // Send the request
    requestSink.add(request);
  }

  abstract void forwardResponse(Consumer consumer, String type, JsonObject json);

  void logUnknownResponse(Consumer consumer, JsonObject json) {
    Class<? extends Consumer> consumerClass = consumer.getClass();
    StringBuilder msg = new StringBuilder();
    msg.append("Expected response for " + consumerClass + "\n");
    for (Class<?> interf : consumerClass.getInterfaces()) {
      msg.append("  implementing " + interf + "\n");
    }
    msg.append("  but received " + json);
    Logging.getLogger().logError(msg.toString());
  }

  /**
   * Process the response from the VM service and forward that response to the consumer associated
   * with the response id.
   */
  void processResponse(String jsonText) {

    // Decode the JSON
    JsonObject json;
    try {
      json = (JsonObject) new JsonParser().parse(jsonText);
    } catch (JsonSyntaxException e) {
      Logging.getLogger().logError("Parse response failed", e);
      return;
    }

    // Get the consumer associated with this response
    String id;
    try {
      id = json.get(ID).getAsString();
    } catch (Exception e) {
      Logging.getLogger().logError("Response missing " + ID, e);
      return;
    }
    Consumer consumer = consumerMap.remove(id);
    if (consumer == null) {
      Logging.getLogger().logError("No consumer associated with " + ID + ": " + id);
      return;
    }

    // Forward the response if the request was successfully executed
    JsonElement elem = json.get(RESULT);
    if (elem != null) {
      JsonObject result;
      try {
        result = elem.getAsJsonObject();
      } catch (Exception e) {
        Logging.getLogger().logError("Response has invalid " + RESULT, e);
        return;
      }
      String responseType;
      try {
        responseType = result.get(TYPE).getAsString();
      } catch (Exception e) {
        Logging.getLogger().logError("Response missing " + TYPE, e);
        return;
      }
      forwardResponse(consumer, responseType, result);
      return;
    }

    // Forward an error if the request failed
    elem = json.get(ERROR);
    if (elem != null) {
      JsonObject error;
      try {
        error = elem.getAsJsonObject();
      } catch (Exception e) {
        Logging.getLogger().logError("Response has invalid " + RESULT, e);
        return;
      }
      consumer.onError(new RPCError(error));
      Logging.getLogger().logError("Error Response: " + error);
      return;
    }

    Logging.getLogger().logError("Response missing " + RESULT + " and " + ERROR);
  }
}
