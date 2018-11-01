// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is a generated file.

/// A library to access the VM Service API.
///
/// The main entry-point for this library is the [VmService] class.
library vm_service_lib;

import 'dart:async';
import 'dart:convert' show base64, jsonDecode, jsonEncode, utf8;
import 'dart:typed_data';

const String vmServiceVersion = '3.12.0';

/// @optional
const String optional = 'optional';

/// @undocumented
const String undocumented = 'undocumented';

/// Decode a string in Base64 encoding into the equivalent non-encoded string.
/// This is useful for handling the results of the Stdout or Stderr events.
String decodeBase64(String str) => new String.fromCharCodes(base64.decode(str));

Object _createObject(dynamic json) {
  if (json == null) return null;

  if (json is List) {
    return json.map((e) => _createObject(e)).toList();
  } else if (json is Map) {
    String type = json['type'];
    if (_typeFactories[type] == null) {
      return null;
    } else {
      return _typeFactories[type](json);
    }
  } else {
    // Handle simple types.
    return json;
  }
}

dynamic _createSpecificObject(
    dynamic json, dynamic creator(Map<String, dynamic> map)) {
  if (json == null) return null;

  if (json is List) {
    return json.map((e) => _createObject(e)).toList();
  } else if (json is Map) {
    Map<String, dynamic> map = {};
    for (dynamic key in json.keys) {
      map[key as String] = json[key];
    }
    return creator(map);
  } else {
    // Handle simple types.
    return json;
  }
}

typedef Future<Map<String, dynamic>> ServiceCallback(
    Map<String, dynamic> params);

Map<String, Function> _typeFactories = {
  'BoundField': BoundField.parse,
  'BoundVariable': BoundVariable.parse,
  'Breakpoint': Breakpoint.parse,
  '@Class': ClassRef.parse,
  'Class': Class.parse,
  'ClassList': ClassList.parse,
  '@Code': CodeRef.parse,
  'Code': Code.parse,
  '@Context': ContextRef.parse,
  'Context': Context.parse,
  'ContextElement': ContextElement.parse,
  '@Error': ErrorRef.parse,
  'Error': Error.parse,
  'Event': Event.parse,
  'ExtensionData': ExtensionData.parse,
  '@Field': FieldRef.parse,
  'Field': Field.parse,
  'Flag': Flag.parse,
  'FlagList': FlagList.parse,
  'Frame': Frame.parse,
  '@Function': FuncRef.parse,
  'Function': Func.parse,
  '@Instance': InstanceRef.parse,
  'Instance': Instance.parse,
  '@Isolate': IsolateRef.parse,
  'Isolate': Isolate.parse,
  '@Library': LibraryRef.parse,
  'Library': Library.parse,
  'LibraryDependency': LibraryDependency.parse,
  'MapAssociation': MapAssociation.parse,
  'Message': Message.parse,
  '@Null': NullValRef.parse,
  'Null': NullVal.parse,
  '@Object': ObjRef.parse,
  'Object': Obj.parse,
  'ReloadReport': ReloadReport.parse,
  'Response': Response.parse,
  'Sentinel': Sentinel.parse,
  '@Script': ScriptRef.parse,
  'Script': Script.parse,
  'ScriptList': ScriptList.parse,
  'SourceLocation': SourceLocation.parse,
  'SourceReport': SourceReport.parse,
  'SourceReportCoverage': SourceReportCoverage.parse,
  'SourceReportRange': SourceReportRange.parse,
  'Stack': Stack.parse,
  'Success': Success.parse,
  'TimelineEvent': TimelineEvent.parse,
  '@TypeArguments': TypeArgumentsRef.parse,
  'TypeArguments': TypeArguments.parse,
  'UnresolvedSourceLocation': UnresolvedSourceLocation.parse,
  'Version': Version.parse,
  '@VM': VMRef.parse,
  'VM': VM.parse,
  '_CpuProfile': CpuProfile.parse,
  'CodeRegion': CodeRegion.parse,
  'ProfileFunction': ProfileFunction.parse,
  'AllocationProfile': AllocationProfile.parse,
  'ClassHeapStats': ClassHeapStats.parse,
  'HeapSpace': HeapSpace.parse,
};

class VmService {
  StreamSubscription _streamSub;
  Function _writeMessage;
  int _id = 0;
  Map<String, Completer> _completers = {};
  Map<String, String> _methodCalls = {};
  Map<String, ServiceCallback> _services = {};
  Log _log;

  StreamController<String> _onSend = new StreamController.broadcast(sync: true);
  StreamController<String> _onReceive =
      new StreamController.broadcast(sync: true);

  Map<String, StreamController<Event>> _eventControllers = {};

  StreamController<Event> _getEventController(String eventName) {
    StreamController<Event> controller = _eventControllers[eventName];
    if (controller == null) {
      controller = new StreamController.broadcast();
      _eventControllers[eventName] = controller;
    }
    return controller;
  }

  DisposeHandler _disposeHandler;

  VmService(Stream<dynamic> /*String|List<int>*/ inStream,
      void writeMessage(String message),
      {Log log, DisposeHandler disposeHandler}) {
    _streamSub = inStream.listen(_processMessage);
    _writeMessage = writeMessage;
    _log = log == null ? new _NullLog() : log;
    _disposeHandler = disposeHandler;
  }

  // VMUpdate
  Stream<Event> get onVMEvent => _getEventController('VM').stream;

  // IsolateStart, IsolateRunnable, IsolateExit, IsolateUpdate, ServiceExtensionAdded
  Stream<Event> get onIsolateEvent => _getEventController('Isolate').stream;

  // PauseStart, PauseExit, PauseBreakpoint, PauseInterrupted, PauseException,
  // Resume, BreakpointAdded, BreakpointResolved, BreakpointRemoved, Inspect
  Stream<Event> get onDebugEvent => _getEventController('Debug').stream;

  // GC
  Stream<Event> get onGCEvent => _getEventController('GC').stream;

  // WriteEvent
  Stream<Event> get onStdoutEvent => _getEventController('Stdout').stream;

  // WriteEvent
  Stream<Event> get onStderrEvent => _getEventController('Stderr').stream;

  // Extension
  Stream<Event> get onExtensionEvent => _getEventController('Extension').stream;

  // _Graph
  Stream<Event> get onGraphEvent => _getEventController('_Graph').stream;

  // _Service
  Stream<Event> get onServiceEvent => _getEventController('_Service').stream;

  // Listen for a specific event name.
  Stream<Event> onEvent(String streamName) =>
      _getEventController(streamName).stream;

  /// The `addBreakpoint` RPC is used to add a breakpoint at a specific line of
  /// some script.
  ///
  /// The `scriptId` parameter is used to specify the target script.
  ///
  /// The `line` parameter is used to specify the target line for the
  /// breakpoint. If there are multiple possible breakpoints on the target line,
  /// then the VM will place the breakpoint at the location which would execute
  /// soonest. If it is not possible to set a breakpoint at the target line, the
  /// breakpoint will be added at the next possible breakpoint location within
  /// the same function.
  ///
  /// The `column` parameter may be optionally specified. This is useful for
  /// targeting a specific breakpoint on a line with multiple possible
  /// breakpoints.
  ///
  /// If no breakpoint is possible at that line, the `102` (Cannot add
  /// breakpoint) error code is returned.
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  ///
  /// See [Breakpoint].
  Future<Breakpoint> addBreakpoint(String isolateId, String scriptId, int line,
      {int column}) {
    Map m = {'isolateId': isolateId, 'scriptId': scriptId, 'line': line};
    if (column != null) m['column'] = column;
    return _call('addBreakpoint', m);
  }

  /// The `addBreakpoint` RPC is used to add a breakpoint at a specific line of
  /// some script. This RPC is useful when a script has not yet been assigned an
  /// id, for example, if a script is in a deferred library which has not yet
  /// been loaded.
  ///
  /// The `scriptUri` parameter is used to specify the target script.
  ///
  /// The `line` parameter is used to specify the target line for the
  /// breakpoint. If there are multiple possible breakpoints on the target line,
  /// then the VM will place the breakpoint at the location which would execute
  /// soonest. If it is not possible to set a breakpoint at the target line, the
  /// breakpoint will be added at the next possible breakpoint location within
  /// the same function.
  ///
  /// The `column` parameter may be optionally specified. This is useful for
  /// targeting a specific breakpoint on a line with multiple possible
  /// breakpoints.
  ///
  /// If no breakpoint is possible at that line, the `102` (Cannot add
  /// breakpoint) error code is returned.
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  ///
  /// See [Breakpoint].
  Future<Breakpoint> addBreakpointWithScriptUri(
      String isolateId, String scriptUri, int line,
      {int column}) {
    Map m = {'isolateId': isolateId, 'scriptUri': scriptUri, 'line': line};
    if (column != null) m['column'] = column;
    return _call('addBreakpointWithScriptUri', m);
  }

  /// The `addBreakpointAtEntry` RPC is used to add a breakpoint at the
  /// entrypoint of some function.
  ///
  /// If no breakpoint is possible at the function entry, the `102` (Cannot add
  /// breakpoint) error code is returned.
  ///
  /// See [Breakpoint].
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  Future<Breakpoint> addBreakpointAtEntry(String isolateId, String functionId) {
    return _call('addBreakpointAtEntry',
        {'isolateId': isolateId, 'functionId': functionId});
  }

  /// The `invoke` RPC is used to perform regular method invocation on some
  /// receiver, as if by dart:mirror's ObjectMirror.invoke. Note this does not
  /// provide a way to perform getter, setter or constructor invocation.
  ///
  /// `targetId` may refer to a [Library], [Class], or [Instance].
  ///
  /// Each elements of `argumentId` may refer to an [Instance].
  ///
  /// If `targetId` or any element of `argumentIds` is a temporary id which has
  /// expired, then the `Expired` [Sentinel] is returned.
  ///
  /// If `targetId` or any element of `argumentIds` refers to an object which
  /// has been collected by the VM's garbage collector, then the `Collected`
  /// [Sentinel] is returned.
  ///
  /// If invocation triggers a failed compilation then [rpc error] 113
  /// "Expression compilation error" is returned.
  ///
  /// If an runtime error occurs while evaluating the invocation, an [ErrorRef]
  /// reference will be returned.
  ///
  /// If the invocation is evaluated successfully, an [InstanceRef] reference
  /// will be returned.
  ///
  /// The return value can be one of [InstanceRef], [ErrorRef] or [Sentinel].
  Future<dynamic> invoke(String isolateId, String targetId, String selector,
      List<String> argumentIds) {
    return _call('invoke', {
      'isolateId': isolateId,
      'targetId': targetId,
      'selector': selector,
      'argumentIds': argumentIds
    });
  }

  /// The `evaluate` RPC is used to evaluate an expression in the context of
  /// some target.
  ///
  /// `targetId` may refer to a [Library], [Class], or [Instance].
  ///
  /// If `targetId` is a temporary id which has expired, then the `Expired`
  /// [Sentinel] is returned.
  ///
  /// If `targetId` refers to an object which has been collected by the VM's
  /// garbage collector, then the `Collected` [Sentinel] is returned.
  ///
  /// If `scope` is provided, it should be a map from identifiers to object ids.
  /// These bindings will be added to the scope in which the expression is
  /// evaluated, which is a child scope of the class or library for
  /// instance/class or library targets respectively. This means bindings
  /// provided in `scope` may shadow instance members, class members and
  /// top-level members.
  ///
  /// If expression is failed to parse and compile, then [rpc error] 113
  /// "Expression compilation error" is returned.
  ///
  /// If an error occurs while evaluating the expression, an [ErrorRef]
  /// reference will be returned.
  ///
  /// If the expression is evaluated successfully, an [InstanceRef] reference
  /// will be returned.
  ///
  /// The return value can be one of [InstanceRef], [ErrorRef] or [Sentinel].
  Future<dynamic> evaluate(String isolateId, String targetId, String expression,
      {Map<String, String> scope}) {
    Map m = {
      'isolateId': isolateId,
      'targetId': targetId,
      'expression': expression
    };
    if (scope != null) m['scope'] = scope;
    return _call('evaluate', m);
  }

  /// The `evaluateInFrame` RPC is used to evaluate an expression in the context
  /// of a particular stack frame. `frameIndex` is the index of the desired
  /// [Frame], with an index of `0` indicating the top (most recent) frame.
  ///
  /// If `scope` is provided, it should be a map from identifiers to object ids.
  /// These bindings will be added to the scope in which the expression is
  /// evaluated, which is a child scope of the frame's current scope. This means
  /// bindings provided in `scope` may shadow instance members, class members,
  /// top-level members, parameters and locals.
  ///
  /// If expression is failed to parse and compile, then [rpc error] 113
  /// "Expression compilation error" is returned.
  ///
  /// If an error occurs while evaluating the expression, an [ErrorRef]
  /// reference will be returned.
  ///
  /// If the expression is evaluated successfully, an [InstanceRef] reference
  /// will be returned.
  ///
  /// The return value can be one of [InstanceRef], [ErrorRef] or [Sentinel].
  Future<dynamic> evaluateInFrame(
      String isolateId, int frameIndex, String expression,
      {Map<String, String> scope}) {
    Map m = {
      'isolateId': isolateId,
      'frameIndex': frameIndex,
      'expression': expression
    };
    if (scope != null) m['scope'] = scope;
    return _call('evaluateInFrame', m);
  }

