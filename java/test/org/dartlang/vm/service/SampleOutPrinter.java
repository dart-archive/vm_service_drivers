package org.dartlang.vm.service;

import com.google.common.base.Charsets;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * Echo the content of a stream to {@link System.out} with the given prefix.
 */
public class SampleOutPrinter {
  private class LinesReaderThread extends Thread {
    public LinesReaderThread() {
      setName("SampleOutPrinter.LinesReaderThread - " + prefix);
      setDaemon(true);
    }

    @Override
    public void run() {
      while (true) {
        String line;
        try {
          line = reader.readLine();
        } catch (IOException e) {
          System.out.println("Exception reading sample stream");
          e.printStackTrace();
          return;
        }
        // check for EOF
        if (line == null) {
          return;
        }
        synchronized (currentLineLock) {
          currentLine = line;
          currentLineLock.notifyAll();
        }
        System.out.println(prefix + ": " + line);
      }
    }
  }

  private String currentLine;

  private final Object currentLineLock = new Object();

  private final String prefix;
  private final BufferedReader reader;

  public SampleOutPrinter(String prefix, InputStream stream) {
    this.prefix = prefix;
    this.reader = new BufferedReader(new InputStreamReader(stream, Charsets.UTF_8));
    new LinesReaderThread().start();
  }

  public void assertEmpty() {
    synchronized (currentLineLock) {
      if (currentLine != null) {
        throw new RuntimeException("Did not expect " + prefix + " output");
      }
    }
  }

  public void assertLastLine(String text) {
    synchronized (currentLineLock) {
      if (text == null) {
        if (currentLine != null) {
          throw new RuntimeException("Did not expect " + prefix + " output");
        }
      } else {
        if (currentLine == null || !currentLine.contains(text)) {
          throw new RuntimeException("Expected current line to contain: " + text);
        }
      }
    }
  }

  /**
   * Wait for output from the sample program that contains the given text.
   */
  public void waitFor(String text) {
    long start = System.currentTimeMillis();
    synchronized (currentLineLock) {
      while (System.currentTimeMillis() - start < 5000) {
        if (currentLine != null && currentLine.contains(text)) {
          return;
        }
        try {
          currentLineLock.wait(5000);
        } catch (InterruptedException e) {
          // ignored
        }
      }
    }
    throw new RuntimeException("Expected output: " + text);
  }
}
