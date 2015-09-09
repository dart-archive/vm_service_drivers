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
package com.google.dart.observatory.element;

// This is a generated file.

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.util.ArrayList;
import java.util.List;

/**
 * An [Isolate] object provides information about one isolate in the VM.
 */
public class Isolate extends Element {

  public Isolate(JsonObject json) {
    super(json);
  }

  /**
   * A list of all breakpoints for this isolate.
   */
  public List<Breakpoint> getBreakpoints() {
    JsonArray array = json.getAsJsonArray("breakpoints");
    int size = array.size();
    List<Breakpoint> result = new ArrayList<Breakpoint>();
    for (int index = 0; index < size; ++index) {
      result.add(new Breakpoint((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * The entry function for this isolate. Guaranteed to be initialized when the
   * IsolateRunnable event fires.
   */
  public FuncRef getEntry() {
    return new FuncRef((JsonObject) json.get("entry"));
  }

  /**
   * The error that is causing this isolate to exit, if applicable.
   */
  public Error getError() {
    return new Error((JsonObject) json.get("error"));
  }

  /**
   * The id which is passed to the getIsolate RPC to reload this isolate.
   */
  public String getId() {
    return json.get("id").getAsString();
  }

  /**
   * A list of all libraries for this isolate. Guaranteed to be initialized
   * when the IsolateRunnable event fires.
   */
  public List<LibraryRef> getLibraries() {
    JsonArray array = json.getAsJsonArray("libraries");
    int size = array.size();
    List<LibraryRef> result = new ArrayList<LibraryRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new LibraryRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * The number of live ports for this isolate.
   */
  public int getLivePorts() {
    return json.get("livePorts").getAsInt();
  }

  /**
   * A name identifying this isolate. Not guaranteed to be unique.
   */
  public String getName() {
    return json.get("name").getAsString();
  }

  /**
   * A numeric id for this isolate, represented as a string. Unique.
   */
  public String getNumber() {
    return json.get("number").getAsString();
  }

  /**
   * The last pause event delivered to the isolate. If the isolate is running,
   * this will be a resume event.
   */
  public Event getPauseEvent() {
    return new Event((JsonObject) json.get("pauseEvent"));
  }

  /**
   * Will this isolate pause when exiting?
   */
  public boolean getPauseOnExit() {
    return json.get("pauseOnExit").getAsBoolean();
  }

  /**
   * The root library for this isolate. Guaranteed to be initialized when the
   * IsolateRunnable event fires.
   */
  public LibraryRef getRootLib() {
    return new LibraryRef((JsonObject) json.get("rootLib"));
  }

  /**
   * The time that the VM started in milliseconds since the epoch. Suitable to
   * pass to DateTime.fromMillisecondsSinceEpoch.
   */
  public int getStartTime() {
    return json.get("startTime").getAsInt();
  }
}
