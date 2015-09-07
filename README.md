# vm_service_drivers

Dart and Java libraries to access the VM Service Protocol, and code to generate
both libraries from the markdown specification.

## Usage and Info

The generator can be found in the `dart/` subdirectory, and invoked from
`bin/generate.dart`. It will parse the `service.md` spec and generate the Dart
library (`dart/lib/vm_service_lib.dart`) and the Java library (`java/src`).

The VM Service Protocol spec lives at
[github.com/dart-lang/sdk](https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md).

## Feedback

Please file bugs and feedback at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/vm_service_drivers/issues
