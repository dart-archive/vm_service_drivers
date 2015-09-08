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

public class Context extends Element {

  public Context(JsonObject json) {
    super(json);
  }

  /**
   * The number of variables in this context.
   */
  public int getLength() {
    return json.get("length").getAsInt();
  }

  /**
   * The enclosing context for this context.
   */
  public Context getParent() {
    return new Context((JsonObject) json.get("parent"));
  }

  /**
   * The variables in this context object.
   */
  public List<ContextElement> getVariables() {
    JsonArray array = (JsonArray) json.get("variables");
    int size = array.size();
    List<ContextElement> result = new ArrayList<ContextElement>();
    for (int index = 0; index < size; ++index) {
      result.add(new ContextElement((JsonObject) array.get(index)));
    }
    return result;
  }
}
