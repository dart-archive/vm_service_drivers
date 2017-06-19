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
package org.dartlang.vm.service.element;

// This is a generated file.

import com.google.gson.JsonObject;

@SuppressWarnings({"WeakerAccess", "unused", "UnnecessaryInterfaceModifier"})
public class CpuProfile extends Response {

  public CpuProfile(JsonObject json) {
    super(json);
  }

  public int getSampleCount() {
    return json.get("sampleCount") == null ? -1 : json.get("sampleCount").getAsInt();
  }

  public int getSamplePeriod() {
    return json.get("samplePeriod") == null ? -1 : json.get("samplePeriod").getAsInt();
  }

  public int getStackDepth() {
    return json.get("stackDepth") == null ? -1 : json.get("stackDepth").getAsInt();
  }

  public int getTimeExtentMicros() {
    return json.get("timeExtentMicros") == null ? -1 : json.get("timeExtentMicros").getAsInt();
  }

  public int getTimeOriginMicros() {
    return json.get("timeOriginMicros") == null ? -1 : json.get("timeOriginMicros").getAsInt();
  }

  public double getTimeSpan() {
    return json.get("timeSpan") == null ? 0.0 : json.get("timeSpan").getAsDouble();
  }
}
