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
package org.dartlang.vm.service.consumer;

import org.dartlang.vm.service.element.Element;
import org.dartlang.vm.service.element.Library;
import org.dartlang.vm.service.element.Obj;
import org.dartlang.vm.service.element.RPCError;
import org.dartlang.vm.service.element.Sentinel;

public abstract class GetInstanceConsumer implements GetObjectConsumer {

  @Override
  public void received(Library response) {
    onError(newRPCError(response));
  }

  @Override
  public void received(Obj response) {
    onError(newRPCError(response));
  }

  @Override
  public void received(Sentinel response) {
    onError(newRPCError(response));
  }

  private RPCError newRPCError(Element response) {
    throw new RuntimeException("not implemented yet");
  }
}
