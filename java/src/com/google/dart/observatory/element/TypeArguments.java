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
 * A [TypeArguments] object represents the type argument vector for some
 * instantiated generic type.
 */
public class TypeArguments extends Element {

  public TypeArguments(JsonObject json) {
    super(json);
  }

  /**
   * A name for this type argument list.
   */
  public String getName() {
    return json.get("name").getAsString();
  }

  /**
   * A list of types. The value will always be one of the kinds: Type, TypeRef,
   * TypeParameter, BoundedType.
   */
  public List<InstanceRef> getTypes() {
    JsonArray array = (JsonArray) json.get("types");
    int size = array.size();
    List<InstanceRef> result = new ArrayList<InstanceRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new InstanceRef((JsonObject) array.get(index)));
    }
    return result;
  }
}
