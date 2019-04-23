// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:vm_service_lib/utils.dart';

@TestOn('vm')
void main() {
  group('getVmWsUriFromObservatoryUri', () {
    void check(String input, String expected) {
      final inputUri = Uri.parse(input);
      final actualUri = getVmWsUriFromObservatoryUri(inputUri);
      expect(actualUri.toString(), equals(expected));
    }

    test('handles http URIs',
        () => check('http://localhost:123/', 'ws://localhost:123/ws'));
    test('handles https URIs',
        () => check('https://localhost:123/', 'wss://localhost:123/ws'));
    test('handles ws URIs',
        () => check('ws://localhost:123/', 'ws://localhost:123/ws'));
    test('handles wss URIs',
        () => check('wss://localhost:123/', 'wss://localhost:123/ws'));
    test(
        'handles http URIs with tokens',
        () => check(
            'http://localhost:123/ABCDEF=/', 'ws://localhost:123/ABCDEF=/ws'));
    test(
        'handles https URIs with tokens',
        () => check('https://localhost:123/ABCDEF=/',
            'wss://localhost:123/ABCDEF=/ws'));
    test(
        'handles ws URIs with tokens',
        () => check(
            'ws://localhost:123/ABCDEF=/', 'ws://localhost:123/ABCDEF=/ws'));
    test(
        'handles wss URIs with tokens',
        () => check(
            'wss://localhost:123/ABCDEF=/', 'wss://localhost:123/ABCDEF=/ws'));
    test('handles http URIs without trailing slashes',
        () => check('http://localhost:123', 'ws://localhost:123/ws'));
    test('handles https URIs without trailing slashes',
        () => check('https://localhost:123', 'wss://localhost:123/ws'));
    test('handles ws URIs without trailing slashes',
        () => check('ws://localhost:123', 'ws://localhost:123/ws'));
    test('handles wss URIs without trailing slashes',
        () => check('wss://localhost:123', 'wss://localhost:123/ws'));
    test(
        'handles http URIs without trailing slashes with tokens',
        () => check(
            'http://localhost:123/ABCDEF=', 'ws://localhost:123/ABCDEF=/ws'));
    test(
        'handles https URIs without trailing slashes with tokens',
        () => check(
            'https://localhost:123/ABCDEF=', 'wss://localhost:123/ABCDEF=/ws'));
    test(
        'handles ws URIs without trailing slashes with tokens',
        () => check(
            'ws://localhost:123/ABCDEF=', 'ws://localhost:123/ABCDEF=/ws'));
    test(
        'handles wss URIs without trailing slashes with tokens',
        () => check(
            'wss://localhost:123/ABCDEF=', 'wss://localhost:123/ABCDEF=/ws'));
  });
}