  /// The `getFlagList` RPC returns a list of all command line flags in the VM
  /// along with their current values.
  ///
  /// See [FlagList].
  Future<FlagList> getFlagList() => _call('getFlagList');

  /// The `getIsolate` RPC is used to lookup an `Isolate` object by its `id`.
  ///
  /// If `isolateId` refers to an isolate which has exited, then the `Collected`
  /// [Sentinel] is returned.
  ///
  /// See [Isolate].
  ///
  /// The return value can be one of [Isolate] or [Sentinel].
  Future<dynamic> getIsolate(String isolateId) {
    return _call('getIsolate', {'isolateId': isolateId});
  }

  /// The `getScripts` RPC is used to retrieve a `ScriptList` containing all
  /// scripts for an isolate based on the isolate's `isolateId`.
  ///
  /// See [ScriptList].
  Future<ScriptList> getScripts(String isolateId) {
    return _call('getScripts', {'isolateId': isolateId});
  }

  /// The `getObject` RPC is used to lookup an `object` from some isolate by its
  /// `id`.
  ///
  /// If `objectId` is a temporary id which has expired, then the `Expired`
  /// [Sentinel] is returned.
  ///
  /// If `objectId` refers to a heap object which has been collected by the VM's
  /// garbage collector, then the `Collected` [Sentinel] is returned.
  ///
  /// If `objectId` refers to a non-heap object which has been deleted, then the
  /// `Collected` [Sentinel] is returned.
  ///
  /// If the object handle has not expired and the object has not been
  /// collected, then an [Obj] will be returned.
  ///
  /// The `offset` and `count` parameters are used to request subranges of
  /// Instance objects with the kinds: String, List, Map, Uint8ClampedList,
  /// Uint8List, Uint16List, Uint32List, Uint64List, Int8List, Int16List,
  /// Int32List, Int64List, Flooat32List, Float64List, Inst32x3List,
  /// Float32x4List, and Float64x2List. These parameters are otherwise ignored.
  ///
  /// The return value can be one of [Obj] or [Sentinel].
  Future<dynamic> getObject(String isolateId, String objectId,
      {int offset, int count}) {
    Map m = {'isolateId': isolateId, 'objectId': objectId};
    if (offset != null) m['offset'] = offset;
    if (count != null) m['count'] = count;
    return _call('getObject', m);
  }

  /// The `getStack` RPC is used to retrieve the current execution stack and
  /// message queue for an isolate. The isolate does not need to be paused.
  ///
  /// See [Stack].
  Future<Stack> getStack(String isolateId) {
    return _call('getStack', {'isolateId': isolateId});
  }

  /// The `getSourceReport` RPC is used to generate a set of reports tied to
  /// source locations in an isolate.
  ///
  /// The `reports` parameter is used to specify which reports should be
  /// generated. The `reports` parameter is a list, which allows multiple
  /// reports to be generated simultaneously from a consistent isolate state.
  /// The `reports` parameter is allowed to be empty (this might be used to
  /// force compilation of a particular subrange of some script).
  ///
  /// The available report kinds are:
  ///
  /// report kind | meaning
  /// ----------- | -------
  /// Coverage | Provide code coverage information
  /// PossibleBreakpoints | Provide a list of token positions which correspond
  /// to possible breakpoints.
  ///
  /// The `scriptId` parameter is used to restrict the report to a particular
  /// script. When analyzing a particular script, either or both of the
  /// `tokenPos` and `endTokenPos` parameters may be provided to restrict the
  /// analysis to a subrange of a script (for example, these can be used to
  /// restrict the report to the range of a particular class or function).
  ///
  /// If the `scriptId` parameter is not provided then the reports are generated
  /// for all loaded scripts and the `tokenPos` and `endTokenPos` parameters are
  /// disallowed.
  ///
  /// The `forceCompilation` parameter can be used to force compilation of all
  /// functions in the range of the report. Forcing compilation can cause a
  /// compilation error, which could terminate the running Dart program. If this
  /// parameter is not provided, it is considered to have the value `false`.
  ///
  /// See [SourceReport].
  Future<SourceReport> getSourceReport(
      String isolateId, List<SourceReportKind> reports,
      {String scriptId, int tokenPos, int endTokenPos, bool forceCompile}) {
    Map m = {'isolateId': isolateId, 'reports': reports};
    if (scriptId != null) m['scriptId'] = scriptId;
    if (tokenPos != null) m['tokenPos'] = tokenPos;
    if (endTokenPos != null) m['endTokenPos'] = endTokenPos;
    if (forceCompile != null) m['forceCompile'] = forceCompile;
    return _call('getSourceReport', m);
  }

  /// The `getVersion` RPC is used to determine what version of the Service
  /// Protocol is served by a VM.
  ///
  /// See [Version].
  Future<Version> getVersion() => _call('getVersion');

  /// The `getVM` RPC returns global information about a Dart virtual machine.
  ///
  /// See [VM].
  Future<VM> getVM() => _call('getVM');

  /// The `pause` RPC is used to interrupt a running isolate. The RPC enqueues
  /// the interrupt request and potentially returns before the isolate is
  /// paused.
  ///
  /// When the isolate is paused an event will be sent on the `Debug` stream.
  ///
  /// See [Success].
  Future<Success> pause(String isolateId) {
    return _call('pause', {'isolateId': isolateId});
  }

  /// The `kill` RPC is used to kill an isolate as if by dart:isolate's
  /// <code>Isolate.kill(IMMEDIATE)</code>Isolate.kill(IMMEDIATE).
  ///
  /// The isolate is killed regardless of whether it is paused or running.
  ///
  /// See [Success].
  Future<Success> kill(String isolateId) {
    return _call('kill', {'isolateId': isolateId});
  }

  /// The `reloadSources` RPC is used to perform a hot reload of an Isolate's
  /// sources.
  ///
  /// if the `force` parameter is provided, it indicates that all of the
  /// Isolate's sources should be reloaded regardless of modification time.
  ///
  /// if the `pause` parameter is provided, the isolate will pause immediately
  /// after the reload.
  ///
  /// if the `rootLibUri` parameter is provided, it indicates the new uri to the
  /// Isolate's root library.
  ///
  /// if the `packagesUri` parameter is provided, it indicates the new uri to
  /// the Isolate's package map (.packages) file.
  Future<ReloadReport> reloadSources(String isolateId,
      {bool force, bool pause, String rootLibUri, String packagesUri}) {
    Map m = {'isolateId': isolateId};
    if (force != null) m['force'] = force;
    if (pause != null) m['pause'] = pause;
    if (rootLibUri != null) m['rootLibUri'] = rootLibUri;
    if (packagesUri != null) m['packagesUri'] = packagesUri;
    return _call('reloadSources', m);
  }

  /// The `removeBreakpoint` RPC is used to remove a breakpoint by its `id`.
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  ///
  /// See [Success].
  Future<Success> removeBreakpoint(String isolateId, String breakpointId) {
    return _call('removeBreakpoint',
        {'isolateId': isolateId, 'breakpointId': breakpointId});
  }

  /// The `resume` RPC is used to resume execution of a paused isolate.
  ///
  /// If the `step` parameter is not provided, the program will resume regular
  /// execution.
  ///
  /// If the `step` parameter is provided, it indicates what form of
  /// single-stepping to use.
  ///
  /// step | meaning
  /// ---- | -------
  /// Into | Single step, entering function calls
  /// Over | Single step, skipping over function calls
  /// Out | Single step until the current function exits
  /// Rewind | Immediately exit the top frame(s) without executing any code.
  /// Isolate will be paused at the call of the last exited function.
  ///
  /// The `frameIndex` parameter is only used when the `step` parameter is
  /// Rewind. It specifies the stack frame to rewind to. Stack frame 0 is the
  /// currently executing function, so `frameIndex` must be at least 1.
  ///
  /// If the `frameIndex` parameter is not provided, it defaults to 1.
  ///
  /// See [Success], [StepOption].
  Future<Success> resume(String isolateId,
      {/*StepOption*/ String step, int frameIndex}) {
    Map m = {'isolateId': isolateId};
    if (step != null) m['step'] = step;
    if (frameIndex != null) m['frameIndex'] = frameIndex;
    return _call('resume', m);
  }

  /// The `setExceptionPauseMode` RPC is used to control if an isolate pauses
  /// when an exception is thrown.
  ///
  /// mode | meaning
  /// ---- | -------
  /// None | Do not pause isolate on thrown exceptions
  /// Unhandled | Pause isolate on unhandled exceptions
  /// All  | Pause isolate on all thrown exceptions
  Future<Success> setExceptionPauseMode(
      String isolateId, /*ExceptionPauseMode*/ String mode) {
    return _call(
        'setExceptionPauseMode', {'isolateId': isolateId, 'mode': mode});
  }

  /// The `setFlag` RPC is used to set a VM flag at runtime. Returns an error if
  /// the named flag does not exist, the flag may not be set at runtime, or the
  /// value is of the wrong type for the flag.
  ///
  /// The following flags may be set at runtime:
  Future<Success> setFlag(String name, String value) {
    return _call('setFlag', {'name': name, 'value': value});
  }

  /// The `setLibraryDebuggable` RPC is used to enable or disable whether
  /// breakpoints and stepping work for a given library.
  ///
  /// See [Success].
  Future<Success> setLibraryDebuggable(
      String isolateId, String libraryId, bool isDebuggable) {
    return _call('setLibraryDebuggable', {
      'isolateId': isolateId,
      'libraryId': libraryId,
      'isDebuggable': isDebuggable
    });
  }

  /// The `setName` RPC is used to change the debugging name for an isolate.
  ///
  /// See [Success].
  Future<Success> setName(String isolateId, String name) {
    return _call('setName', {'isolateId': isolateId, 'name': name});
  }

  /// The `setVMName` RPC is used to change the debugging name for the vm.
  ///
  /// See [Success].
  Future<Success> setVMName(String name) {
    return _call('setVMName', {'name': name});
  }

  /// The `streamCancel` RPC cancels a stream subscription in the VM.
  ///
  /// If the client is not subscribed to the stream, the `104` (Stream not
  /// subscribed) error code is returned.
  ///
  /// See [Success].
  Future<Success> streamCancel(String streamId) {
    return _call('streamCancel', {'streamId': streamId});
  }

  /// The `streamListen` RPC subscribes to a stream in the VM. Once subscribed,
  /// the client will begin receiving events from the stream.
  ///
  /// If the client is not subscribed to the stream, the `103` (Stream already
  /// subscribed) error code is returned.
  ///
  /// The `streamId` parameter may have the following published values:
  ///
  /// streamId | event types provided
  /// -------- | -----------
  /// VM | VMUpdate
  /// Isolate | IsolateStart, IsolateRunnable, IsolateExit, IsolateUpdate,
  /// IsolateReload, ServiceExtensionAdded
  /// Debug | PauseStart, PauseExit, PauseBreakpoint, PauseInterrupted,
  /// PauseException, PausePostRequest, Resume, BreakpointAdded,
  /// BreakpointResolved, BreakpointRemoved, Inspect, None
  /// GC | GC
  /// Extension | Extension
  /// Timeline | TimelineEvents
  ///
  /// Additionally, some embedders provide the `Stdout` and `Stderr` streams.
  /// These streams allow the client to subscribe to writes to stdout and
  /// stderr.
  ///
  /// streamId | event types provided
  /// -------- | -----------
  /// Stdout | WriteEvent
  /// Stderr | WriteEvent
  ///
  /// It is considered a `backwards compatible` change to add a new type of
  /// event to an existing stream. Clients should be written to handle this
  /// gracefully, perhaps by warning and ignoring.
  ///
  /// See [Success].
  Future<Success> streamListen(String streamId) {
    return _call('streamListen', {'streamId': streamId});
  }

  /// Trigger a full GC, collecting all unreachable or weakly reachable objects.
  @undocumented
  Future<Success> collectAllGarbage(String isolateId) {
    return _call('_collectAllGarbage', {'isolateId': isolateId});
  }

  /// `roots` is one of User or VM. The results are returned as a stream of
  /// [_Graph] events.
  @undocumented
  Future<Success> requestHeapSnapshot(
      String isolateId, String roots, bool collectGarbage) {
    return _call('_requestHeapSnapshot', {
      'isolateId': isolateId,
      'roots': roots,
      'collectGarbage': collectGarbage
    });
  }

