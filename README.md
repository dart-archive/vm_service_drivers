# vm_service_drivers

**This repository is now deprecated and has been republished as `package:vm_service`. Please see [https://github.com/dart-lang/sdk/tree/master/pkg/vm_service](https://github.com/dart-lang/sdk/tree/master/pkg/vm_service) for new changes and to file issues.**

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

## See also

The Dart [package](https://github.com/dart-lang/vm_service_drivers/tree/master/dart).

## Feedback

Please file bugs and feedback at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/vm_service_drivers/issues
