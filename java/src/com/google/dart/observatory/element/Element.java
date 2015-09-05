package com.google.dart.observatory.element;

import com.google.gson.JsonObject;

/**
 * Superclass for all observatory elements.
 */
public class Element {

  protected JsonObject json;

  public Element(JsonObject json) {
    this.json = json;
  }

  public JsonObject getJson() {
    return json;
  }
}