  /// Valid values for `gc` are 'full'.
  @undocumented
  Future<AllocationProfile> getAllocationProfile(String isolateId,
      {String gc, bool reset}) {
    Map m = {'isolateId': isolateId};
    if (gc != null) m['gc'] = gc;
    if (reset != null) m['reset'] = reset;
    return _call('_getAllocationProfile', m);
  }

  /// Returns a ServiceObject (a specialization of an ObjRef).
  @undocumented
  Future<ObjRef> getInstances(String isolateId, String classId, int limit) {
    return _call('_getInstances',
        {'isolateId': isolateId, 'classId': classId, 'limit': limit});
  }

  @undocumented
  Future<Success> clearCpuProfile(String isolateId) {
    return _call('_clearCpuProfile', {'isolateId': isolateId});
  }

  /// `tags` is one of UserVM, UserOnly, VMUser, VMOnly, or None.
  @undocumented
  Future<CpuProfile> getCpuProfile(String isolateId, String tags) {
    return _call('_getCpuProfile', {'isolateId': isolateId, 'tags': tags});
  }

  @undocumented
  Future<Success> clearVMTimeline() => _call('_clearVMTimeline');

  @undocumented
  Future<Success> setVMTimelineFlags(List<String> recordedStreams) {
    return _call('_setVMTimelineFlags', {'recordedStreams': recordedStreams});
  }

  @undocumented
  Future<Response> getVMTimeline() => _call('_getVMTimeline');

  @undocumented
  Future<Success> registerService(String service, String alias) {
    return _call('_registerService', {'service': service, 'alias': alias});
  }

  /// Call an arbitrary service protocol method. This allows clients to call
  /// methods not explicitly exposed by this library.
  Future<Response> callMethod(String method, {String isolateId, Map args}) {
    return callServiceExtension(method, isolateId: isolateId, args: args);
  }

  /// Invoke a specific service protocol extension method.
  ///
  /// See https://api.dartlang.org/stable/dart-developer/dart-developer-library.html.
  Future<Response> callServiceExtension(String method,
      {String isolateId, Map args}) {
    if (args == null && isolateId == null) {
      return _call(method);
    } else if (args == null) {
      return _call(method, {'isolateId': isolateId});
    } else {
      args = new Map.from(args);
      args['isolateId'] = isolateId;
      return _call(method, args);
    }
  }

  Stream<String> get onSend => _onSend.stream;

  Stream<String> get onReceive => _onReceive.stream;

  void dispose() {
    _streamSub.cancel();
    _completers.values.forEach((c) => c.completeError('disposed'));
    if (_disposeHandler != null) _disposeHandler();
  }

  Future<T> _call<T>(String method, [Map args]) {
    String id = '${++_id}';
    Completer<T> completer = new Completer<T>();
    _completers[id] = completer;
    _methodCalls[id] = method;
    Map m = {'id': id, 'method': method};
    if (args != null) m['params'] = args;
    String message = jsonEncode(m);
    _onSend.add(message);
    _writeMessage(message);
    return completer.future;
  }

  /// Register a service for invocation.
  void registerServiceCallback(String service, ServiceCallback cb) {
    if (_services.containsKey(service)) {
      throw new Exception('Service \'${service}\' already registered');
    }
    _services[service] = cb;
  }

  void _processMessage(dynamic message) {
    // Expect a String, an int[], or a ByteData.

    if (message is String) {
      _processMessageStr(message);
    } else if (message is List<int>) {
      Uint8List list = new Uint8List.fromList(message);
      _processMessageByteData(new ByteData.view(list.buffer));
    } else if (message is ByteData) {
      _processMessageByteData(message);
    } else {
      _log.warning('unknown message type: ${message.runtimeType}');
    }
  }

  void _processMessageByteData(ByteData bytes) {
    int offset = 0;
    int metaSize = bytes.getUint32(offset + 4, Endian.big);
    offset += 8;
    String meta = utf8.decode(new Uint8List.view(
        bytes.buffer, bytes.offsetInBytes + offset, metaSize));
    offset += metaSize;
    ByteData data = new ByteData.view(bytes.buffer,
        bytes.offsetInBytes + offset, bytes.lengthInBytes - offset);
    dynamic map = jsonDecode(meta);
    if (map != null && map['method'] == 'streamNotify') {
      String streamId = map['params']['streamId'];
      Map event = map['params']['event'];
      event['_data'] = data;
      _getEventController(streamId).add(_createObject(event));
    }
  }

  void _processMessageStr(String message) {
    var json;
    try {
      _onReceive.add(message);

      json = jsonDecode(message);
    } catch (e, s) {
      _log.severe('unable to decode message: ${message}, ${e}\n${s}');
      return;
    }

    if (json.containsKey('method')) {
      if (json.containsKey('id')) {
        _processRequest(json);
      } else {
        _processNotification(json);
      }
    } else if (json.containsKey('id') &&
        (json.containsKey('result') || json.containsKey('error'))) {
      _processResponse(json);
    } else {
      _log.severe('unknown message type: ${message}');
    }
  }

  void _processResponse(Map<String, dynamic> json) {
    Completer completer = _completers.remove(json['id']);
    String methodName = _methodCalls.remove(json['id']);

    if (completer == null) {
      _log.severe('unmatched request response: ${jsonEncode(json)}');
    } else if (json['error'] != null) {
      completer.completeError(RPCError.parse(methodName, json['error']));
    } else {
      Map<String, dynamic> result = json['result'] as Map<String, dynamic>;
      String type = result['type'];
      if (_typeFactories[type] == null) {
        completer.complete(Response.parse(result));
      } else {
        completer.complete(_createObject(result));
      }
    }
  }

  Future _processRequest(Map<String, dynamic> json) async {
    final Map m = await _routeRequest(json['method'], json['params']);
    m['id'] = json['id'];
    m['jsonrpc'] = '2.0';
    String message = jsonEncode(m);
    _onSend.add(message);
    _writeMessage(message);
  }

  Future _processNotification(Map<String, dynamic> json) async {
    final String method = json['method'];
    final Map params = json['params'];
    if (method == 'streamNotify') {
      String streamId = params['streamId'];
      _getEventController(streamId).add(_createObject(params['event']));
    } else {
      await _routeRequest(method, params);
    }
  }

  Future<Map> _routeRequest(String method, Map params) async {
    try {
      if (_services.containsKey(method)) {
        return await _services[method](params);
      }
      return {
        'error': {
          'code': -32601, // Method not found
          'message': 'Method not found \'${method}\''
        }
      };
    } catch (e, s) {
      return <String, dynamic>{
        'code': -32000, // SERVER ERROR
        'message': 'Unexpected Server Error ${e}\n${s}'
      };
    }
  }
}

typedef Future DisposeHandler();

class RPCError {
  static RPCError parse(String callingMethod, dynamic json) {
    return new RPCError(
        callingMethod, json['code'], json['message'], json['data']);
  }

  final String callingMethod;
  final int code;
  final String message;
  final Map data;

  RPCError(this.callingMethod, this.code, this.message, [this.data]);

  String get details => data == null ? null : data['details'];

  String toString() {
    if (details == null) {
      return '${message} (${code}) from ${callingMethod}()';
    } else {
      return '${message} (${code}) from ${callingMethod}():\n${details}';
    }
  }
}

/// An `ExtensionData` is an arbitrary map that can have any contents.
class ExtensionData {
  static ExtensionData parse(Map json) =>
      json == null ? null : new ExtensionData._fromJson(json);

  final Map data;

  ExtensionData() : data = {};

  ExtensionData._fromJson(this.data) {}

  String toString() => '[ExtensionData ${data}]';
}

/// A logging handler you can pass to a [VmService] instance in order to get
/// notifications of non-fatal service protocol warnings and errors.
abstract class Log {
  /// Log a warning level message.
  void warning(String message);

  /// Log an error level message.
  void severe(String message);
}

class _NullLog implements Log {
  void warning(String message) {}
  void severe(String message) {}
}
// enums

class CodeKind {
  CodeKind._();

  static const String kDart = 'Dart';
  static const String kNative = 'Native';
  static const String kStub = 'Stub';
  static const String kTag = 'Tag';
  static const String kCollected = 'Collected';
}

class ErrorKind {
  ErrorKind._();

  /// The isolate has encountered an unhandled Dart exception.
  static const String kUnhandledException = 'UnhandledException';

  /// The isolate has encountered a Dart language error in the program.
  static const String kLanguageError = 'LanguageError';

  /// The isolate has encounted an internal error. These errors should be
  /// reported as bugs.
  static const String kInternalError = 'InternalError';

  /// The isolate has been terminated by an external source.
  static const String kTerminationError = 'TerminationError';
}

/// Adding new values to `EventKind` is considered a backwards compatible
/// change. Clients should ignore unrecognized events.
class EventKind {
  EventKind._();

  /// Notification that VM identifying information has changed. Currently used
  /// to notify of changes to the VM debugging name via setVMName.
  static const String kVMUpdate = 'VMUpdate';

  /// Notification that a new isolate has started.
  static const String kIsolateStart = 'IsolateStart';

  /// Notification that an isolate is ready to run.
  static const String kIsolateRunnable = 'IsolateRunnable';

  /// Notification that an isolate has exited.
  static const String kIsolateExit = 'IsolateExit';

  /// Notification that isolate identifying information has changed. Currently
  /// used to notify of changes to the isolate debugging name via setName.
  static const String kIsolateUpdate = 'IsolateUpdate';

  /// Notification that an isolate has been reloaded.
  static const String kIsolateReload = 'IsolateReload';

  /// Notification that an extension RPC was registered on an isolate.
  static const String kServiceExtensionAdded = 'ServiceExtensionAdded';

  /// An isolate has paused at start, before executing code.
  static const String kPauseStart = 'PauseStart';

  /// An isolate has paused at exit, before terminating.
  static const String kPauseExit = 'PauseExit';

  /// An isolate has paused at a breakpoint or due to stepping.
  static const String kPauseBreakpoint = 'PauseBreakpoint';

  /// An isolate has paused due to interruption via pause.
  static const String kPauseInterrupted = 'PauseInterrupted';

  /// An isolate has paused due to an exception.
  static const String kPauseException = 'PauseException';

  /// An isolate has paused after a service request.
  static const String kPausePostRequest = 'PausePostRequest';

  /// An isolate has started or resumed execution.
  static const String kResume = 'Resume';

  /// Indicates an isolate is not yet runnable. Only appears in an Isolate's
  /// pauseEvent. Never sent over a stream.
  static const String kNone = 'None';

  /// A breakpoint has been added for an isolate.
  static const String kBreakpointAdded = 'BreakpointAdded';

  /// An unresolved breakpoint has been resolved for an isolate.
  static const String kBreakpointResolved = 'BreakpointResolved';

  /// A breakpoint has been removed.
  static const String kBreakpointRemoved = 'BreakpointRemoved';

  /// A garbage collection event.
  static const String kGC = 'GC';

  /// Notification of bytes written, for example, to stdout/stderr.
  static const String kWriteEvent = 'WriteEvent';

  /// Notification from dart:developer.inspect.
  static const String kInspect = 'Inspect';

  /// Event from dart:developer.postEvent.
  static const String kExtension = 'Extension';

  /// Notification that a Service has been registered into the Service Protocol
  /// from another client.
  static const String kServiceRegistered = 'ServiceRegistered';

  /// Notification that a Service has been removed from the Service Protocol
  /// from another client.
  static const String kServiceUnregistered = 'ServiceUnregistered';
}

/// Adding new values to `InstanceKind` is considered a backwards compatible
/// change. Clients should treat unrecognized instance kinds as `PlainInstance`.
class InstanceKind {
  InstanceKind._();

  /// A general instance of the Dart class Object.
  static const String kPlainInstance = 'PlainInstance';

  /// null instance.
  static const String kNull = 'Null';

  /// true or false.
  static const String kBool = 'Bool';

  /// An instance of the Dart class double.
  static const String kDouble = 'Double';

  /// An instance of the Dart class int.
  static const String kInt = 'Int';

  /// An instance of the Dart class String.
  static const String kString = 'String';

  /// An instance of the built-in VM List implementation. User-defined Lists
  /// will be PlainInstance.
  static const String kList = 'List';

  /// An instance of the built-in VM Map implementation. User-defined Maps will
  /// be PlainInstance.
  static const String kMap = 'Map';

  /// Vector instance kinds.
  static const String kFloat32x4 = 'Float32x4';
  static const String kFloat64x2 = 'Float64x2';
  static const String kInt32x4 = 'Int32x4';

