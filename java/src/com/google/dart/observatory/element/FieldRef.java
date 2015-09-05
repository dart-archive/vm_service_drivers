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

import com.google.gson.JsonObject;

/**
 * An [FieldRef] is a reference to a [Field].
 */
public class FieldRef extends Element {

  public FieldRef(JsonObject json) {
    super(json);
  }

  /**
   * The name of this field.
   */
  public String getName() {
    return json.get("name").getAsString();
  }

  /**
   * The owner of this field, which can be either a Library or a Class.
   */
  public ObjRef getOwner() {
    return new ObjRef((JsonObject) json.get("owner"));
  }

  /**
   * The declared type of this field. The value will always be of one of the
   * kinds: Type, TypeRef, TypeParameter, BoundedType.
   */
  public InstanceRef getDeclaredType() {
    return new InstanceRef((JsonObject) json.get("declaredType"));
  }

  /**
   * Is this field const?
   */
  public boolean getIsConst() {
    return json.get("const").getAsBoolean();
  }

  /**
   * Is this field final?
   */
  public boolean getIsFinal() {
    return json.get("final").getAsBoolean();
  }

  /**
   * Is this field static?
   */
  public boolean getIsStatic() {
    return json.get("static").getAsBoolean();
  }
}
