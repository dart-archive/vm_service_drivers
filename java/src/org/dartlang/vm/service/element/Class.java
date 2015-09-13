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

/**
 * A [Class] provides information about a Dart language class.
 */
public class Class extends Element {

  public Class(JsonObject json) {
    super(json);
  }

  /**
   * The error which occurred during class finalization, if it exists.
   */
  public ErrorRef getError() {
    return new ErrorRef((JsonObject) json.get("error"));
  }

  /**
   * A list of fields in this class. Does not include fields from superclasses.
   */
  public List<FieldRef> getFields() {
    JsonArray array = json.getAsJsonArray("fields");
    int size = array.size();
    List<FieldRef> result = new ArrayList<FieldRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new FieldRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * A list of functions in this class. Does not include functions from superclasses.
   */
  public List<FuncRef> getFunctions() {
    JsonArray array = json.getAsJsonArray("functions");
    int size = array.size();
    List<FuncRef> result = new ArrayList<FuncRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new FuncRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * A list of interface types for this class. The value will be of the kind: Type.
   */
  public List<InstanceRef> getInterfaces() {
    JsonArray array = json.getAsJsonArray("interfaces");
    int size = array.size();
    List<InstanceRef> result = new ArrayList<InstanceRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new InstanceRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * Is this an abstract class?
   */
  public boolean getIsAbstract() {
    return json.get("abstract").getAsBoolean();
  }

  /**
   * Is this a const class?
   */
  public boolean getIsConst() {
    return json.get("const").getAsBoolean();
  }

  /**
   * The library which contains this class.
   */
  public LibraryRef getLibrary() {
    return new LibraryRef((JsonObject) json.get("library"));
  }

  /**
   * The location of this class in the source code.
   */
  public SourceLocation getLocation() {
    return new SourceLocation((JsonObject) json.get("location"));
  }

  /**
   * The name of this class.
   */
  public String getName() {
    return json.get("name").getAsString();
  }

  /**
   * A list of subclasses of this class.
   */
  public List<ClassRef> getSubclasses() {
    JsonArray array = json.getAsJsonArray("subclasses");
    int size = array.size();
    List<ClassRef> result = new ArrayList<ClassRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new ClassRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * The superclass of this class, if any.
   */
  public ClassRef getSuperClass() {
    return new ClassRef((JsonObject) json.get("super"));
  }
}
