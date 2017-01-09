#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Provision pub packages.
pub get

# Ensure the generator works.
dart -c tool/generate.dart

# Ensure all the code analyzes cleanly.
dartanalyzer --fatal-warnings \
  example/sample_exception.dart example/sample_isolates.dart example/sample_main.dart \
  example/vm_service_assert.dart example/vm_service_lib_tester.dart \
  lib/vm_service_lib.dart lib/vm_service_lib_io.dart \
  tool/generate.dart

# Run the VM service protocol smoke tester.
dart -c example/vm_service_lib_tester.dart
