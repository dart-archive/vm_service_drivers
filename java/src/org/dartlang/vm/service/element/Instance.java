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
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.util.ArrayList;
import java.util.List;

/**
 * An [Instance] represents an instance of the Dart language class [Obj].
 */
public class Instance extends Element {

  public Instance(JsonObject json) {
    super(json);
  }

  /**
   * The elements of a List instance. Provided for instance kinds: Map
   */
  public List<MapAssociation> getAssociations() {
    JsonArray array = json.getAsJsonArray("associations");
    int size = array.size();
    List<MapAssociation> result = new ArrayList<MapAssociation>();
    for (int index = 0; index < size; ++index) {
      result.add(new MapAssociation((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * The bound of a TypeParameter or BoundedType. The value will always be of
   * one of the kinds: Type, TypeRef, TypeParameter, BoundedType. Provided for
   * instance kinds: BoundedType TypeParameter
   */
  public InstanceRef getBound() {
    return new InstanceRef((JsonObject) json.get("bound"));
  }

  /**
   * The bytes of a TypedData instance. Provided for instance kinds:
   * Uint8ClampedList Uint8List Uint16List Uint32List Uint64List Int8List
   * Int16List Int32List Int64List Float32List Float64List Int32x4List
   * Float32x4List Float64x2List
   */
  public List<Integer> getBytes() {
    return getListInt("bytes");
  }

  /**
   * Instance references always include their class.
   */
  public ClassRef getClassRef() {
    return new ClassRef((JsonObject) json.get("class"));
  }

  /**
   * The context associated with a Closure instance. Provided for instance
   * kinds: Closure
   */
  public FuncRef getClosureContext() {
    return new FuncRef((JsonObject) json.get("closureContext"));
  }

  /**
   * The function associated with a Closure instance. Provided for instance
   * kinds: Closure
   */
  public FuncRef getClosureFunction() {
    return new FuncRef((JsonObject) json.get("closureFunction"));
  }

  /**
   * The elements of a List instance. Provided for instance kinds: List
   * 
   * [elements] can be one of [InstanceRef] or [List<Sentinel>].
   */
  public InstanceRef getElements() {
    JsonElement elem = json.get("elements");
    if (!elem.isJsonObject()) return null;
    JsonObject child = elem.getAsJsonObject();
    String type = child.get("type").getAsString();
    if ("Sentinel".equals(type)) return null;
    return new InstanceRef(child);
  }

  /**
   * The fields of this Instance.
   */
  public BoundField getFields() {
    return new BoundField((JsonObject) json.get("fields"));
  }

  /**
   * Whether this regular expression is case sensitive. Provided for instance
   * kinds: RegExp
   */
  public boolean getIsCaseSensitive() {
    return json.get("isCaseSensitive").getAsBoolean();
  }

  /**
   * Whether this regular expression matches multiple lines. Provided for
   * instance kinds: RegExp
   */
  public boolean getIsMultiLine() {
    return json.get("isMultiLine").getAsBoolean();
  }

  /**
   * What kind of instance is this?
   */
  public InstanceKind getKind() {
    return InstanceKind.valueOf(json.get("kind").getAsString());
  }

  /**
   * The length of a List instance. Provided for instance kinds: List Map
   * Uint8ClampedList Uint8List Uint16List Uint32List Uint64List Int8List
   * Int16List Int32List Int64List Float32List Float64List Int32x4List
   * Float32x4List Float64x2List
   */
  public int getLength() {
    return json.get("length").getAsInt();
  }

  /**
   * The referent of a MirrorReference instance. Provided for instance kinds:
   * MirrorReference
   */
  public InstanceRef getMirrorReferent() {
    return new InstanceRef((JsonObject) json.get("mirrorReferent"));
  }

  /**
   * The name of a Type instance. Provided for instance kinds: Type
   */
  public String getName() {
    return json.get("name").getAsString();
  }

  /**
   * The index of a TypeParameter instance. Provided for instance kinds:
   * TypeParameter
   */
  public int getParameterIndex() {
    return json.get("parameterIndex").getAsInt();
  }

  /**
   * The parameterized class of a type parameter: Provided for instance kinds:
   * TypeParameter
   */
  public ClassRef getParameterizedClass() {
    return new ClassRef((JsonObject) json.get("parameterizedClass"));
  }

  /**
   * The pattern of a RegExp instance. Provided for instance kinds: RegExp
   */
  public String getPattern() {
    return json.get("pattern").getAsString();
  }

  /**
   * The key for a WeakProperty instance. Provided for instance kinds:
   * WeakProperty
   */
  public InstanceRef getPropertyKey() {
    return new InstanceRef((JsonObject) json.get("propertyKey"));
  }

  /**
   * The key for a WeakProperty instance. Provided for instance kinds:
   * WeakProperty
   */
  public InstanceRef getPropertyValue() {
    return new InstanceRef((JsonObject) json.get("propertyValue"));
  }

  /**
   * The type bounded by a BoundedType instance - or - the referent of a
   * TypeRef instance. The value will always be of one of the kinds: Type,
   * TypeRef, TypeParameter, BoundedType. Provided for instance kinds:
   * BoundedType TypeRef
   */
  public InstanceRef getTargetType() {
    return new InstanceRef((JsonObject) json.get("targetType"));
  }

  /**
   * The type arguments for this type. Provided for instance kinds: Type
   */
  public TypeArgumentsRef getTypeArguments() {
    return new TypeArgumentsRef((JsonObject) json.get("typeArguments"));
  }

  /**
   * The corresponding Class if this Type is canonical. Provided for instance
   * kinds: Type
   */
  public ClassRef getTypeClass() {
    return new ClassRef((JsonObject) json.get("typeClass"));
  }

  /**
   * The value of this instance as a string. Provided for the instance kinds:
   * Bool (true or false) Double (suitable for passing to Double.parse()) Int
   * (suitable for passing to int.parse()) String (value may be truncated)
   */
  public String getValueAsString() {
    return json.get("valueAsString").getAsString();
  }

  /**
   * The valueAsString for String references may be truncated. If so, this
   * property is added with the value 'true'.
   */
  public boolean getValueAsStringIsTruncated() {
    return json.get("valueAsStringIsTruncated").getAsBoolean();
  }
}
