// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_tester;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:vm_service_lib/vm_service_lib.dart';
import 'package:vm_service_lib/vm_service_lib_io.dart';

final String host = 'localhost';
final int port = 7575;

VmService serviceClient;

main(List<String> args) async {
  if (args.length != 1) {
    print('usage: dart example/vm_service_lib_tester.dart <sdk location>');
    exit(1);
  }

  String sdk = args.first;

  print('Using sdk at ${sdk}.');

  // pause_isolates_on_start, pause_isolates_on_exit
  Process process = await Process.start('${sdk}/bin/dart', [
      '--pause_isolates_on_start',
      '--enable-vm-service=${port}',
      'example/sample_main.dart'
  ]);

  print('dart process started');

  process.exitCode.then((code) => print('vm exited: ${code}'));
  // ignore: strong_mode_down_cast_composite
  process.stdout.transform(UTF8.decoder).listen(print);
  // ignore: strong_mode_down_cast_composite
  process.stderr.transform(UTF8.decoder).listen(print);

  await new Future.delayed(new Duration(milliseconds: 500));

  serviceClient = await vmServiceConnect(host, port, log: new StdoutLog());

  print('socket connected');

  serviceClient.onSend.listen((str)    => print('--> ${str}'));
  serviceClient.onReceive.listen((str) => print('<-- ${str}'));

  serviceClient.onIsolateEvent.listen((e) => print('onIsolateEvent: ${e}'));
  serviceClient.onDebugEvent.listen((e) => print('onDebugEvent: ${e}'));
  serviceClient.onGCEvent.listen((e) => print('onGCEvent: ${e}'));
  serviceClient.onStdoutEvent.listen((e) => print('onStdoutEvent: ${e}'));
  serviceClient.onStderrEvent.listen((e) => print('onStderrEvent: ${e}'));

  serviceClient.streamListen('Isolate');
  serviceClient.streamListen('Debug');
  serviceClient.streamListen('Stdout');

  VM vm = await serviceClient.getVM();
  print(await serviceClient.getVersion());
  List<IsolateRef> isolates = await vm.isolates;
  print(isolates);

  IsolateRef isolateRef = isolates.first;
  print(await serviceClient.resume(isolateRef.id));

  serviceClient.dispose();
  process.kill();
}

class StdoutLog extends Log {
  void warning(String message) => print(message);
  void severe(String message) => print(message);
}
