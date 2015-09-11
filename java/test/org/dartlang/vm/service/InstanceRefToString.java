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
package org.dartlang.vm.service;

import org.dartlang.vm.service.element.InstanceKind;
import org.dartlang.vm.service.element.InstanceRef;

/**
 * Utility class for converting {@link InstanceRef} to a human readable string.
 */
public class InstanceRefToString {
//  private final VmService service;
//  private final OpLatch latch;

  /**
   * Construct a new instance for converting one or more {@link InstanceRef} to human readable
   * strings. Specify an {@link OpLatch} so that this class can update the expiration time for any
   * waiting thread as it makes {@link VmService} class to obtain details about each
   * {@link InstanceRef}.
   */
  public InstanceRefToString(VmService service, OpLatch latch) {
//    this.service = service;
//    this.latch = latch;
  }

  /**
   * Return a human readable string for the given {@link InstanceRef}.
   */
  public String toString(InstanceRef ref) {
    return toString(ref, 4);
  }

  /**
   * Return a human readable string for the given {@link InstanceRef}.
   * 
   * @param maxDepth the maximum number of recursions this method can make on itself to determine
   *          human readable strings for child objects.
   */
  public String toString(InstanceRef ref, int maxDepth) {
    if (ref == null) {
      return "-- no value --";
    }
    InstanceKind kind = ref.getKind();
    if (kind != null) {
      switch (kind) {
        case Bool:
        case Double:
        case Float32x4:
        case Float64x2:
        case Int:
        case Int32x4:
        case Null:
        case String:
        case StackTrace:
          return ref.getValueAsString();
        case List:
          // TODO call VmService to obtain list content
        case BoundedType:
        case Closure:
        case Float32List:
        case Float32x4List:
        case Float64List:
        case Float64x2List:
        case Int16List:
        case Int32List:
        case Int32x4List:
        case Int64List:
        case Int8List:
        case Map:
        case MirrorReference:
        case PlainInstance:
        case RegExp:
        case Type:
        case TypeParameter:
        case TypeRef:
        case Uint16List:
        case Uint32List:
        case Uint64List:
        case Uint8ClampedList:
        case Uint8List:
        case WeakProperty:
      }
    }
    return "a " + kind;
  }
}
