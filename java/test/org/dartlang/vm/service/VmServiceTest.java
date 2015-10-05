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

import org.dartlang.vm.service.consumer.*;
import org.dartlang.vm.service.element.*;
import org.dartlang.vm.service.logging.Logger;
import org.dartlang.vm.service.logging.Logging;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import java.util.List;

public class VmServiceTest {
  private static File dartVm;
  private static File sampleDart;
  private static int vmPort;
  private static Process process;
  private static VmService vmService;
  private static SampleOutPrinter sampleOut;
  private static SampleOutPrinter sampleErr;
  private static SampleVmServiceListener vmListener;
  private static int actualVmServiceVersionMajor;

  public static void main(String[] args) {
    setupLogging();
    parseArgs(args);
    try {
      startSample();
      sleep(100);
      vmConnect();
      vmListener = new SampleVmServiceListener();
      vmService.addVmServiceListener(vmListener);
      vmStreamListen(VmService.DEBUG_STREAM_ID);
      vmStreamListen(VmService.ISOLATE_STREAM_ID);
      vmGetVersion();
      ElementList<IsolateRef> isolates = vmGetVmIsolates();
      Isolate sampleIsolate = vmGetIsolate(isolates.get(0));
      Library rootLib = vmGetLibrary(sampleIsolate, sampleIsolate.getRootLib());

      // Run to breakpoint on line "foo(1);"
      vmAddBreakpoint(sampleIsolate, rootLib.getScripts().get(0), 13);
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.BreakpointAdded);
      vmResume(isolates.get(0), null);
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.Resume);
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.PauseBreakpoint);
      sampleOut.assertLastLine("hello");

      // Get stack trace
      vmGetStack(sampleIsolate);

      // Step over line "foo(1);"
      vmResume(isolates.get(0), StepOption.Over);
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.Resume);
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.PauseBreakpoint);
      sampleOut.assertLastLine("val: 1");

      // Finish execution
      vmResume(isolates.get(0), null);
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.Resume);

      // VM pauses on exit and must be resumed to cleanly terminate process
      vmListener.waitFor(VmService.DEBUG_STREAM_ID, EventKind.PauseExit);
      vmResume(isolates.get(0), null);
      vmListener.waitFor(VmService.ISOLATE_STREAM_ID, EventKind.IsolateExit);
      waitForProcessExit();

      sampleOut.assertLastLine("exiting");
      sampleErr.assertLastLine(null);
      process = null;
      System.out.println("Test Complete");
    } finally {
      vmDisconnect();
      stopSample();
    }
  }

  private static int findUnusedPort() {
    try {
      ServerSocket ss = new ServerSocket(0);
      int port = ss.getLocalPort();
      ss.close();
      return port;
    } catch (IOException ioe) {
      //$FALL-THROUGH$
    }
    return -1;
  }

  private static boolean isWindows() {
    return System.getProperty("os.name").startsWith("Win");
  }

  private static void parseArgs(String[] args) {
    if (args.length != 1) {
      showErrorAndExit("Expected absolute path to Dart SDK");
    }
    File sdkDir = new File(args[0]);
    if (!sdkDir.isDirectory()) {
      showErrorAndExit("Specified directory does not exist: " + sdkDir);
    }
    File binDir = new File(sdkDir, "bin");
    dartVm = new File(binDir, isWindows() ? "dart.exe" : "dart");
    if (!dartVm.isFile()) {
      showErrorAndExit("Cannot find Dart VM in SDK: " + dartVm);
    }
    File currentDir = new File(".").getAbsoluteFile();
    File projDir = currentDir;
    String projName = "vm_service_drivers";
    while (!projDir.getName().equals(projName)) {
      projDir = projDir.getParentFile();
      if (projDir == null) {
        showErrorAndExit("Cannot find project " + projName + " from " + currentDir);
      }
    }
    sampleDart = new File(projDir, "dart/example/sample_main.dart".replace("/", File.separator));
    if (!sampleDart.isFile()) {
      showErrorAndExit("Cannot find sample: " + sampleDart);
    }
    System.out.println("Using Dart SDK: " + sdkDir);
    System.out.println("Launching sample: " + sampleDart);
  }

  private static void setupLogging() {
    Logging.setLogger(new Logger() {
      @Override
      public void logError(String message) {
        System.out.println("Log error: " + message);
      }

      @Override
      public void logError(String message, Throwable exception) {
        System.out.println("Log error: " + message);
        if (exception != null) {
          System.out.println("Log error exception: " + exception);
          exception.printStackTrace();
        }
      }

      @Override
      public void logInformation(String message) {
        System.out.println("Log info: " + message);
      }

      @Override
      public void logInformation(String message, Throwable exception) {
        System.out.println("Log info: " + message);
        if (exception != null) {
          System.out.println("Log info exception: " + exception);
          exception.printStackTrace();
        }
      }
    });
  }

  private static void showErrorAndExit(String errMsg) {
    System.out.println(errMsg);
    System.out.flush();
    sleep(10);
    System.out.println("Usage: VmServiceTest /path/to/Dart/SDK");
    System.exit(1);
  }

  private static void showRPCError(RPCError error) {
    System.out.println(">>> Received error response");
    System.out.println("  Code: " + error.getCode());
    System.out.println("  Message: " + error.getMessage());
    System.out.println("  Details: " + error.getDetails());
    System.out.println("  Request: " + error.getRequest());
  }

  private static void showSentinel(Sentinel sentinel) {
    System.out.println(">>> Received sentinel response");
    System.out.println("  Sentinel kind: " + sentinel.getKind());
    System.out.println("  Sentinel value: " + sentinel.getValueAsString());
  }

  private static void sleep(int milliseconds) {
    try {
      Thread.sleep(milliseconds);
    } catch (InterruptedException e) {
      // ignored
    }
  }

  private static void startSample() {
    // Echo Dart VM version
    List<String> processArgs = new ArrayList<>();
    processArgs.add(dartVm.getAbsolutePath());
    processArgs.add("--version");
    ProcessBuilder processBuilder = new ProcessBuilder(processArgs);
    try {
      process = processBuilder.start();
    } catch (IOException e) {
      throw new RuntimeException("Failed to launch Dart VM", e);
    }
    new SampleOutPrinter("Version", process.getInputStream());
    new SampleOutPrinter("Version", process.getErrorStream());

    vmPort = findUnusedPort();
    processArgs = new ArrayList<>();
    processArgs.add(dartVm.getAbsolutePath());
    processArgs.add("--pause_isolates_on_start");
    processArgs.add("--observe");
    processArgs.add("--enable-vm-service=" + vmPort);
    processArgs.add(sampleDart.getAbsolutePath());
    processBuilder = new ProcessBuilder(processArgs);
    try {
      process = processBuilder.start();
    } catch (IOException e) {
      throw new RuntimeException("Failed to launch Dart sample", e);
    }
    // Echo sample application output to System.out
    sampleOut = new SampleOutPrinter("Sample out", process.getInputStream());
    sampleErr = new SampleOutPrinter("Sample err", process.getErrorStream());
    System.out.println("Dart process started - port " + vmPort);
  }

  private static void stopSample() {
    if (process == null) {
      return;
    }
    final Process processToStop = process;
    process = null;
    long endTime = System.currentTimeMillis() + 5000;
    while (System.currentTimeMillis() < endTime) {
      try {
        int exit = processToStop.exitValue();
        if (exit != 0) {
          System.out.println("Sample exit code: " + exit);
        }
        return;
      } catch (IllegalThreadStateException e) {
        //$FALL-THROUGH$
      }
      try {
        Thread.sleep(20);
      } catch (InterruptedException e) {
        //$FALL-THROUGH$
      }
    }
    processToStop.destroy();
    System.out.println("Terminated sample process");
  }

  private static void vmAddBreakpoint(Isolate isolate, ScriptRef script, int lineNum) {
    final OpLatch latch = new OpLatch();
    vmService.addBreakpoint(isolate.getId(), script.getId(), lineNum, new BreakpointConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Breakpoint response) {
        System.out.println("Received Breakpoint response");
        System.out.println("  BreakpointNumber:" + response.getBreakpointNumber());
        latch.opComplete();
      }
    });
    latch.waitAndAssertOpComplete();
  }

  private static void vmConnect() {
    try {
      vmService = VmService.localConnect(vmPort);
    } catch (IOException e) {
      throw new RuntimeException("Failed to connect to the VM vmService service", e);
    }
  }

  private static void vmDisconnect() {
    if (vmService != null) {
      vmService.disconnect();
    }
  }

  private static Isolate vmGetIsolate(IsolateRef isolate) {
    final ResultLatch<Isolate> latch = new ResultLatch<Isolate>();
    vmService.getIsolate(isolate.getId(), new GetIsolateConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Isolate response) {
        System.out.println("Received Isolate response");
        System.out.println("  Id: " + response.getId());
        System.out.println("  Name: " + response.getName());
        System.out.println("  Number: " + response.getNumber());
        System.out.println("  Start Time: " + response.getStartTime());
        System.out.println("  RootLib Id: " + response.getRootLib().getId());
        System.out.println("  RootLib Uri: " + response.getRootLib().getUri());
        System.out.println("  RootLib Name: " + response.getRootLib().getName());
        System.out.println("  RootLib Json: " + response.getRootLib().getJson());
        System.out.println("  Isolate: " + response);
        latch.setValue(response);
      }

      @Override
      public void received(Sentinel response) {
        showSentinel(response);
      }
    });
    return latch.getValue();
  }

  private static Library vmGetLibrary(Isolate isolateId, LibraryRef library) {
    final ResultLatch<Library> latch = new ResultLatch<Library>();
    vmService.getLibrary(isolateId.getId(), library.getId(), new GetLibraryConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Library response) {
        System.out.println("Received GetLibrary library");
        System.out.println("  uri: " + response.getUri());
        latch.setValue(response);
      }
    });
    return latch.getValue();
  }

  private static void vmGetStack(Isolate isolate) {
    final ResultLatch<Stack> latch = new ResultLatch<Stack>();
    vmService.getStack(isolate.getId(), new StackConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Stack stack) {
        latch.setValue(stack);
      }
    });
    Stack stack = latch.getValue();
    System.out.println("Received Stack response");
    System.out.println("  Messages:");
    for (Message message : stack.getMessages()) {
      System.out.println("    " + message.getName());
    }
    System.out.println("  Frames:");
    InstanceRefToString convert = new InstanceRefToString(isolate, vmService, latch);
    for (Frame frame : stack.getFrames()) {
      System.out.println("    #" + frame.getIndex() + " " + frame.getFunction().getName() + " ("
          + frame.getLocation().getScript().getUri() + ")");
      for (BoundVariable var : frame.getVars()) {
        InstanceRef instanceRef = var.getValue();
        System.out.println("      " + var.getName() + " = " + convert.toString(instanceRef));
      }
    }
  }

  private static void vmGetVersion() {
    final OpLatch latch = new OpLatch();
    vmService.getVersion(new VersionConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Version response) {
        System.out.println("Received Version response");
        actualVmServiceVersionMajor = response.getMajor();
        System.out.println("  Major: " + actualVmServiceVersionMajor);
        System.out.println("  Minor: " + response.getMinor());
        System.out.println(response.getJson());
        latch.opComplete();
      }
    });
    latch.waitAndAssertOpComplete();
  }

  private static ElementList<IsolateRef> vmGetVmIsolates() {
    final ResultLatch<ElementList<IsolateRef>> latch = new ResultLatch<ElementList<IsolateRef>>();
    vmService.getVM(new VMConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(VM response) {
        System.out.println("Received VM response");
        System.out.println("  ArchitectureBits: " + response.getArchitectureBits());
        System.out.println("  HostCPU: " + response.getHostCPU());
        System.out.println("  TargetCPU: " + response.getTargetCPU());
        System.out.println("  Pid: " + response.getPid());
        System.out.println("  StartTime: " + response.getStartTime());
        for (IsolateRef isolate : response.getIsolates()) {
          System.out.println("  Isolate " + isolate.getNumber() + ", " + isolate.getId() + ", "
              + isolate.getName());
        }
        latch.setValue(response.getIsolates());
      }
    });
    return latch.getValue();
  }

  private static void vmResume(IsolateRef isolateRef, final StepOption step) {
    final String id = isolateRef.getId();
    vmService.resume(id, step, new SuccessConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Success response) {
        if (step == null) {
          System.out.println("Resumed isolate " + id);
        } else {
          System.out.println("Step " + step + " isolate " + id);
        }
      }
    });
    // Do not wait for confirmation, but display error if it occurs
  }

  private static void vmStreamListen(String streamId) {
    final OpLatch latch = new OpLatch();
    vmService.streamListen(streamId, new SuccessConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Success response) {
        System.out.println("Subscribed to debug event stream");
        latch.opComplete();
      }
    });
    latch.waitAndAssertOpComplete();
  }

  private static void waitForProcessExit() {
    if (actualVmServiceVersionMajor == 2) {
      // Don't wait for VM 1.12 - protocol 2.1
      return;
    }
    long end = System.currentTimeMillis() + 5000;
    while (true) {
      try {
        System.out.println("Exit code: " + process.exitValue());
        return;
      } catch (IllegalThreadStateException e) {
        // fall through to wait for exit
      }
      if (System.currentTimeMillis() >= end) {
        throw new RuntimeException("Expected child process to finish");
      }
      sleep(10);
    }
  }
}
