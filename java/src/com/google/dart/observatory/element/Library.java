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
 * A [Library] provides information about a Dart language library.
 */
public class Library extends Element {

  public Library(JsonObject json) {
    super(json);
  }

  /**
   * A list of all classes in this library.
   */
  public List<ClassRef> getClasses() {
    JsonArray array = (JsonArray) json.get("classes");
    int size = array.size();
    List<ClassRef> result = new ArrayList<ClassRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new ClassRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * Is this library debuggable? Default true.
   */
  public boolean getDebuggable() {
    return json.get("debuggable").getAsBoolean();
  }

  /**
   * A list of the imports for this library.
   */
  public List<LibraryDependency> getDependencies() {
    JsonArray array = (JsonArray) json.get("dependencies");
    int size = array.size();
    List<LibraryDependency> result = new ArrayList<LibraryDependency>();
    for (int index = 0; index < size; ++index) {
      result.add(new LibraryDependency((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * A list of the top-level functions in this library.
   */
  public List<FuncRef> getFunctions() {
    JsonArray array = (JsonArray) json.get("functions");
    int size = array.size();
    List<FuncRef> result = new ArrayList<FuncRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new FuncRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * The name of this library.
   */
  public String getName() {
    return json.get("name").getAsString();
  }

  /**
   * A list of the scripts which constitute this library.
   */
  public List<ScriptRef> getScripts() {
    JsonArray array = (JsonArray) json.get("scripts");
    int size = array.size();
    List<ScriptRef> result = new ArrayList<ScriptRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new ScriptRef((JsonObject) array.get(index)));
    }
    return result;
  }

  /**
   * The uri of this library.
   */
  public String getUri() {
    return json.get("uri").getAsString();
  }

  /**
   * A list of the top-level variables in this library.
   */
  public List<FieldRef> getVariables() {
    JsonArray array = (JsonArray) json.get("variables");
    int size = array.size();
    List<FieldRef> result = new ArrayList<FieldRef>();
    for (int index = 0; index < size; ++index) {
      result.add(new FieldRef((JsonObject) array.get(index)));
    }
    return result;
  }
}
