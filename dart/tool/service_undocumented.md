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

### _getAllocationProfile

```
AllocationProfile _getAllocationProfile(
  string isolateId, 
  string gc [optional],
  bool reset [optional]
)
```

Valid values for _gc_ are 'full'.

### _clearCpuProfile

```
Success _clearCpuProfile(string isolateId)
```

### _getCpuProfile

```
_CpuProfile _getCpuProfile(string isolateId, string tags)
```

_tags_ is one of UserVM, UserOnly, VMUser, VMOnly, or None.

### _clearVMTimeline

```
Success _clearVMTimeline()
```

### _setVMTimelineFlags

```
Success _setVMTimelineFlags(string[] recordedStreams)
```

### _getVMTimeline

```
Response _getVMTimeline()
```

### _CpuProfile

```
class _CpuProfile extends Response {
  int sampleCount;
  int samplePeriod;
  int stackDepth;
  double timeSpan;
  int timeOriginMicros;
  int timeExtentMicros;
}
```

### AllocationProfile

```
class AllocationProfile extends Response {
  int dateLastServiceGC;
  ClassHeapStats[] members;
}
```

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
