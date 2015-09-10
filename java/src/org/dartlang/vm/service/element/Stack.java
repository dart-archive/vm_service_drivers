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

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.util.ArrayList;
import java.util.List;

public class Stack extends Element {

  public Stack(JsonObject json) {
    super(json);
  }

  public List<Frame> getFrames() {
    JsonArray array = json.getAsJsonArray("frames");
    int size = array.size();
    List<Frame> result = new ArrayList<Frame>();
    for (int index = 0; index < size; ++index) {
      result.add(new Frame((JsonObject) array.get(index)));
    }
    return result;
  }

  public List<Message> getMessages() {
    JsonArray array = json.getAsJsonArray("messages");
    int size = array.size();
    List<Message> result = new ArrayList<Message>();
    for (int index = 0; index < size; ++index) {
      result.add(new Message((JsonObject) array.get(index)));
    }
    return result;
  }
}
