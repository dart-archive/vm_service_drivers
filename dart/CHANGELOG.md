# Changelog

## 0.0.10
- expose a service extension API

## 0.0.9
- update to the latest spec to capture the `Event.inspectee` field

## 0.0.8
- allow listening to arbitrary event types
- use Strings for the enum types (to allow for unknown enum values)

## 0.0.7
- make the diagnostic logging synchronous
- remove a workaround for a VM bug (fixed in 1.13.0-dev.7.3)
- several strong mode fixes

## 0.0.6
- added `exceptionPauseMode` to the Isolate class
- added `hashCode` and `operator==` methods to classes supporting object identity
- work around a VM bug with the `type` field of `BoundVariable` and `BoundField`

## 0.0.5
- added more dartdocs
- moved back to using Dart enums
- changed from optional positional params to optional named params

## 0.0.4
- enum redux

## 0.0.3
- update to use a custom enum class
- upgrade to the latest service protocol spec

## 0.0.2
- added the `setExceptionPauseMode` method
- fixed an issue with enum parsing

## 0.0.1
- first publish
- upgraded the library to the 3.0 version of the service protocol
- upgraded the library to the 2.0 version of the service protocol
- copied basic Dart API generator from Atom Dart Plugin
  https://github.com/dart-atom/dartlang/tree/master/tool
- refactored Dart code to generate Java client as well as Dart client
