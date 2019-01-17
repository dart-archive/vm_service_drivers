// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'vm_service_lib.dart';

Future<VmService> vmServiceConnect(String host, int port, {Log log}) async {
  WebSocket socket = await WebSocket.connect('ws://$host:$port/ws');
  StreamController<String> controller = StreamController();
  socket.listen((data) => controller.add(data));
  return VmService(controller.stream, (String message) => socket.add(message),
      log: log, disposeHandler: () => socket.close());
}

Future<VmService> vmServiceConnectUri(String wsUri, {Log log}) async {
  WebSocket socket = await WebSocket.connect(wsUri);
  StreamController<String> controller = StreamController();
  socket.listen((data) => controller.add(data));
  return VmService(controller.stream, (String message) => socket.add(message),
      log: log, disposeHandler: () => socket.close());
}
