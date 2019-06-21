Undocumented (and currently unsupported) service methods and classes.

### _collectAllGarbage

```
Success _collectAllGarbage(string isolateId)
```

Trigger a full GC, collecting all unreachable or weakly reachable objects.

### _requestHeapSnapshot

```
Success _requestHeapSnapshot(string isolateId, string roots, bool collectGarbage)
```

_roots_ is one of User or VM. The results are returned as a stream of
[_Graph] events.

### _clearCpuProfile

```
Success _clearCpuProfile(string isolateId)
```

### _getCpuProfile

```
_CpuProfile _getCpuProfile(string isolateId, string tags)
```

_tags_ is one of UserVM, UserOnly, VMUser, VMOnly, or None.

### _CpuProfile

```
class _CpuProfile extends Response {
  int sampleCount;
  int samplePeriod;
  int stackDepth;
  double timeSpan;
  int timeOriginMicros;
  int timeExtentMicros;
  CodeRegion[] codes;
  ProfileFunction[] functions;
  int[] exclusiveCodeTrie;
  int[] inclusiveCodeTrie;
  int[] exclusiveFunctionTrie;
  int[] inclusiveFunctionTrie;
}
```

### CodeRegion

```
class CodeRegion {
  string kind;
  int inclusiveTicks;
  int exclusiveTicks;
  @Code code;
}
```

<!-- <string|int>[] ticks -->

### ProfileFunction

```
class ProfileFunction {
  string kind;
  int inclusiveTicks;
  int exclusiveTicks;
  @Function function;
  int[] codes;
}
```

<!-- <string|int>[] ticks -->

### AllocationProfile

```
class AllocationProfile extends Response {
  string dateLastServiceGC;
  ClassHeapStats[] members;
}
```

<!-- TODO: int dateLastServiceGC -->

### ClassHeapStats

```
class ClassHeapStats extends Response {
  @Class class;
  int[] new;
  int[] old;
  int promotedBytes;
  int promotedInstances;
}
```

### HeapSpace

```
class HeapSpace extends Response {
  double avgCollectionPeriodMillis;
  int capacity;
  int collections;
  int external;
  String name;
  double time;
  int used;
}
```

<!-- _CpuProfile -->
<!--
    counters: _JsonMap
    codes: JSArray
    functions: JSArray
    exclusiveCodeTrie: JSArray
    inclusiveCodeTrie: JSArray
    exclusiveFunctionTrie: JSArray
    inclusiveFunctionTrie: JSArray
  -->

<!-- _getCpuProfileTimeline -->

<!-- _getAllocationSamples -->

streamId | event types provided
-------- | -----------
_Service | ServiceRegistered, ServiceUnregistered

### _registerService

```
Success _registerService(string service, string alias)
```

### EventKind

```
enum EventKind {
  // Notification that a Service has been registered into the Service Protocol
  // from another client.
  ServiceRegistered,

  // Notification that a Service has been removed from the Service Protocol
  // from another client.
  ServiceUnregistered
}
```

### Event

```
class Event extends Response {
  // The service identifier.
  //
  // This is provided for the event kinds:
  //   ServiceRegistered
  //   ServiceUnregistered
  String service [optional];

  // The RPC method that should be used to invoke the service.
  //
  // This is provided for the event kinds:
  //   ServiceRegistered
  //   ServiceUnregistered
  String method [optional];

  // The alias of the registered service.
  //
  // This is provided for the event kinds:
  //   ServiceRegistered
  String alias [optional];
}
```
