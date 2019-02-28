// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
import 'dart:async';

import 'package:async/async.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:vm_service_lib/vm_service_lib.dart';

void main() {
  MockVmService serviceMock;
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

    group('custom service extensions', () {
      test('with no params or isolateId', () {
        var extension = 'ext.cool';
        var request = rpcRequest(extension, params: null);
        var response = Response()..json = {"hello": "world"};
        when(serviceMock.callServiceExtension(
          extension,
          isolateId: argThat(isNull, named: 'isolateId'),
          args: argThat(isNull, named: 'args'),
        )).thenAnswer((Invocation invocation) {
          expect(invocation.namedArguments,
              equals({Symbol('isolateId'): null, Symbol('args'): null}));
          return Future.value(response);
        });
        expect(responsesController.stream, emits(rpcResponse(response)));
        requestsController.add(request);
      });

      test('with isolateId and no other params', () {
        var extension = 'ext.cool';
        var request = rpcRequest(extension, params: {'isolateId': '1'});
        var response = Response()..json = {"hello": "world"};
        when(serviceMock.callServiceExtension(
          extension,
          isolateId: argThat(equals('1'), named: 'isolateId'),
          args: argThat(equals({}), named: 'args'),
        )).thenAnswer((Invocation invocation) {
          expect(invocation.namedArguments,
              equals({Symbol('isolateId'): '1', Symbol('args'): {}}));
          return Future.value(response);
        });
        expect(responsesController.stream, emits(rpcResponse(response)));
        requestsController.add(request);
      });

      test('with params and no isolateId', () {
        var extension = 'ext.cool';
        var params = {'cool': 'option'};
        var request = rpcRequest(extension, params: params);
        var response = Response()..json = {"hello": "world"};
        when(serviceMock.callServiceExtension(
          extension,
          isolateId: argThat(isNull, named: 'isolateId'),
          args: argThat(equals(params), named: 'args'),
        )).thenAnswer((Invocation invocation) {
          expect(invocation.namedArguments,
              equals({Symbol('isolateId'): null, Symbol('args'): params}));
          return Future.value(response);
        });
        expect(responsesController.stream, emits(rpcResponse(response)));
        requestsController.add(request);
      });

      test('with params and isolateId', () {
        var extension = 'ext.cool';
        var params = {'cool': 'option'};
        var request =
            rpcRequest(extension, params: Map.of(params)..['isolateId'] = '1');
        var response = Response()..json = {"hello": "world"};
        when(serviceMock.callServiceExtension(
          extension,
          isolateId: argThat(equals("1"), named: 'isolateId'),
          args: argThat(equals(params), named: 'args'),
        )).thenAnswer((Invocation invocation) {
          expect(invocation.namedArguments,
              equals({Symbol('isolateId'): '1', Symbol('args'): params}));
          return Future.value(response);
        });
        expect(responsesController.stream, emits(rpcResponse(response)));
        requestsController.add(request);
      });
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

  group('streams', () {
    test('can be listened to and canceled', () async {
      var streamId = 'Isolate';
      var responseQueue = StreamQueue(responsesController.stream);
      StreamController<Event> eventController;
      {
        var request =
            rpcRequest('streamListen', params: {'streamId': streamId});
        var response = Success();
        when(serviceMock.streamListen(streamId))
            .thenAnswer((_) => Future.value(response));
        requestsController.add(request);
        await expect(responseQueue, emitsThrough(rpcResponse(response)));

        eventController = serviceMock.streamControllers[streamId];

        var events = [
          Event()
            ..kind = EventKind.kIsolateStart
            ..timestamp = 0,
          Event()
            ..kind = EventKind.kIsolateExit
            ..timestamp = 1,
        ];
        events.forEach(eventController.add);
        await expect(
            responseQueue,
            emitsInOrder(
                events.map((event) => streamNotifyResponse(streamId, event))));
      }
      {
        var request =
            rpcRequest('streamCancel', params: {'streamId': streamId});
        var response = Success();
        when(serviceMock.streamListen(streamId))
            .thenAnswer((_) => Future.value(response));
        requestsController.add(request);
        await expect(responseQueue, emitsThrough(rpcResponse(response)));

        var nextEvent = Event()
          ..kind = EventKind.kIsolateReload
          ..timestamp = 2;
        eventController.add(nextEvent);
        expect(responseQueue,
            neverEmits(streamNotifyResponse(streamId, nextEvent)));

        await pumpEventQueue();
        await eventController.close();
        await responsesController.close();
      }
    });
    test("can't be listened to twice", () {
      var streamId = 'Isolate';
      var responseQueue = StreamQueue(responsesController.stream);
      {
        var request =
            rpcRequest('streamListen', params: {'streamId': streamId});
        var response = Success();
        when(serviceMock.streamListen(streamId))
            .thenAnswer((_) => Future.value(response));
        requestsController.add(request);
        expect(responseQueue, emitsThrough(rpcResponse(response)));
      }
      {
        var request =
            rpcRequest('streamListen', params: {'streamId': streamId});
        var response = Success();
        when(serviceMock.streamListen(streamId))
            .thenAnswer((_) => Future.value(response));
        requestsController.add(request);
        expect(
            responseQueue,
            emitsThrough(rpcErrorResponse(
                RPCError('streamSubcribe', 103, 'Stream already subscribed', {
              'details': "The stream '$streamId' is already subscribed",
            }))));
      }
    });

    test("can't cancel a stream that isn't being listened to", () {
      var streamId = 'Isolate';
      var responseQueue = StreamQueue(responsesController.stream);

      var request = rpcRequest('streamCancel', params: {'streamId': streamId});
      var response = Success();
      when(serviceMock.streamListen(streamId))
          .thenAnswer((_) => Future.value(response));
      requestsController.add(request);
      expect(
          responseQueue,
          emitsThrough(rpcErrorResponse(
              RPCError('streamCancel', 104, 'Stream not subscribed', {
            'details': "The stream '$streamId' is not subscribed",
          }))));
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

Map<String, Object> streamNotifyResponse(String streamId, Event event) {
  return {
    'jsonrpc': '2.0',
    'method': 'streamNotify',
    'params': {
      'streamId': '$streamId',
      'event': event.toJson(),
    },
  };
}

class MockVmService extends Mock implements VmServiceInterface {
  final streamControllers = <String, StreamController<Event>>{};

  @override
  Stream<Event> onEvent(String streamId) => streamControllers
      .putIfAbsent(streamId, () => StreamController<Event>())
      .stream;
}
