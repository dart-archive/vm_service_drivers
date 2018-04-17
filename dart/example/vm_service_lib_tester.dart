// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_tester;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:vm_service_lib/vm_service_lib.dart';
import 'package:vm_service_lib/vm_service_lib_io.dart';

final String host = 'localhost';
final int port = 7575;

VmService serviceClient;

main(List<String> args) async {
  String sdk = path.dirname(path.dirname(Platform.resolvedExecutable));

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
  process.stdout.transform(utf8.decoder).listen(print);
  // ignore: strong_mode_down_cast_composite
  process.stderr.transform(utf8.decoder).listen(print);

  await new Future.delayed(new Duration(milliseconds: 500));

  serviceClient = await vmServiceConnect(host, port, log: new StdoutLog());

  print('socket connected');

  serviceClient.onSend.listen((str) => print('--> ${str}'));
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
  print('hostCPU=${vm.hostCPU}');
  print(await serviceClient.getVersion());
  List<IsolateRef> isolates = await vm.isolates;
  print(isolates);

  // TODO(cbernaschina): remote this check when 1.25 is released
  if (vm.version.contains('1.25.')) {
    await testServiceRegistration();
  }

  IsolateRef isolateRef = isolates.first;
  print(await serviceClient.resume(isolateRef.id));

  serviceClient.dispose();
  process.kill();
}

Future testServiceRegistration() async {
  const String serviceName = 'serviceName';
  const String serviceAlias = 'serviceAlias';
  const String movedValue = 'movedValue';
  serviceClient.registerServiceCallback(serviceName,
      (Map<String, dynamic> params) async {
    assert(params['input'] == movedValue);
    return <String, dynamic>{
      'result': {'output': params['input']}
    };
  });
  await serviceClient.registerService(serviceName, serviceAlias);
  VmService otherClient =
      await vmServiceConnect(host, port, log: new StdoutLog());
  Completer completer = new Completer();
  otherClient.onServiceEvent.listen((e) async {
    if (e.service == serviceName && e.kind == EventKind.kServiceRegistered) {
      assert(e.alias == serviceAlias);
      Response response = await serviceClient.callMethod(
        e.method,
        args: <String, dynamic>{'input': movedValue},
      );
      assert(response.json['output'] == movedValue);
      completer.complete();
    }
  });
  await otherClient.streamListen('_Service');
  await completer.future;
}

class StdoutLog extends Log {
  void warning(String message) => print(message);
  void severe(String message) => print(message);
}
