# vm_service_drivers

[![Build Status](https://travis-ci.org/dart-lang/vm_service_drivers.svg)](https://travis-ci.org/dart-lang/vm_service_drivers)

This repository contains Dart and Java libraries to access the VM Service
Protocol, and code to generate both libraries from the markdown specification.

## Usage and Info

The generator can be found in the `dart/` subdirectory, and invoked from
`tool/generate.dart`. It will parse the `tool/service.md` spec and generate the
Dart library (`dart/lib/vm_service_lib.dart`) and the Java library (`java/src`).

Additionally, the Dart library to access the VM Service Protocol is published on
pub as `vm_service_lib`.

The VM Service Protocol spec can be found at
[github.com/dart-lang/sdk/runtime/vm/service/service.md](https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md).

## Feedback

Please file bugs and feedback at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/vm_service_drivers/issues