  /// An instance of the built-in VM TypedData implementations. User-defined
  /// TypedDatas will be PlainInstance.
  static const String kUint8ClampedList = 'Uint8ClampedList';
  static const String kUint8List = 'Uint8List';
  static const String kUint16List = 'Uint16List';
  static const String kUint32List = 'Uint32List';
  static const String kUint64List = 'Uint64List';
  static const String kInt8List = 'Int8List';
  static const String kInt16List = 'Int16List';
  static const String kInt32List = 'Int32List';
  static const String kInt64List = 'Int64List';
  static const String kFloat32List = 'Float32List';
  static const String kFloat64List = 'Float64List';
  static const String kInt32x4List = 'Int32x4List';
  static const String kFloat32x4List = 'Float32x4List';
  static const String kFloat64x2List = 'Float64x2List';

  /// An instance of the Dart class StackTrace.
  static const String kStackTrace = 'StackTrace';

  /// An instance of the built-in VM Closure implementation. User-defined
  /// Closures will be PlainInstance.
  static const String kClosure = 'Closure';

  /// An instance of the Dart class MirrorReference.
  static const String kMirrorReference = 'MirrorReference';

  /// An instance of the Dart class RegExp.
  static const String kRegExp = 'RegExp';

  /// An instance of the Dart class WeakProperty.
  static const String kWeakProperty = 'WeakProperty';

  /// An instance of the Dart class Type.
  static const String kType = 'Type';

  /// An instance of the Dart class TypeParameter.
  static const String kTypeParameter = 'TypeParameter';

  /// An instance of the Dart class TypeRef.
  static const String kTypeRef = 'TypeRef';

  /// An instance of the Dart class BoundedType.
  static const String kBoundedType = 'BoundedType';
}

/// A `SentinelKind` is used to distinguish different kinds of `Sentinel`
/// objects.
///
/// Adding new values to `SentinelKind` is considered a backwards compatible
/// change. Clients must handle this gracefully.
class SentinelKind {
  SentinelKind._();

  /// Indicates that the object referred to has been collected by the GC.
  static const String kCollected = 'Collected';

  /// Indicates that an object id has expired.
  static const String kExpired = 'Expired';

  /// Indicates that a variable or field has not been initialized.
  static const String kNotInitialized = 'NotInitialized';

  /// Indicates that a variable or field is in the process of being initialized.
  static const String kBeingInitialized = 'BeingInitialized';

  /// Indicates that a variable has been eliminated by the optimizing compiler.
  static const String kOptimizedOut = 'OptimizedOut';

  /// Reserved for future use.
  static const String kFree = 'Free';
}

/// A `FrameKind` is used to distinguish different kinds of `Frame` objects.
class FrameKind {
  FrameKind._();

  static const String kRegular = 'Regular';
  static const String kAsyncCausal = 'AsyncCausal';
  static const String kAsyncSuspensionMarker = 'AsyncSuspensionMarker';
  static const String kAsyncActivation = 'AsyncActivation';
}

class SourceReportKind {
  SourceReportKind._();

  /// Used to request a code coverage information.
  static const String kCoverage = 'Coverage';

  /// Used to request a list of token positions of possible breakpoints.
  static const String kPossibleBreakpoints = 'PossibleBreakpoints';
}

/// An `ExceptionPauseMode` indicates how the isolate pauses when an exception
/// is thrown.
class ExceptionPauseMode {
  ExceptionPauseMode._();

  static const String kNone = 'None';
  static const String kUnhandled = 'Unhandled';
  static const String kAll = 'All';
}

/// A `StepOption` indicates which form of stepping is requested in a [resume]
/// RPC.
class StepOption {
  StepOption._();

  static const String kInto = 'Into';
  static const String kOver = 'Over';
  static const String kOverAsyncSuspension = 'OverAsyncSuspension';
  static const String kOut = 'Out';
  static const String kRewind = 'Rewind';
}

// types

/// A `BoundField` represents a field bound to a particular value in an
/// `Instance`.
///
/// If the field is uninitialized, the `value` will be the `NotInitialized`
/// [Sentinel].
///
/// If the field is being initialized, the `value` will be the
/// `BeingInitialized` [Sentinel].
class BoundField {
  static BoundField parse(Map<String, dynamic> json) =>
      json == null ? null : new BoundField._fromJson(json);

  FieldRef decl;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  BoundField();

  BoundField._fromJson(Map<String, dynamic> json) {
    decl = _createObject(json['decl']);
    value = _createObject(json['value']);
  }

  String toString() => '[BoundField decl: ${decl}, value: ${value}]';
}

/// A `BoundVariable` represents a local variable bound to a particular value in
/// a `Frame`.
///
/// If the variable is uninitialized, the `value` will be the `NotInitialized`
/// [Sentinel].
///
/// If the variable is being initialized, the `value` will be the
/// `BeingInitialized` [Sentinel].
///
/// If the variable has been optimized out by the compiler, the `value` will be
/// the `OptimizedOut` [Sentinel].
class BoundVariable {
  static BoundVariable parse(Map<String, dynamic> json) =>
      json == null ? null : new BoundVariable._fromJson(json);

  String name;

  /// [value] can be one of [InstanceRef], [TypeArgumentsRef] or [Sentinel].
  dynamic value;

  /// The token position where this variable was declared.
  int declarationTokenPos;

  /// The first token position where this variable is visible to the scope.
  int scopeStartTokenPos;

  /// The last token position where this variable is visible to the scope.
  int scopeEndTokenPos;

  BoundVariable();

  BoundVariable._fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = _createObject(json['value']);
    declarationTokenPos = json['declarationTokenPos'];
    scopeStartTokenPos = json['scopeStartTokenPos'];
    scopeEndTokenPos = json['scopeEndTokenPos'];
  }

  String toString() => '[BoundVariable ' //
      'name: ${name}, value: ${value}, declarationTokenPos: ${declarationTokenPos}, ' //
      'scopeStartTokenPos: ${scopeStartTokenPos}, scopeEndTokenPos: ${scopeEndTokenPos}]';
}

/// A `Breakpoint` describes a debugger breakpoint.
///
/// A breakpoint is `resolved` when it has been assigned to a specific program
/// location. A breakpoint my remain unresolved when it is in code which has not
/// yet been compiled or in a library which has not been loaded (i.e. a deferred
/// library).
class Breakpoint extends Obj {
  static Breakpoint parse(Map<String, dynamic> json) =>
      json == null ? null : new Breakpoint._fromJson(json);

  /// A number identifying this breakpoint to the user.
  int breakpointNumber;

  /// Has this breakpoint been assigned to a specific program location?
  bool resolved;

  /// Is this a breakpoint that was added synthetically as part of a step
  /// OverAsyncSuspension resume command?
  @optional
  bool isSyntheticAsyncContinuation;

  /// SourceLocation when breakpoint is resolved, UnresolvedSourceLocation when
  /// a breakpoint is not resolved.
  ///
  /// [location] can be one of [SourceLocation] or [UnresolvedSourceLocation].
  dynamic location;

  Breakpoint();

  Breakpoint._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    breakpointNumber = json['breakpointNumber'];
    resolved = json['resolved'];
    isSyntheticAsyncContinuation = json['isSyntheticAsyncContinuation'];
    location = _createObject(json['location']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Breakpoint && id == other.id;

  String toString() => '[Breakpoint ' //
      'type: ${type}, id: ${id}, breakpointNumber: ${breakpointNumber}, ' //
      'resolved: ${resolved}, location: ${location}]';
}

/// `ClassRef` is a reference to a `Class`.
class ClassRef extends ObjRef {
  static ClassRef parse(Map<String, dynamic> json) =>
      json == null ? null : new ClassRef._fromJson(json);

  /// The name of this class.
  String name;

  ClassRef();

  ClassRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is ClassRef && id == other.id;

  String toString() => '[ClassRef type: ${type}, id: ${id}, name: ${name}]';
}

/// A `Class` provides information about a Dart language class.
class Class extends Obj {
  static Class parse(Map<String, dynamic> json) =>
      json == null ? null : new Class._fromJson(json);

  /// The name of this class.
  String name;

  /// The error which occurred during class finalization, if it exists.
  @optional
  ErrorRef error;

  /// Is this an abstract class?
  bool isAbstract;

  /// Is this a const class?
  bool isConst;

  /// The library which contains this class. TODO: This should be @Library, but
  /// the VM can return @Instance objects here.
  ObjRef library;

  /// The location of this class in the source code.
  @optional
  SourceLocation location;

  /// The superclass of this class, if any.
  @optional
  ClassRef superClass;

  /// The supertype for this class, if any.
  ///
  /// The value will be of the kind: Type.
  @optional
  InstanceRef superType;

  /// A list of interface types for this class.
  ///
  /// The values will be of the kind: Type.
  List<InstanceRef> interfaces;

  /// The mixin type for this class, if any.
  ///
  /// The value will be of the kind: Type.
  @optional
  InstanceRef mixin;

  /// A list of fields in this class. Does not include fields from superclasses.
  List<FieldRef> fields;

  /// A list of functions in this class. Does not include functions from
  /// superclasses.
  List<FuncRef> functions;

  /// A list of subclasses of this class.
  List<ClassRef> subclasses;

  Class();

  Class._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    error = _createObject(json['error']);
    isAbstract = json['abstract'];
    isConst = json['const'];
    library = _createObject(json['library']);
    location = _createObject(json['location']);
    superClass = _createObject(json['super']);
    superType = _createObject(json['superType']);
    interfaces = new List<InstanceRef>.from(_createObject(json['interfaces']));
    mixin = _createObject(json['mixin']);
    fields = new List<FieldRef>.from(_createObject(json['fields']));
    functions = new List<FuncRef>.from(_createObject(json['functions']));
    subclasses = new List<ClassRef>.from(_createObject(json['subclasses']));
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Class && id == other.id;

  String toString() => '[Class]';
}

class ClassList extends Response {
  static ClassList parse(Map<String, dynamic> json) =>
      json == null ? null : new ClassList._fromJson(json);

  List<ClassRef> classes;

  ClassList();

  ClassList._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    classes = new List<ClassRef>.from(_createObject(json['classes']));
  }

  String toString() => '[ClassList type: ${type}, classes: ${classes}]';
}

/// `CodeRef` is a reference to a `Code` object.
class CodeRef extends ObjRef {
  static CodeRef parse(Map<String, dynamic> json) =>
      json == null ? null : new CodeRef._fromJson(json);

  /// A name for this code object.
  String name;

  /// What kind of code object is this?
  /*CodeKind*/ String kind;

  CodeRef();

  CodeRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    kind = json['kind'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is CodeRef && id == other.id;

  String toString() =>
      '[CodeRef type: ${type}, id: ${id}, name: ${name}, kind: ${kind}]';
}

/// A `Code` object represents compiled code in the Dart VM.
class Code extends ObjRef {
  static Code parse(Map<String, dynamic> json) =>
      json == null ? null : new Code._fromJson(json);

  /// A name for this code object.
  String name;

  /// What kind of code object is this?
  /*CodeKind*/ String kind;

  Code();

  Code._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    kind = json['kind'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Code && id == other.id;

  String toString() =>
      '[Code type: ${type}, id: ${id}, name: ${name}, kind: ${kind}]';
}

class ContextRef extends ObjRef {
  static ContextRef parse(Map<String, dynamic> json) =>
      json == null ? null : new ContextRef._fromJson(json);

  /// The number of variables in this context.
  int length;

  ContextRef();

  ContextRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    length = json['length'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is ContextRef && id == other.id;

  String toString() =>
      '[ContextRef type: ${type}, id: ${id}, length: ${length}]';
}

/// A `Context` is a data structure which holds the captured variables for some
/// closure.
class Context extends Obj {
  static Context parse(Map<String, dynamic> json) =>
      json == null ? null : new Context._fromJson(json);

  /// The number of variables in this context.
  int length;

  /// The enclosing context for this context.
  @optional
  Context parent;

  /// The variables in this context object.
  List<ContextElement> variables;

  Context();

  Context._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    length = json['length'];
    parent = _createObject(json['parent']);
    variables = new List<ContextElement>.from(_createObject(json['variables']));
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Context && id == other.id;

  String toString() => '[Context ' //
      'type: ${type}, id: ${id}, length: ${length}, variables: ${variables}]';
}

class ContextElement {
  static ContextElement parse(Map<String, dynamic> json) =>
      json == null ? null : new ContextElement._fromJson(json);

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  ContextElement();

  ContextElement._fromJson(Map<String, dynamic> json) {
    value = _createObject(json['value']);
  }

  String toString() => '[ContextElement value: ${value}]';
}

/// `ErrorRef` is a reference to an `Error`.
class ErrorRef extends ObjRef {
  static ErrorRef parse(Map<String, dynamic> json) =>
      json == null ? null : new ErrorRef._fromJson(json);

  /// What kind of error is this?
  /*ErrorKind*/ String kind;

  /// A description of the error.
  String message;

  ErrorRef();

  ErrorRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    kind = json['kind'];
    message = json['message'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is ErrorRef && id == other.id;

  String toString() =>
      '[ErrorRef type: ${type}, id: ${id}, kind: ${kind}, message: ${message}]';
}

/// An `Error` represents a Dart language level error. This is distinct from an
/// [rpc error].
class Error extends Obj {
  static Error parse(Map<String, dynamic> json) =>
      json == null ? null : new Error._fromJson(json);

  /// What kind of error is this?
  /*ErrorKind*/ String kind;

  /// A description of the error.
  String message;

  /// If this error is due to an unhandled exception, this is the exception
  /// thrown.
  @optional
  InstanceRef exception;

  /// If this error is due to an unhandled exception, this is the stacktrace
  /// object.
  @optional
  InstanceRef stacktrace;

  Error();

  Error._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    kind = json['kind'];
    message = json['message'];
    exception = _createObject(json['exception']);
    stacktrace = _createObject(json['stacktrace']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Error && id == other.id;

  String toString() =>
      '[Error type: ${type}, id: ${id}, kind: ${kind}, message: ${message}]';
}

/// An `Event` is an asynchronous notification from the VM. It is delivered only
/// when the client has subscribed to an event stream using the [streamListen]
/// RPC.
///
/// For more information, see [events].
class Event extends Response {
  static Event parse(Map<String, dynamic> json) =>
      json == null ? null : new Event._fromJson(json);

  /// What kind of event is this?
  /*EventKind*/ String kind;

  /// The isolate with which this event is associated.
  ///
  /// This is provided for all event kinds except for:
  ///  - VMUpdate
  @optional
  IsolateRef isolate;

  /// The vm with which this event is associated.
  ///
  /// This is provided for the event kind:
  ///  - VMUpdate
  @optional
  VMRef vm;

  /// The timestamp (in milliseconds since the epoch) associated with this
  /// event. For some isolate pause events, the timestamp is from when the
  /// isolate was paused. For other events, the timestamp is from when the event
  /// was created.
  int timestamp;

  /// The breakpoint which was added, removed, or resolved.
  ///
  /// This is provided for the event kinds:
  ///  - PauseBreakpoint
  ///  - BreakpointAdded
  ///  - BreakpointRemoved
  ///  - BreakpointResolved
  @optional
  Breakpoint breakpoint;

  /// The list of breakpoints at which we are currently paused for a
  /// PauseBreakpoint event.
  ///
  /// This list may be empty. For example, while single-stepping, the VM sends a
  /// PauseBreakpoint event with no breakpoints.
  ///
  /// If there is more than one breakpoint set at the program position, then all
  /// of them will be provided.
  ///
  /// This is provided for the event kinds:
  ///  - PauseBreakpoint
  @optional
  List<Breakpoint> pauseBreakpoints;

  /// The top stack frame associated with this event, if applicable.
  ///
  /// This is provided for the event kinds:
  ///  - PauseBreakpoint
  ///  - PauseInterrupted
  ///  - PauseException
  ///
  /// For PauseInterrupted events, there will be no top frame if the isolate is
  /// idle (waiting in the message loop).
  ///
  /// For the Resume event, the top frame is provided at all times except for
  /// the initial resume event that is delivered when an isolate begins
  /// execution.
  @optional
  Frame topFrame;

  /// The exception associated with this event, if this is a PauseException
  /// event.
  @optional
  InstanceRef exception;

  /// An array of bytes, encoded as a base64 string.
  ///
  /// This is provided for the WriteEvent event.
  @optional
  String bytes;

  /// The argument passed to dart:developer.inspect.
  ///
  /// This is provided for the Inspect event.
  @optional
  InstanceRef inspectee;

  /// The RPC name of the extension that was added.
  ///
  /// This is provided for the ServiceExtensionAdded event.
  @optional
  String extensionRPC;

  /// The extension event kind.
  ///
  /// This is provided for the Extension event.
  @optional
  String extensionKind;

  /// The extension event data.
  ///
  /// This is provided for the Extension event.
  @optional
  ExtensionData extensionData;

  /// An array of TimelineEvents
  ///
  /// This is provided for the TimelineEvents event.
  @optional
  List<TimelineEvent> timelineEvents;

  /// Is the isolate paused at an await, yield, or yield* statement?
  ///
  /// This is provided for the event kinds:
  ///  - PauseBreakpoint
  ///  - PauseInterrupted
  @optional
  bool atAsyncSuspension;

  /// The status (success or failure) related to the event. This is provided for
  /// the event kinds:
  ///  - IsolateReloaded
  ///  - IsolateSpawn
  @optional
  String status;

  /// The service identifier.
  ///
  /// This is provided for the event kinds:
  ///  - ServiceRegistered
  ///  - ServiceUnregistered
  @optional
  String service;

  /// The RPC method that should be used to invoke the service.
  ///
  /// This is provided for the event kinds:
  ///  - ServiceRegistered
  ///  - ServiceUnregistered
  @optional
  String method;

  /// The alias of the registered service.
  ///
  /// This is provided for the event kinds:
  ///  - ServiceRegistered
  @optional
  String alias;

  Event();

  Event._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    kind = json['kind'];
    isolate = _createObject(json['isolate']);
    vm = _createObject(json['vm']);
    timestamp = json['timestamp'];
    breakpoint = _createObject(json['breakpoint']);
    pauseBreakpoints = json['pauseBreakpoints'] == null
        ? null
        : new List<Breakpoint>.from(_createObject(json['pauseBreakpoints']));
    topFrame = _createObject(json['topFrame']);
    exception = _createObject(json['exception']);
    bytes = json['bytes'];
    inspectee = _createObject(json['inspectee']);
    extensionRPC = json['extensionRPC'];
    extensionKind = json['extensionKind'];
    extensionData = ExtensionData.parse(json['extensionData']);
    timelineEvents = json['timelineEvents'] == null
        ? null
        : new List<TimelineEvent>.from(_createObject(json['timelineEvents']));
    atAsyncSuspension = json['atAsyncSuspension'];
    status = json['status'];
    service = json['service'];
    method = json['method'];
    alias = json['alias'];
  }

  String toString() =>
      '[Event type: ${type}, kind: ${kind}, timestamp: ${timestamp}]';
}

/// An `FieldRef` is a reference to a `Field`.
class FieldRef extends ObjRef {
  static FieldRef parse(Map<String, dynamic> json) =>
      json == null ? null : new FieldRef._fromJson(json);

  /// The name of this field.
  String name;

  /// The owner of this field, which can be either a Library or a Class.
  ObjRef owner;

  /// The declared type of this field.
  ///
  /// The value will always be of one of the kinds: Type, TypeRef,
  /// TypeParameter, BoundedType.
  InstanceRef declaredType;

  /// Is this field const?
  bool isConst;

  /// Is this field final?
  bool isFinal;

  /// Is this field static?
  bool isStatic;

  FieldRef();

  FieldRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    declaredType = _createObject(json['declaredType']);
    isConst = json['const'];
    isFinal = json['final'];
    isStatic = json['static'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is FieldRef && id == other.id;

  String toString() => '[FieldRef]';
}

/// A `Field` provides information about a Dart language field or variable.
class Field extends Obj {
  static Field parse(Map<String, dynamic> json) =>
      json == null ? null : new Field._fromJson(json);

  /// The name of this field.
  String name;

  /// The owner of this field, which can be either a Library or a Class.
  ObjRef owner;

  /// The declared type of this field.
  ///
  /// The value will always be of one of the kinds: Type, TypeRef,
  /// TypeParameter, BoundedType.
  InstanceRef declaredType;

  /// Is this field const?
  bool isConst;

  /// Is this field final?
  bool isFinal;

  /// Is this field static?
  bool isStatic;

  /// The value of this field, if the field is static.
  @optional
  InstanceRef staticValue;

  /// The location of this field in the source code.
  @optional
  SourceLocation location;

  Field();

  Field._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    declaredType = _createObject(json['declaredType']);
    isConst = json['const'];
    isFinal = json['final'];
    isStatic = json['static'];
    staticValue = _createObject(json['staticValue']);
    location = _createObject(json['location']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Field && id == other.id;

  String toString() => '[Field]';
}

/// A `Flag` represents a single VM command line flag.
class Flag {
  static Flag parse(Map<String, dynamic> json) =>
      json == null ? null : new Flag._fromJson(json);

  /// The name of the flag.
  String name;

  /// A description of the flag.
  String comment;

  /// Has this flag been modified from its default setting?
  bool modified;

  /// The value of this flag as a string.
  ///
  /// If this property is absent, then the value of the flag was NULL.
  @optional
  String valueAsString;

  Flag();

  Flag._fromJson(Map<String, dynamic> json) {
    name = json['name'];
    comment = json['comment'];
    modified = json['modified'];
    valueAsString = json['valueAsString'];
  }

  String toString() =>
      '[Flag name: ${name}, comment: ${comment}, modified: ${modified}]';
}

/// A `FlagList` represents the complete set of VM command line flags.
class FlagList extends Response {
  static FlagList parse(Map<String, dynamic> json) =>
      json == null ? null : new FlagList._fromJson(json);

  /// A list of all flags in the VM.
  List<Flag> flags;

  FlagList();

  FlagList._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    flags = new List<Flag>.from(_createObject(json['flags']));
  }

  String toString() => '[FlagList type: ${type}, flags: ${flags}]';
}

class Frame extends Response {
  static Frame parse(Map<String, dynamic> json) =>
      json == null ? null : new Frame._fromJson(json);

  int index;

  @optional
  FuncRef function;

  @optional
  CodeRef code;

  @optional
  SourceLocation location;

  @optional
  List<BoundVariable> vars;

  @optional
  /*FrameKind*/
  String kind;

  Frame();

  Frame._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    index = json['index'];
    function = _createObject(json['function']);
    code = _createObject(json['code']);
    location = _createObject(json['location']);
    vars = json['vars'] == null
        ? null
        : new List<BoundVariable>.from(_createObject(json['vars']));
    kind = json['kind'];
  }

  String toString() => '[Frame type: ${type}, index: ${index}]';
}

/// An `FuncRef` is a reference to a `Func`.
class FuncRef extends ObjRef {
  static FuncRef parse(Map<String, dynamic> json) =>
      json == null ? null : new FuncRef._fromJson(json);

  /// The name of this function.
  String name;

  /// The owner of this function, which can be a Library, Class, or a Function.
  ///
  /// [owner] can be one of [LibraryRef], [ClassRef] or [FuncRef].
  dynamic owner;

  /// Is this function static?
  bool isStatic;

  /// Is this function const?
  bool isConst;

  FuncRef();

  FuncRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    isStatic = json['static'];
    isConst = json['const'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is FuncRef && id == other.id;

  String toString() => '[FuncRef ' //
      'type: ${type}, id: ${id}, name: ${name}, owner: ${owner}, ' //
      'isStatic: ${isStatic}, isConst: ${isConst}]';
}

/// A `Func` represents a Dart language function.
class Func extends Obj {
  static Func parse(Map<String, dynamic> json) =>
      json == null ? null : new Func._fromJson(json);

  /// The name of this function.
  String name;

  /// The owner of this function, which can be a Library, Class, or a Function.
  ///
  /// [owner] can be one of [LibraryRef], [ClassRef] or [FuncRef].
  dynamic owner;

  /// The location of this function in the source code.
  @optional
  SourceLocation location;

  /// The compiled code associated with this function.
  @optional
  CodeRef code;

  Func();

  Func._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    location = _createObject(json['location']);
    code = _createObject(json['code']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Func && id == other.id;

  String toString() =>
      '[Func type: ${type}, id: ${id}, name: ${name}, owner: ${owner}]';
}

/// `InstanceRef` is a reference to an `Instance`.
class InstanceRef extends ObjRef {
  static InstanceRef parse(Map<String, dynamic> json) =>
      json == null ? null : new InstanceRef._fromJson(json);

  /// What kind of instance is this?
  /*InstanceKind*/ String kind;

  /// Instance references always include their class.
  ClassRef classRef;

  /// The value of this instance as a string.
  ///
  /// Provided for the instance kinds:
  ///  - Null (null)
  ///  - Bool (true or false)
  ///  - Double (suitable for passing to Double.parse())
  ///  - Int (suitable for passing to int.parse())
  ///  - String (value may be truncated)
  ///  - Float32x4
  ///  - Float64x2
  ///  - Int32x4
  ///  - StackTrace
  @optional
  String valueAsString;

  /// The valueAsString for String references may be truncated. If so, this
  /// property is added with the value 'true'.
  ///
  /// New code should use 'length' and 'count' instead.
  @optional
  bool valueAsStringIsTruncated;

  /// The length of a List or the number of associations in a Map or the number
  /// of codeunits in a String.
  ///
  /// Provided for instance kinds:
  ///  - String
  ///  - List
  ///  - Map
  ///  - Uint8ClampedList
  ///  - Uint8List
  ///  - Uint16List
  ///  - Uint32List
  ///  - Uint64List
  ///  - Int8List
  ///  - Int16List
  ///  - Int32List
  ///  - Int64List
  ///  - Float32List
  ///  - Float64List
  ///  - Int32x4List
  ///  - Float32x4List
  ///  - Float64x2List
  @optional
  int length;

