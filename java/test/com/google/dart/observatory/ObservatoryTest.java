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
package com.google.dart.observatory;

import com.google.dart.observatory.consumer.IsolateConsumer;
import com.google.dart.observatory.consumer.SuccessConsumer;
import com.google.dart.observatory.consumer.VMConsumer;
import com.google.dart.observatory.consumer.VersionConsumer;
import com.google.dart.observatory.element.Isolate;
import com.google.dart.observatory.element.IsolateRef;
import com.google.dart.observatory.element.RPCError;
import com.google.dart.observatory.element.StepOption;
import com.google.dart.observatory.element.Success;
import com.google.dart.observatory.element.VM;
import com.google.dart.observatory.element.Version;
import com.google.dart.observatory.logging.Logger;
import com.google.dart.observatory.logging.Logging;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class ObservatoryTest {

  private static File dartVm;
  private static File sampleDart;
  private static int vmPort;
  private static Process process;
  private static Observatory observatory;
  private static List<IsolateRef> isolates;
  private static SampleOutPrinter sampleOut;
  private static SampleOutPrinter sampleErr;
  private static Isolate sampleIsolate;

  public static void main(String[] args) {
    setupLogging();
    parseArgs(args);
    try {
      startSample();
      sleep(500);
      vmConnect();
      vmGetVersion();
      vmGetIsolates();
      vmGetSampleIsolate(isolates.get(0).getId());

      // Run to breakpoint
      vmAddBreakpoint(isolates.get(0), 8);
//      vmResume(isolates.get(0), null);
//      sampleOut.waitFor("hello");
//      sleep(200);
//      sampleOut.assertLastLine("hello");

      // Step over one line
//      vmResume(isolates.get(0), StepOption.Over);
//      sampleOut.waitFor("val: 1");
//      sleep(200);
//      sampleOut.assertLastLine("val: 1");

      // Finish execution
      vmResume(isolates.get(0), null);
      sampleOut.waitFor("exiting");
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

  private static void parseArgs(String[] args) {
    if (args.length != 1) {
      showErrorAndExit("Expected absolute path to Dart SDK");
    }
    File sdkDir = new File(args[0]);
    if (!sdkDir.isDirectory()) {
      showErrorAndExit("Specified directory does not exist: " + sdkDir);
    }
    File binDir = new File(sdkDir, "bin");
    dartVm = new File(binDir, "dart");
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
    System.out.println("Usage: ObservatoryTest /path/to/Dart/SDK");
    System.exit(1);
  }

  private static void showRPCError(RPCError error) {
    System.out.println(">>> Received error response");
    System.out.println("  Code: " + error.getCode());
    System.out.println("  Message: " + error.getMessage());
    System.out.println("  Details: " + error.getDetails());
    System.out.println("  Request: " + error.getRequest());
  }

  private static void sleep(int milliseconds) {
    try {
      Thread.sleep(milliseconds);
    } catch (InterruptedException e) {
      // ignored
    }
  }

  private static void startSample() {
    vmPort = findUnusedPort();
    List<String> processArgs = new ArrayList<String>();
    processArgs.add(dartVm.getAbsolutePath());
    processArgs.add("--pause_isolates_on_start");
    processArgs.add("--observe");
    processArgs.add("--enable-vm-service=" + vmPort);
    processArgs.add(sampleDart.getAbsolutePath());
    ProcessBuilder processBuilder = new ProcessBuilder(processArgs);
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

  private static void vmAddBreakpoint(IsolateRef isolateRef, int lineNum) {
//    final CountDownLatch latch = new CountDownLatch(1);
//    observatory.addBreakpoint(isolateRef.getId(), "sample_main.dart$main", lineNum,
//        new BreakpointConsumer() {
//          @Override
//          public void onError(RPCError error) {
//            showRPCError(error);
//          }
//
//          @Override
//          public void received(Breakpoint response) {
//            System.out.println("Received Breakpoint response");
//            System.out.println("  BreakpointNumber:" + response.getBreakpointNumber());
//            latch.countDown();
//          }
//        });
//    waitFor(latch);
  }

  private static void vmConnect() {
    try {
      observatory = Observatory.localConnect(vmPort);
    } catch (IOException e) {
      throw new RuntimeException("Failed to connect to the VM observatory service", e);
    }
  }

  private static void vmDisconnect() {
    if (observatory != null) {
      observatory.disconnect();
    }
  }

  private static void vmGetIsolates() {
    final CountDownLatch latch = new CountDownLatch(1);
    observatory.getVM(new VMConsumer() {
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
        isolates = response.getIsolates();
        for (IsolateRef isolate : isolates) {
          System.out.println("  Isolate " + isolate.getNumber() + ", " + isolate.getId() + ", "
              + isolate.getName());
        }
        latch.countDown();
      }
    });
    waitFor(latch);
  }

  private static void vmGetSampleIsolate(String id) {
    final CountDownLatch latch = new CountDownLatch(1);
    observatory.getIsolate(id, new IsolateConsumer() {
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
        System.out.println("  RootLib Id: " + response.getRootLib().getId());
        System.out.println("  RootLib Uri: " + response.getRootLib().getUri());
        System.out.println("  RootLib Name: " + response.getRootLib().getName());
        System.out.println("  RootLib Json: " + response.getRootLib().getJson());
        sampleIsolate = response;
        System.out.println("  Isolate: " + sampleIsolate);
        latch.countDown();
      }
    });
    waitFor(latch);
  }

  private static void vmGetVersion() {
    final CountDownLatch latch = new CountDownLatch(1);
    observatory.getVersion(new VersionConsumer() {
      @Override
      public void onError(RPCError error) {
        showRPCError(error);
      }

      @Override
      public void received(Version response) {
        System.out.println("Received Version response");
        System.out.println("  Major: " + response.getMajor());
        System.out.println("  Minor: " + response.getMinor());
        System.out.println(response.getJson());
        latch.countDown();
      }
    });
    waitFor(latch);
  }

  private static void vmResume(IsolateRef isolateRef, final StepOption step) {
    final String id = isolateRef.getId();
    observatory.resume(id, step, new SuccessConsumer() {
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
  }

  private static void waitFor(final CountDownLatch latch) {
    try {
      if (!latch.await(5, TimeUnit.SECONDS)) {
        System.out.println(">>> No response received");
        throw new RuntimeException("No response received");
      }
    } catch (InterruptedException e) {
      System.out.println(">>> Interrupted while waiting for response");
      throw new RuntimeException("Interrupted while waiting for response", e);
    }
  }
}
