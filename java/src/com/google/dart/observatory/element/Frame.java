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

public class Frame extends Element {

  public Frame(JsonObject json) {
    super(json);
  }

  public CodeRef getCode() {
    return new CodeRef((JsonObject) json.get("code"));
  }

  public FuncRef getFunction() {
    return new FuncRef((JsonObject) json.get("function"));
  }

  public int getIndex() {
    return json.get("index").getAsInt();
  }

  public SourceLocation getLocation() {
    return new SourceLocation((JsonObject) json.get("location"));
  }

  public List<BoundVariable> getVars() {
    JsonArray array = (JsonArray) json.get("vars");
    int size = array.size();
    List<BoundVariable> result = new ArrayList<BoundVariable>();
    for (int index = 0; index < size; ++index) {
      result.add(new BoundVariable((JsonObject) array.get(index)));
    }
    return result;
  }
}
