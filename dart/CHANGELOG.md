# Changelog

## 3.14.1
- address an encoding issue with stdout / stderr text

## 3.14.0
- regenerate for `v3.14`
- bump to a major version numbering scheme

## 0.3.10+2
- work around an issue de-serializing Instance.closureContext

## 0.3.10+1
- fix an issue de-serializing some object types

## 0.3.10
- regenerate for `v3.12`
- expose `isolate.getScripts()`
- expose `isolate.getInstances()`

## 0.3.9+2
- handle nulls for `Script.source`
- fix a decoding issue for `Script.tokenPosTable`

## 0.3.9+1
- rev to version `3.9` of the spec
- expose `invoke`

## 0.3.9
- Rename the `Null` type to `NullVal`

## 0.3.8
- upgrades for Dart 2 dependencies

## 0.3.7
- ensure the library works with Dart 2
- regenerate the library based on the 3.8-dev spec
- now require a minimum of a 2.0.0-dev Dart SDK
- update to not use deprecated dart:convert constants

## 0.3.6
- workaround for an issue with the type of @Library refs for VM objects

## 0.3.5+1
- bug fix for deserializing `Instance` objects

## 0.3.5
- improve access to the profiling APIs

## 0.3.4
- more strong mode runtime fixes
- expose some undocumented (and unsupported) service protocol methods

## 0.3.3
- fix strong mode issues at runtime (with JSLists and Lists)
- expose the ability to evaluate in the scope of another object
- expose the async causal frame info
- expose the `awaiterFrames` field
- expose the `frameIndex` param for the step call

## 0.3.2+1
- fix a strong mode issue in the generated Dart library

## 0.3.2
- expose the `PausePostRequest` event

## 0.3.1
- fix a parsing issue with ExtensionData

## 0.2.4
- expose the service protocol timeline API
- add the new `None` event type

## 0.2.3
- include the name of the calling method in RPC errors

## 0.2.2
- fixed several strong mode analysis issues

## 0.2.1
- upgrade to service protocol version `3.3`

## 0.2.0
- upgrade to service protocol version `3.2`

## 0.1.2
- fixed a bug with the `ServiceExtensionAdded` event

## 0.1.1
- expose the new 'Extension' event information

## 0.1.0
- rev to 0.1.0; declare first stable API version

## 0.0.13
- improve the toString() message for RPCError

## 0.0.12
- bug fix for parsing MapAssociations

## 0.0.11
- bug fix to the service extension API

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