  /// The name of a Type instance.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional
  String name;

  /// The corresponding Class if this Type has a resolved typeClass.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional
  ClassRef typeClass;

  /// The parameterized class of a type parameter:
  ///
  /// Provided for instance kinds:
  ///  - TypeParameter
  @optional
  ClassRef parameterizedClass;

  /// The pattern of a RegExp instance.
  ///
  /// The pattern is always an instance of kind String.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional
  InstanceRef pattern;

  InstanceRef();

  InstanceRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    kind = json['kind'];
    classRef = _createObject(json['class']);
    valueAsString = json['valueAsString'];
    valueAsStringIsTruncated = json['valueAsStringIsTruncated'] ?? false;
    length = json['length'];
    name = json['name'];
    typeClass = _createObject(json['typeClass']);
    parameterizedClass = _createObject(json['parameterizedClass']);
    pattern = _createObject(json['pattern']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is InstanceRef && id == other.id;

  String toString() => '[InstanceRef ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}]';
}

/// An `Instance` represents an instance of the Dart language class `Obj`.
class Instance extends Obj {
  static Instance parse(Map<String, dynamic> json) =>
      json == null ? null : new Instance._fromJson(json);

  /// What kind of instance is this?
  /*InstanceKind*/ String kind;

  /// The value of this instance as a string.
  ///
  /// Provided for the instance kinds:
  ///  - Bool (true or false)
  ///  - Double (suitable for passing to Double.parse())
  ///  - Int (suitable for passing to int.parse())
  ///  - String (value may be truncated)
  @optional
  String valueAsString;

  /// The valueAsString for String references may be truncated. If so, this
  /// property is added with the value 'true'.
  ///
  /// New code should use 'length' and 'count' instead.
  @optional
  bool valueAsStringIsTruncated;

  /// The length of a List or the number of associations in a Map or the number
  /// of codeunits in a String.
  ///
  /// Provided for instance kinds:
  ///  - String
  ///  - List
  ///  - Map
  ///  - Uint8ClampedList
  ///  - Uint8List
  ///  - Uint16List
  ///  - Uint32List
  ///  - Uint64List
  ///  - Int8List
  ///  - Int16List
  ///  - Int32List
  ///  - Int64List
  ///  - Float32List
  ///  - Float64List
  ///  - Int32x4List
  ///  - Float32x4List
  ///  - Float64x2List
  @optional
  int length;

  /// The index of the first element or association or codeunit returned. This
  /// is only provided when it is non-zero.
  ///
  /// Provided for instance kinds:
  ///  - String
  ///  - List
  ///  - Map
  ///  - Uint8ClampedList
  ///  - Uint8List
  ///  - Uint16List
  ///  - Uint32List
  ///  - Uint64List
  ///  - Int8List
  ///  - Int16List
  ///  - Int32List
  ///  - Int64List
  ///  - Float32List
  ///  - Float64List
  ///  - Int32x4List
  ///  - Float32x4List
  ///  - Float64x2List
  @optional
  int offset;

  /// The number of elements or associations or codeunits returned. This is only
  /// provided when it is less than length.
  ///
  /// Provided for instance kinds:
  ///  - String
  ///  - List
  ///  - Map
  ///  - Uint8ClampedList
  ///  - Uint8List
  ///  - Uint16List
  ///  - Uint32List
  ///  - Uint64List
  ///  - Int8List
  ///  - Int16List
  ///  - Int32List
  ///  - Int64List
  ///  - Float32List
  ///  - Float64List
  ///  - Int32x4List
  ///  - Float32x4List
  ///  - Float64x2List
  @optional
  int count;

  /// The name of a Type instance.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional
  String name;

  /// The corresponding Class if this Type is canonical.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional
  ClassRef typeClass;

  /// The parameterized class of a type parameter:
  ///
  /// Provided for instance kinds:
  ///  - TypeParameter
  @optional
  ClassRef parameterizedClass;

  /// The fields of this Instance.
  @optional
  List<BoundField> fields;

  /// The elements of a List instance.
  ///
  /// Provided for instance kinds:
  ///  - List
  @optional
  List<dynamic> elements;

  /// The elements of a Map instance.
  ///
  /// Provided for instance kinds:
  ///  - Map
  @optional
  List<MapAssociation> associations;

  /// The bytes of a TypedData instance.
  ///
  /// The data is provided as a Base64 encoded string.
  ///
  /// Provided for instance kinds:
  ///  - Uint8ClampedList
  ///  - Uint8List
  ///  - Uint16List
  ///  - Uint32List
  ///  - Uint64List
  ///  - Int8List
  ///  - Int16List
  ///  - Int32List
  ///  - Int64List
  ///  - Float32List
  ///  - Float64List
  ///  - Int32x4List
  ///  - Float32x4List
  ///  - Float64x2List
  @optional
  String bytes;

  /// The function associated with a Closure instance.
  ///
  /// Provided for instance kinds:
  ///  - Closure
  @optional
  FuncRef closureFunction;

  /// The context associated with a Closure instance.
  ///
  /// Provided for instance kinds:
  ///  - Closure
  @optional
  ContextRef closureContext;

  /// The referent of a MirrorReference instance.
  ///
  /// Provided for instance kinds:
  ///  - MirrorReference
  @optional
  InstanceRef mirrorReferent;

  /// The pattern of a RegExp instance.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional
  String pattern;

  /// Whether this regular expression is case sensitive.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional
  bool isCaseSensitive;

  /// Whether this regular expression matches multiple lines.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional
  bool isMultiLine;

  /// The key for a WeakProperty instance.
  ///
  /// Provided for instance kinds:
  ///  - WeakProperty
  @optional
  InstanceRef propertyKey;

  /// The key for a WeakProperty instance.
  ///
  /// Provided for instance kinds:
  ///  - WeakProperty
  @optional
  InstanceRef propertyValue;

  /// The type arguments for this type.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional
  TypeArgumentsRef typeArguments;

  /// The index of a TypeParameter instance.
  ///
  /// Provided for instance kinds:
  ///  - TypeParameter
  @optional
  int parameterIndex;

  /// The type bounded by a BoundedType instance - or - the referent of a
  /// TypeRef instance.
  ///
  /// The value will always be of one of the kinds: Type, TypeRef,
  /// TypeParameter, BoundedType.
  ///
  /// Provided for instance kinds:
  ///  - BoundedType
  ///  - TypeRef
  @optional
  InstanceRef targetType;

  /// The bound of a TypeParameter or BoundedType.
  ///
  /// The value will always be of one of the kinds: Type, TypeRef,
  /// TypeParameter, BoundedType.
  ///
  /// Provided for instance kinds:
  ///  - BoundedType
  ///  - TypeParameter
  @optional
  InstanceRef bound;

  Instance();

  Instance._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    kind = json['kind'];
    valueAsString = json['valueAsString'];
    valueAsStringIsTruncated = json['valueAsStringIsTruncated'] ?? false;
    length = json['length'];
    offset = json['offset'];
    count = json['count'];
    name = json['name'];
    typeClass = _createObject(json['typeClass']);
    parameterizedClass = _createObject(json['parameterizedClass']);
    fields = json['fields'] == null
        ? null
        : new List<BoundField>.from(_createObject(json['fields']));
    elements = json['elements'] == null
        ? null
        : new List<dynamic>.from(_createObject(json['elements']));
    associations = json['associations'] == null
        ? null
        : new List<MapAssociation>.from(
            _createSpecificObject(json['associations'], MapAssociation.parse));
    bytes = json['bytes'];
    closureFunction = _createObject(json['closureFunction']);
    closureContext = _createObject(json['closureContext']);
    mirrorReferent = _createObject(json['mirrorReferent']);
    pattern = json['pattern'];
    isCaseSensitive = json['isCaseSensitive'];
    isMultiLine = json['isMultiLine'];
    propertyKey = _createObject(json['propertyKey']);
    propertyValue = _createObject(json['propertyValue']);
    typeArguments = _createObject(json['typeArguments']);
    parameterIndex = json['parameterIndex'];
    targetType = _createObject(json['targetType']);
    bound = _createObject(json['bound']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Instance && id == other.id;

  String toString() => '[Instance type: ${type}, id: ${id}, kind: ${kind}]';
}

/// `IsolateRef` is a reference to an `Isolate` object.
class IsolateRef extends Response {
  static IsolateRef parse(Map<String, dynamic> json) =>
      json == null ? null : new IsolateRef._fromJson(json);

  /// The id which is passed to the getIsolate RPC to load this isolate.
  String id;

  /// A numeric id for this isolate, represented as a string. Unique.
  String number;

  /// A name identifying this isolate. Not guaranteed to be unique.
  String name;

  IsolateRef();

  IsolateRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is IsolateRef && id == other.id;

  String toString() =>
      '[IsolateRef type: ${type}, id: ${id}, number: ${number}, name: ${name}]';
}

/// An `Isolate` object provides information about one isolate in the VM.
class Isolate extends Response {
  static Isolate parse(Map<String, dynamic> json) =>
      json == null ? null : new Isolate._fromJson(json);

  /// The id which is passed to the getIsolate RPC to reload this isolate.
  String id;

  /// A numeric id for this isolate, represented as a string. Unique.
  String number;

  /// A name identifying this isolate. Not guaranteed to be unique.
  String name;

  /// The time that the VM started in milliseconds since the epoch.
  ///
  /// Suitable to pass to DateTime.fromMillisecondsSinceEpoch.
  int startTime;

  /// Is the isolate in a runnable state?
  bool runnable;

  /// The number of live ports for this isolate.
  int livePorts;

  /// Will this isolate pause when exiting?
  bool pauseOnExit;

  /// The last pause event delivered to the isolate. If the isolate is running,
  /// this will be a resume event.
  Event pauseEvent;

  /// The root library for this isolate.
  ///
  /// Guaranteed to be initialized when the IsolateRunnable event fires.
  @optional
  LibraryRef rootLib;

  /// A list of all libraries for this isolate.
  ///
  /// Guaranteed to be initialized when the IsolateRunnable event fires.
  List<LibraryRef> libraries;

  /// A list of all breakpoints for this isolate.
  List<Breakpoint> breakpoints;

  /// The error that is causing this isolate to exit, if applicable.
  @optional
  Error error;

  /// The current pause on exception mode for this isolate.
  /*ExceptionPauseMode*/ String exceptionPauseMode;

  /// The list of service extension RPCs that are registered for this isolate,
  /// if any.
  @optional
  List<String> extensionRPCs;

  Isolate();

  Isolate._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
    startTime = json['startTime'];
    runnable = json['runnable'];
    livePorts = json['livePorts'];
    pauseOnExit = json['pauseOnExit'];
    pauseEvent = _createObject(json['pauseEvent']);
    rootLib = _createObject(json['rootLib']);
    libraries = new List<LibraryRef>.from(_createObject(json['libraries']));
    breakpoints = new List<Breakpoint>.from(_createObject(json['breakpoints']));
    error = _createObject(json['error']);
    exceptionPauseMode = json['exceptionPauseMode'];
    extensionRPCs = json['extensionRPCs'] == null
        ? null
        : new List<String>.from(json['extensionRPCs']);
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Isolate && id == other.id;

  String toString() => '[Isolate]';
}

/// `LibraryRef` is a reference to a `Library`.
class LibraryRef extends ObjRef {
  static LibraryRef parse(Map<String, dynamic> json) =>
      json == null ? null : new LibraryRef._fromJson(json);

  /// The name of this library.
  String name;

  /// The uri of this library.
  String uri;

  LibraryRef();

  LibraryRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    uri = json['uri'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is LibraryRef && id == other.id;

  String toString() =>
      '[LibraryRef type: ${type}, id: ${id}, name: ${name}, uri: ${uri}]';
}

/// A `Library` provides information about a Dart language library.
///
/// See [setLibraryDebuggable].
class Library extends Obj {
  static Library parse(Map<String, dynamic> json) =>
      json == null ? null : new Library._fromJson(json);

  /// The name of this library.
  String name;

  /// The uri of this library.
  String uri;

  /// Is this library debuggable? Default true.
  bool debuggable;

  /// A list of the imports for this library.
  List<LibraryDependency> dependencies;

  /// A list of the scripts which constitute this library.
  List<ScriptRef> scripts;

  /// A list of the top-level variables in this library.
  List<FieldRef> variables;

  /// A list of the top-level functions in this library.
  List<FuncRef> functions;

  /// A list of all classes in this library.
  List<ClassRef> classes;

  Library();

