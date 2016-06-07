#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Provision pub packages.
pub get

# Ensure the generator works.
dart tool/generate.dart

# Ensure all the code analyzes cleanly.
pub global activate tuneup
pub global run tuneup check

# Run the VM service protcol smoke tester.
dart -c example/vm_service_lib_tester.dart $DART_SDK
