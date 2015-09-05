// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void main(List<String> args) {
  String local1 = 'abcd';
  int local2 = 2;

  print('hello from main');

  foo(1);
  foo(local2);
  foo(3);
  foo(local1.length);

  print('exiting...');
}

void foo(int val) {
  print('val: ${val}');
}