  Library._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    uri = json['uri'];
    debuggable = json['debuggable'];
    dependencies =
        new List<LibraryDependency>.from(_createObject(json['dependencies']));
    scripts = new List<ScriptRef>.from(_createObject(json['scripts']));
    variables = new List<FieldRef>.from(_createObject(json['variables']));
    functions = new List<FuncRef>.from(_createObject(json['functions']));
    classes = new List<ClassRef>.from(_createObject(json['classes']));
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Library && id == other.id;

  String toString() => '[Library]';
}

/// A `LibraryDependency` provides information about an import or export.
class LibraryDependency {
  static LibraryDependency parse(Map<String, dynamic> json) =>
      json == null ? null : new LibraryDependency._fromJson(json);

  /// Is this dependency an import (rather than an export)?
  bool isImport;

  /// Is this dependency deferred?
  bool isDeferred;

  /// The prefix of an 'as' import, or null.
  String prefix;

  /// The library being imported or exported.
  LibraryRef target;

  LibraryDependency();

  LibraryDependency._fromJson(Map<String, dynamic> json) {
    isImport = json['isImport'];
    isDeferred = json['isDeferred'];
    prefix = json['prefix'];
    target = _createObject(json['target']);
  }

  String toString() => '[LibraryDependency ' //
      'isImport: ${isImport}, isDeferred: ${isDeferred}, prefix: ${prefix}, ' //
      'target: ${target}]';
}

class MapAssociation {
  static MapAssociation parse(Map<String, dynamic> json) =>
      json == null ? null : new MapAssociation._fromJson(json);

  /// [key] can be one of [InstanceRef] or [Sentinel].
  dynamic key;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  MapAssociation();

  MapAssociation._fromJson(Map<String, dynamic> json) {
    key = _createObject(json['key']);
    value = _createObject(json['value']);
  }

  String toString() => '[MapAssociation key: ${key}, value: ${value}]';
}

/// A `Message` provides information about a pending isolate message and the
/// function that will be invoked to handle it.
class Message extends Response {
  static Message parse(Map<String, dynamic> json) =>
      json == null ? null : new Message._fromJson(json);

  /// The index in the isolate's message queue. The 0th message being the next
  /// message to be processed.
  int index;

  /// An advisory name describing this message.
  String name;

  /// An instance id for the decoded message. This id can be passed to other
  /// RPCs, for example, getObject or evaluate.
  String messageObjectId;

  /// The size (bytes) of the encoded message.
  int size;

  /// A reference to the function that will be invoked to handle this message.
  @optional
  FuncRef handler;

  /// The source location of handler.
  @optional
  SourceLocation location;

  Message();

  Message._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    index = json['index'];
    name = json['name'];
    messageObjectId = json['messageObjectId'];
    size = json['size'];
    handler = _createObject(json['handler']);
    location = _createObject(json['location']);
  }

  String toString() => '[Message ' //
      'type: ${type}, index: ${index}, name: ${name}, messageObjectId: ${messageObjectId}, ' //
      'size: ${size}]';
}

/// `NullValRef` is a reference to an a `NullVal`.
class NullValRef extends InstanceRef {
  static NullValRef parse(Map<String, dynamic> json) =>
      json == null ? null : new NullValRef._fromJson(json);

  NullValRef();

  NullValRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {}

  int get hashCode => id.hashCode;

  operator ==(other) => other is NullValRef && id == other.id;

  String toString() => '[NullValRef ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}]';
}

/// A `NullVal` object represents the Dart language value null.
class NullVal extends Instance {
  static NullVal parse(Map<String, dynamic> json) =>
      json == null ? null : new NullVal._fromJson(json);

  NullVal();

  NullVal._fromJson(Map<String, dynamic> json) : super._fromJson(json) {}

  int get hashCode => id.hashCode;

  operator ==(other) => other is NullVal && id == other.id;

  String toString() => '[NullVal type: ${type}, id: ${id}, kind: ${kind}]';
}

/// `ObjRef` is a reference to a `Obj`.
class ObjRef extends Response {
  static ObjRef parse(Map<String, dynamic> json) =>
      json == null ? null : new ObjRef._fromJson(json);

  /// A unique identifier for an Object. Passed to the getObject RPC to load
  /// this Object.
  String id;

  ObjRef();

  ObjRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    id = json['id'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is ObjRef && id == other.id;

  String toString() => '[ObjRef type: ${type}, id: ${id}]';
}

/// An `Obj` is a persistent object that is owned by some isolate.
class Obj extends Response {
  static Obj parse(Map<String, dynamic> json) =>
      json == null ? null : new Obj._fromJson(json);

  /// A unique identifier for an Object. Passed to the getObject RPC to reload
  /// this Object.
  ///
  /// Some objects may get a new id when they are reloaded.
  String id;

  /// If an object is allocated in the Dart heap, it will have a corresponding
  /// class object.
  ///
  /// The class of a non-instance is not a Dart class, but is instead an
  /// internal vm object.
  ///
  /// Moving an Object into or out of the heap is considered a backwards
  /// compatible change for types other than Instance.
  @optional
  ClassRef classRef;

  /// The size of this object in the heap.
  ///
  /// If an object is not heap-allocated, then this field is omitted.
  ///
  /// Note that the size can be zero for some objects. In the current VM
  /// implementation, this occurs for small integers, which are stored entirely
  /// within their object pointers.
  @optional
  int size;

  Obj();

  Obj._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    id = json['id'];
    classRef = _createObject(json['class']);
    size = json['size'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Obj && id == other.id;

  String toString() => '[Obj type: ${type}, id: ${id}]';
}

class ReloadReport extends Response {
  static ReloadReport parse(Map<String, dynamic> json) =>
      json == null ? null : new ReloadReport._fromJson(json);

  /// Did the reload succeed or fail?
  bool success;

  ReloadReport();

  ReloadReport._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    success = json['success'];
  }

  String toString() => '[ReloadReport type: ${type}, success: ${success}]';
}

/// Every non-error response returned by the Service Protocol extends
/// `Response`. By using the `type` property, the client can determine which
/// [type] of response has been provided.
class Response {
  static Response parse(Map<String, dynamic> json) =>
      json == null ? null : new Response._fromJson(json);

  Map<String, dynamic> json;

  /// Every response returned by the VM Service has the type property. This
  /// allows the client distinguish between different kinds of responses.
  String type;

  Response();

  Response._fromJson(this.json) {
    type = json['type'];
  }

  String toString() => '[Response type: ${type}]';
}

/// A `Sentinel` is used to indicate that the normal response is not available.
///
/// We use a `Sentinel` instead of an [error] for these cases because they do
/// not represent a problematic condition. They are normal.
class Sentinel extends Response {
  static Sentinel parse(Map<String, dynamic> json) =>
      json == null ? null : new Sentinel._fromJson(json);

  /// What kind of sentinel is this?
  /*SentinelKind*/ String kind;

  /// A reasonable string representation of this sentinel.
  String valueAsString;

  Sentinel();

  Sentinel._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    kind = json['kind'];
    valueAsString = json['valueAsString'];
  }

  String toString() => '[Sentinel ' //
      'type: ${type}, kind: ${kind}, valueAsString: ${valueAsString}]';
}

/// `ScriptRef` is a reference to a `Script`.
class ScriptRef extends ObjRef {
  static ScriptRef parse(Map<String, dynamic> json) =>
      json == null ? null : new ScriptRef._fromJson(json);

  /// The uri from which this script was loaded.
  String uri;

  ScriptRef();

  ScriptRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    uri = json['uri'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is ScriptRef && id == other.id;

  String toString() => '[ScriptRef type: ${type}, id: ${id}, uri: ${uri}]';
}

/// A `Script` provides information about a Dart language script.
///
/// The `tokenPosTable` is an array of int arrays. Each subarray consists of a
/// line number followed by `(tokenPos, columnNumber)` pairs:
///
/// ```
/// [
/// ```lineNumber, (tokenPos, columnNumber)*]
/// ```
///
/// The `tokenPos` is an arbitrary integer value that is used to represent a
/// location in the source code. A `tokenPos` value is not meaningful in itself
/// and code should not rely on the exact values returned.
///
/// For example, a `tokenPosTable` with the value...
///
/// ```
/// [
/// ```[
/// ```1, 100, 5, 101, 8],[
/// ```2, 102, 7]]
/// ```
///
/// ...encodes the mapping:
///
/// tokenPos | line | column
/// -------- | ---- | ------
/// 100 | 1 | 5
/// 101 | 1 | 8
/// 102 | 2 | 7
class Script extends Obj {
  static Script parse(Map<String, dynamic> json) =>
      json == null ? null : new Script._fromJson(json);

  /// The uri from which this script was loaded.
  String uri;

  /// The library which owns this script.
  LibraryRef library;

  /// The source code for this script. This can be null for certain built-in
  /// scripts.
  @optional
  String source;

  /// A table encoding a mapping from token position to line and column.
  List<List<int>> tokenPosTable;

  Script();

  Script._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    uri = json['uri'];
    library = _createObject(json['library']);
    source = json['source'];
    tokenPosTable = new List<List<int>>.from(
        json['tokenPosTable'].map((dynamic list) => new List<int>.from(list)));
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is Script && id == other.id;

  String toString() => '[Script ' //
      'type: ${type}, id: ${id}, uri: ${uri}, library: ${library}, ' //
      'tokenPosTable: ${tokenPosTable}]';
}

class ScriptList extends Response {
  static ScriptList parse(Map<String, dynamic> json) =>
      json == null ? null : new ScriptList._fromJson(json);

  List<ScriptRef> scripts;

  ScriptList();

  ScriptList._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    scripts = new List<ScriptRef>.from(_createObject(json['scripts']));
  }

  String toString() => '[ScriptList type: ${type}, scripts: ${scripts}]';
}

/// The `SourceLocation` class is used to designate a position or range in some
/// script.
class SourceLocation extends Response {
  static SourceLocation parse(Map<String, dynamic> json) =>
      json == null ? null : new SourceLocation._fromJson(json);

  /// The script containing the source location.
  ScriptRef script;

  /// The first token of the location.
  int tokenPos;

  /// The last token of the location if this is a range.
  @optional
  int endTokenPos;

  SourceLocation();

  SourceLocation._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    script = _createObject(json['script']);
    tokenPos = json['tokenPos'];
    endTokenPos = json['endTokenPos'];
  }

  String toString() =>
      '[SourceLocation type: ${type}, script: ${script}, tokenPos: ${tokenPos}]';
}

/// The `SourceReport` class represents a set of reports tied to source
/// locations in an isolate.
class SourceReport extends Response {
  static SourceReport parse(Map<String, dynamic> json) =>
      json == null ? null : new SourceReport._fromJson(json);

  /// A list of ranges in the program source.  These ranges correspond to ranges
  /// of executable code in the user's program (functions, methods,
  /// constructors, etc.)
  ///
  /// Note that ranges may nest in other ranges, in the case of nested
  /// functions.
  ///
  /// Note that ranges may be duplicated, in the case of mixins.
  List<SourceReportRange> ranges;

  /// A list of scripts, referenced by index in the report's ranges.
  List<ScriptRef> scripts;

  SourceReport();

  SourceReport._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    ranges = new List<SourceReportRange>.from(_createObject(json['ranges']));
    scripts = new List<ScriptRef>.from(_createObject(json['scripts']));
  }

  String toString() =>
      '[SourceReport type: ${type}, ranges: ${ranges}, scripts: ${scripts}]';
}

/// The `SourceReportCoverage` class represents coverage information for one
/// [SourceReportRange].
///
/// Note that `SourceReportCoverage` does not extend [Response] and therefore
/// will not contain a `type` property.
class SourceReportCoverage {
  static SourceReportCoverage parse(Map<String, dynamic> json) =>
      json == null ? null : new SourceReportCoverage._fromJson(json);

  /// A list of token positions in a SourceReportRange which have been executed.
  /// The list is sorted.
  List<int> hits;

  /// A list of token positions in a SourceReportRange which have not been
  /// executed.  The list is sorted.
  List<int> misses;

  SourceReportCoverage();

  SourceReportCoverage._fromJson(Map<String, dynamic> json) {
    hits = new List<int>.from(json['hits']);
    misses = new List<int>.from(json['misses']);
  }

  String toString() =>
      '[SourceReportCoverage hits: ${hits}, misses: ${misses}]';
}

/// The `SourceReportRange` class represents a range of executable code
/// (function, method, constructor, etc) in the running program. It is part of a
/// [SourceReport].
///
/// Note that `SourceReportRange` does not extend [Response] and therefore will
/// not contain a `type` property.
class SourceReportRange {
  static SourceReportRange parse(Map<String, dynamic> json) =>
      json == null ? null : new SourceReportRange._fromJson(json);

  /// An index into the script table of the SourceReport, indicating which
  /// script contains this range of code.
  int scriptIndex;

  /// The token position at which this range begins.
  int startPos;

  /// The token position at which this range ends.  Inclusive.
  int endPos;

