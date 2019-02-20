// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:vm_service_lib/vm_service_lib.dart';

void main() {
  VmServiceInterface serviceMock;
  StreamController<Map<String, Object>> requestsController;
  StreamController<Map<String, Object>> responsesController;

  setUp(() {
    serviceMock = MockVmService();
    requestsController = StreamController<Map<String, Object>>();
    responsesController = StreamController<Map<String, Object>>();
    VmServer(requestsController.stream, responsesController.sink, serviceMock);
  });

  tearDown(() {
    requestsController.close();
    responsesController.close();
  });

  group('method delegation', () {
    test('works for simple methods', () {
      var request = rpcRequest("getVersion");
      var version = Version()
        ..major = 1
        ..minor = 0;
      when(serviceMock.getVersion()).thenAnswer((_) => Future.value(version));
      expect(responsesController.stream, emits(rpcResponse(version)));
      requestsController.add(request);
    });

    test('works for methods with parameters', () {
      var isolate = Isolate()
        ..id = '123'
        ..number = '0'
        ..startTime = 1
        ..runnable = true
        ..livePorts = 2
        ..pauseOnExit = false
        ..pauseEvent = (Event()
          ..kind = EventKind.kResume
          ..timestamp = 3)
        ..libraries = []
        ..breakpoints = [];
      var request = rpcRequest("getIsolate", params: {'isolateId': isolate.id});
      when(serviceMock.getIsolate(isolate.id))
          .thenAnswer((Invocation invocation) {
        expect(invocation.positionalArguments, equals([isolate.id]));
        return Future.value(isolate);
      });
      expect(responsesController.stream, emits(rpcResponse(isolate)));
      requestsController.add(request);
    });
  });

  group('error handling', () {
    test('special cases RPCError instances', () {
      var request = rpcRequest("getVersion");
      var error =
          RPCError('getVersion', 1234, 'custom message', {'custom': 'data'});
      when(serviceMock.getVersion()).thenAnswer((_) => Future.error(error));
      expect(responsesController.stream, emits(rpcErrorResponse(error)));
      requestsController.add(request);
    });

    test('has a fallback for generic exceptions', () {
      var request = rpcRequest("getVersion");
      var error = UnimplementedError();
      when(serviceMock.getVersion()).thenAnswer((_) => Future.error(error));
      expect(responsesController.stream, emits(rpcErrorResponse(error)));
      requestsController.add(request);
    });
  });
}

Map<String, Object> rpcRequest(String method,
        {Map<String, Object> params = const {}, String id = "1"}) =>
    {
      "jsonrpc": "2.0",
      "method": method,
      "params": params,
      "id": id,
    };

Map<String, Object> rpcResponse(Response response, {String id = "1"}) => {
      'jsonrpc': '2.0',
      'id': id,
      'result': response.toJson(),
    };

Map<String, Object> rpcErrorResponse(Object error, {String id = "1"}) {
  Map<String, Object> errorJson;
  if (error is RPCError) {
    errorJson = {
      'code': error.code,
      'message': error.message,
    };
    if (error.data != null) {
      errorJson['data'] = error.data;
    }
  } else {
    errorJson = {
      'code': -32603,
      'message': error.toString(),
    };
  }
  return {
    'jsonrpc': '2.0',
    'error': errorJson,
    'id': id,
  };
}

class MockVmService extends Mock implements VmServiceInterface {}
