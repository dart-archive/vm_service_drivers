#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Print out language versions.
dart --version
java -version

# Switch to the dart/ sub-dir.
pushd dart

# Provision pub packages.
pub get

# Ensure the generator works.
dart tool/generate.dart

if [ "$BOT" = "dart" ]; then

    # Ensure all the code analyzes cleanly.
    dartanalyzer --fatal-infos .

    # Run the VM service protocol smoke tester.
    dart example/vm_service_lib_tester.dart

    # Run the unit tests
    pub run test

elif [ "$BOT" = "java" ]; then

    popd
    pushd java

    # Run the Java tests.
    ant -f build.xml

else

    echo "unknown bot configuration"
    exit 1

fi

popd
