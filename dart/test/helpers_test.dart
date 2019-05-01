// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
import 'dart:convert';

import 'package:test/test.dart';

import 'package:vm_service_lib/vm_service_lib.dart';

void main() {
  test('resultFor generates the expected JSON', () {
    final json = jsonEncode(resultFor(Success().toJson()));
    expect(json, equals('{"result":{"type":"Success"}}'));
  });
  test('resultFor throws if given an object without a type field', () {
    expect(
      () => resultFor({}),
      throwsArgumentError,
    );
  });
  test('errorFor generates the expected JSON', () {
    final json = jsonEncode(errorFor(RpcError("123", 'failed').toJson()));
    expect(json, equals('{"error":{"code":"123","message":"failed"}}'));
  });
}