  /// Has this range been compiled by the Dart VM?
  bool compiled;

  /// The error while attempting to compile this range, if this report was
  /// generated with forceCompile=true.
  @optional
  ErrorRef error;

  /// Code coverage information for this range.  Provided only when the Coverage
  /// report has been requested and the range has been compiled.
  @optional
  SourceReportCoverage coverage;

  /// Possible breakpoint information for this range, represented as a sorted
  /// list of token positions.  Provided only when the when the
  /// PossibleBreakpoint report has been requested and the range has been
  /// compiled.
  @optional
  List<int> possibleBreakpoints;

  SourceReportRange();

  SourceReportRange._fromJson(Map<String, dynamic> json) {
    scriptIndex = json['scriptIndex'];
    startPos = json['startPos'];
    endPos = json['endPos'];
    compiled = json['compiled'];
    error = _createObject(json['error']);
    coverage = _createObject(json['coverage']);
    possibleBreakpoints = json['possibleBreakpoints'] == null
        ? null
        : new List<int>.from(json['possibleBreakpoints']);
  }

  String toString() => '[SourceReportRange ' //
      'scriptIndex: ${scriptIndex}, startPos: ${startPos}, endPos: ${endPos}, ' //
      'compiled: ${compiled}]';
}

class Stack extends Response {
  static Stack parse(Map<String, dynamic> json) =>
      json == null ? null : new Stack._fromJson(json);

  List<Frame> frames;

  @optional
  List<Frame> asyncCausalFrames;

  @optional
  List<Frame> awaiterFrames;

  List<Message> messages;

  Stack();

  Stack._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    frames = new List<Frame>.from(_createObject(json['frames']));
    asyncCausalFrames = json['asyncCausalFrames'] == null
        ? null
        : new List<Frame>.from(_createObject(json['asyncCausalFrames']));
    awaiterFrames = json['awaiterFrames'] == null
        ? null
        : new List<Frame>.from(_createObject(json['awaiterFrames']));
    messages = new List<Message>.from(_createObject(json['messages']));
  }

  String toString() =>
      '[Stack type: ${type}, frames: ${frames}, messages: ${messages}]';
}

/// The `Success` type is used to indicate that an operation completed
/// successfully.
class Success extends Response {
  static Success parse(Map<String, dynamic> json) =>
      json == null ? null : new Success._fromJson(json);

  Success();

  Success._fromJson(Map<String, dynamic> json) : super._fromJson(json) {}

  String toString() => '[Success type: ${type}]';
}

/// An `TimelineEvent` is an arbitrary map that contains a [Trace Event Format]
/// event.
class TimelineEvent {
  static TimelineEvent parse(Map<String, dynamic> json) =>
      json == null ? null : new TimelineEvent._fromJson(json);

  TimelineEvent();

  TimelineEvent._fromJson(Map<String, dynamic> json) {}

  String toString() => '[TimelineEvent ]';
}

/// `TypeArgumentsRef` is a reference to a `TypeArguments` object.
class TypeArgumentsRef extends ObjRef {
  static TypeArgumentsRef parse(Map<String, dynamic> json) =>
      json == null ? null : new TypeArgumentsRef._fromJson(json);

  /// A name for this type argument list.
  String name;

  TypeArgumentsRef();

  TypeArgumentsRef._fromJson(Map<String, dynamic> json)
      : super._fromJson(json) {
    name = json['name'];
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is TypeArgumentsRef && id == other.id;

  String toString() =>
      '[TypeArgumentsRef type: ${type}, id: ${id}, name: ${name}]';
}

/// A `TypeArguments` object represents the type argument vector for some
/// instantiated generic type.
class TypeArguments extends Obj {
  static TypeArguments parse(Map<String, dynamic> json) =>
      json == null ? null : new TypeArguments._fromJson(json);

  /// A name for this type argument list.
  String name;

  /// A list of types.
  ///
  /// The value will always be one of the kinds: Type, TypeRef, TypeParameter,
  /// BoundedType.
  List<InstanceRef> types;

  TypeArguments();

  TypeArguments._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
    types = new List<InstanceRef>.from(_createObject(json['types']));
  }

  int get hashCode => id.hashCode;

  operator ==(other) => other is TypeArguments && id == other.id;

  String toString() =>
      '[TypeArguments type: ${type}, id: ${id}, name: ${name}, types: ${types}]';
}

/// The `UnresolvedSourceLocation` class is used to refer to an unresolved
/// breakpoint location. As such, it is meant to approximate the final location
/// of the breakpoint but it is not exact.
///
/// Either the `script` or the `scriptUri` field will be present.
///
/// Either the `tokenPos` or the `line` field will be present.
///
/// The `column` field will only be present when the breakpoint was specified
/// with a specific column number.
class UnresolvedSourceLocation extends Response {
  static UnresolvedSourceLocation parse(Map<String, dynamic> json) =>
      json == null ? null : new UnresolvedSourceLocation._fromJson(json);

  /// The script containing the source location if the script has been loaded.
  @optional
  ScriptRef script;

  /// The uri of the script containing the source location if the script has yet
  /// to be loaded.
  @optional
  String scriptUri;

  /// An approximate token position for the source location. This may change
  /// when the location is resolved.
  @optional
  int tokenPos;

  /// An approximate line number for the source location. This may change when
  /// the location is resolved.
  @optional
  int line;

  /// An approximate column number for the source location. This may change when
  /// the location is resolved.
  @optional
  int column;

  UnresolvedSourceLocation();

  UnresolvedSourceLocation._fromJson(Map<String, dynamic> json)
      : super._fromJson(json) {
    script = _createObject(json['script']);
    scriptUri = json['scriptUri'];
    tokenPos = json['tokenPos'];
    line = json['line'];
    column = json['column'];
  }

  String toString() => '[UnresolvedSourceLocation type: ${type}]';
}

/// See [Versioning].
class Version extends Response {
  static Version parse(Map<String, dynamic> json) =>
      json == null ? null : new Version._fromJson(json);

  /// The major version number is incremented when the protocol is changed in a
  /// potentially incompatible way.
  int major;

  /// The minor version number is incremented when the protocol is changed in a
  /// backwards compatible way.
  int minor;

  Version();

  Version._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    major = json['major'];
    minor = json['minor'];
  }

  String toString() =>
      '[Version type: ${type}, major: ${major}, minor: ${minor}]';
}

/// `VMRef` is a reference to a `VM` object.
class VMRef extends Response {
  static VMRef parse(Map<String, dynamic> json) =>
      json == null ? null : new VMRef._fromJson(json);

  /// A name identifying this vm. Not guaranteed to be unique.
  String name;

  VMRef();

  VMRef._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    name = json['name'];
  }

  String toString() => '[VMRef type: ${type}, name: ${name}]';
}

class VM extends Response {
  static VM parse(Map<String, dynamic> json) =>
      json == null ? null : new VM._fromJson(json);

  /// Word length on target architecture (e.g. 32, 64).
  int architectureBits;

  /// The CPU we are generating code for.
  String targetCPU;

  /// The CPU we are actually running on.
  String hostCPU;

  /// The Dart VM version string.
  String version;

  /// The process id for the VM.
  int pid;

  /// The time that the VM started in milliseconds since the epoch.
  ///
  /// Suitable to pass to DateTime.fromMillisecondsSinceEpoch.
  int startTime;

  /// A list of isolates running in the VM.
  List<IsolateRef> isolates;

  VM();

  VM._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    architectureBits = json['architectureBits'];
    targetCPU = json['targetCPU'];
    hostCPU = json['hostCPU'];
    version = json['version'];
    pid = json['pid'];
    startTime = json['startTime'];
    isolates = new List<IsolateRef>.from(_createObject(json['isolates']));
  }

  String toString() => '[VM]';
}

@undocumented
class CpuProfile extends Response {
  static CpuProfile parse(Map<String, dynamic> json) =>
      json == null ? null : new CpuProfile._fromJson(json);

  int sampleCount;

  int samplePeriod;

  int stackDepth;

  double timeSpan;

  int timeOriginMicros;

  int timeExtentMicros;

  List<CodeRegion> codes;

  List<ProfileFunction> functions;

  List<int> exclusiveCodeTrie;

  List<int> inclusiveCodeTrie;

  List<int> exclusiveFunctionTrie;

  List<int> inclusiveFunctionTrie;

  CpuProfile();

  CpuProfile._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    sampleCount = json['sampleCount'];
    samplePeriod = json['samplePeriod'];
    stackDepth = json['stackDepth'];
    timeSpan = json['timeSpan'];
    timeOriginMicros = json['timeOriginMicros'];
    timeExtentMicros = json['timeExtentMicros'];
    codes = new List<CodeRegion>.from(
        _createSpecificObject(json['codes'], CodeRegion.parse));
    functions = new List<ProfileFunction>.from(
        _createSpecificObject(json['functions'], ProfileFunction.parse));
    exclusiveCodeTrie = new List<int>.from(json['exclusiveCodeTrie']);
    inclusiveCodeTrie = new List<int>.from(json['inclusiveCodeTrie']);
    exclusiveFunctionTrie = new List<int>.from(json['exclusiveFunctionTrie']);
    inclusiveFunctionTrie = new List<int>.from(json['inclusiveFunctionTrie']);
  }

  String toString() => '[_CpuProfile]';
}

class CodeRegion {
  static CodeRegion parse(Map<String, dynamic> json) =>
      json == null ? null : new CodeRegion._fromJson(json);

  String kind;

  int inclusiveTicks;

  int exclusiveTicks;

  CodeRef code;

  CodeRegion();

  CodeRegion._fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    inclusiveTicks = json['inclusiveTicks'];
    exclusiveTicks = json['exclusiveTicks'];
    code = _createObject(json['code']);
  }

  String toString() => '[CodeRegion ' //
      'kind: ${kind}, inclusiveTicks: ${inclusiveTicks}, exclusiveTicks: ${exclusiveTicks}, ' //
      'code: ${code}]';
}

class ProfileFunction {
  static ProfileFunction parse(Map<String, dynamic> json) =>
      json == null ? null : new ProfileFunction._fromJson(json);

  String kind;

  int inclusiveTicks;

  int exclusiveTicks;

  FuncRef function;

  List<int> codes;

  ProfileFunction();

  ProfileFunction._fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    inclusiveTicks = json['inclusiveTicks'];
    exclusiveTicks = json['exclusiveTicks'];
    function = _createObject(json['function']);
    codes = new List<int>.from(json['codes']);
  }

  String toString() => '[ProfileFunction ' //
      'kind: ${kind}, inclusiveTicks: ${inclusiveTicks}, exclusiveTicks: ${exclusiveTicks}, ' //
      'function: ${function}, codes: ${codes}]';
}

class AllocationProfile extends Response {
  static AllocationProfile parse(Map<String, dynamic> json) =>
      json == null ? null : new AllocationProfile._fromJson(json);

  String dateLastServiceGC;

  List<ClassHeapStats> members;

  AllocationProfile();

  AllocationProfile._fromJson(Map<String, dynamic> json)
      : super._fromJson(json) {
    dateLastServiceGC = json['dateLastServiceGC'];
    members = new List<ClassHeapStats>.from(_createObject(json['members']));
  }

  String toString() => '[AllocationProfile ' //
      'type: ${type}, dateLastServiceGC: ${dateLastServiceGC}, members: ${members}]';
}

class ClassHeapStats extends Response {
  static ClassHeapStats parse(Map<String, dynamic> json) =>
      json == null ? null : new ClassHeapStats._fromJson(json);

  ClassRef classRef;

  List<int> new_;

  List<int> old;

  int promotedBytes;

  int promotedInstances;

  ClassHeapStats();

  ClassHeapStats._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    classRef = _createObject(json['class']);
    new_ = new List<int>.from(json['new']);
    old = new List<int>.from(json['old']);
    promotedBytes = json['promotedBytes'];
    promotedInstances = json['promotedInstances'];
  }

  String toString() => '[ClassHeapStats ' //
      'type: ${type}, classRef: ${classRef}, new_: ${new_}, old: ${old}, ' //
      'promotedBytes: ${promotedBytes}, promotedInstances: ${promotedInstances}]';
}

class HeapSpace extends Response {
  static HeapSpace parse(Map<String, dynamic> json) =>
      json == null ? null : new HeapSpace._fromJson(json);

  double avgCollectionPeriodMillis;

  int capacity;

  int collections;

  int external;

  String name;

  double time;

  int used;

  HeapSpace();

  HeapSpace._fromJson(Map<String, dynamic> json) : super._fromJson(json) {
    avgCollectionPeriodMillis = json['avgCollectionPeriodMillis'];
    capacity = json['capacity'];
    collections = json['collections'];
    external = json['external'];
    name = json['name'];
    time = json['time'];
    used = json['used'];
  }

  String toString() => '[HeapSpace]';
}
