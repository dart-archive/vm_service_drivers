// This is a generated file.

/// A library to access the VM Service API.
///
/// The main entry-point for this library is the [VmService] class.
library vm_service_lib;

import 'dart:async';
import 'dart:convert' show BASE64, JSON, JsonCodec;

const String vmServiceVersion = '3.0.0';

/// @optional
const String optional = 'optional';

/// Decode a string in Base64 encoding into the equivalent non-encoded string.
/// This is useful for handling the results of the Stdout or Stderr events.
String decodeBase64(String str) => new String.fromCharCodes(BASE64.decode(str));

Object _createObject(dynamic json) {
  if (json == null) return null;

  if (json is List) {
    return (json as List).map((e) => _createObject(e)).toList();
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

String _printEnum(Object obj) {
  if (obj == null) return null;
  String str = obj.toString();
  int index = str.indexOf('.');
  return str.substring(index + 1);
}

Map<String, Function> _typeFactories = {
  'BoundField': BoundField._parse,
  'BoundVariable': BoundVariable._parse,
  'Breakpoint': Breakpoint._parse,
  '@Class': ClassRef._parse,
  'Class': Class._parse,
  'ClassList': ClassList._parse,
  '@Code': CodeRef._parse,
  'Code': Code._parse,
  '@Context': ContextRef._parse,
  'Context': Context._parse,
  'ContextElement': ContextElement._parse,
  '@Error': ErrorRef._parse,
  'Error': Error._parse,
  'Event': Event._parse,
  '@Field': FieldRef._parse,
  'Field': Field._parse,
  'Flag': Flag._parse,
  'FlagList': FlagList._parse,
  'Frame': Frame._parse,
  '@Function': FuncRef._parse,
  'Function': Func._parse,
  '@Instance': InstanceRef._parse,
  'Instance': Instance._parse,
  '@Isolate': IsolateRef._parse,
  'Isolate': Isolate._parse,
  '@Library': LibraryRef._parse,
  'Library': Library._parse,
  'LibraryDependency': LibraryDependency._parse,
  'MapAssociation': MapAssociation._parse,
  'Message': Message._parse,
  '@Null': NullRef._parse,
  'Null': Null._parse,
  '@Object': ObjRef._parse,
  'Object': Obj._parse,
  'Response': Response._parse,
  'Sentinel': Sentinel._parse,
  '@Script': ScriptRef._parse,
  'Script': Script._parse,
  'SourceLocation': SourceLocation._parse,
  'Stack': Stack._parse,
  'Success': Success._parse,
  '@TypeArguments': TypeArgumentsRef._parse,
  'TypeArguments': TypeArguments._parse,
  'UnresolvedSourceLocation': UnresolvedSourceLocation._parse,
  'Version': Version._parse,
  '@VM': VMRef._parse,
  'VM': VM._parse
};

class VmService {
  StreamSubscription _streamSub;
  Function _writeMessage;
  int _id = 0;
  Map<String, Completer> _completers = {};
  Log _log;

  StreamController _onSend = new StreamController.broadcast();
  StreamController _onReceive = new StreamController.broadcast();

  StreamController<Event> _vmController = new StreamController.broadcast();
  StreamController<Event> _isolateController = new StreamController.broadcast();
  StreamController<Event> _debugController = new StreamController.broadcast();
  StreamController<Event> _gcController = new StreamController.broadcast();
  StreamController<Event> _stdoutController = new StreamController.broadcast();
  StreamController<Event> _stderrController = new StreamController.broadcast();

  VmService(Stream<String> inStream, void writeMessage(String message),
      {Log log}) {
    _streamSub = inStream.listen(_processMessage);
    _writeMessage = writeMessage;
    _log = log == null ? new _NullLog() : log;
  }

  // VMUpdate
  Stream<Event> get onVMEvent => _vmController.stream;
  // IsolateStart, IsolateRunnable, IsolateExit, IsolateUpdate
  Stream<Event> get onIsolateEvent => _isolateController.stream;
  // PauseStart, PauseExit, PauseBreakpoint, PauseInterrupted, PauseException,
  // Resume, BreakpointAdded, BreakpointResolved, BreakpointRemoved, Inspect
  Stream<Event> get onDebugEvent => _debugController.stream;
  // GC
  Stream<Event> get onGCEvent => _gcController.stream;
  // WriteEvent
  Stream<Event> get onStdoutEvent => _stdoutController.stream;
  // WriteEvent
  Stream<Event> get onStderrEvent => _stderrController.stream;

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
    return _call('addBreakpoint', m) as Future<Breakpoint>;
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
  /// If an error occurs while evaluating the expression, an [ErrorRef]
  /// reference will be returned.
  ///
  /// If the expression is evaluated successfully, an [InstanceRef] reference
  /// will be returned.
  ///
  /// The return value can be one of [InstanceRef], [ErrorRef] or [Sentinel].
  Future<dynamic> evaluate(
      String isolateId, String targetId, String expression) {
    return _call('evaluate', {
      'isolateId': isolateId,
      'targetId': targetId,
      'expression': expression
    });
  }

  /// The `evaluateInFrame` RPC is used to evaluate an expression in the context
  /// of a particular stack frame. `frameIndex` is the index of the desired
  /// [Frame], with an index of `0` indicating the top (most recent) frame.
  ///
  /// If an error occurs while evaluating the expression, an [ErrorRef]
  /// reference will be returned.
  ///
  /// If the expression is evaluated successfully, an [InstanceRef] reference
  /// will be returned.
  ///
  /// The return value can be one of [InstanceRef] or [ErrorRef].
  Future<dynamic> evaluateInFrame(
      String isolateId, int frameIndex, String expression) {
    return _call('evaluateInFrame', {
      'isolateId': isolateId,
      'frameIndex': frameIndex,
      'expression': expression
    });
  }

  /// The _getFlagList RPC returns a list of all command line flags in the VM
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
  /// Instance objects with the kinds: List, Map, Uint8ClampedList, Uint8List,
  /// Uint16List, Uint32List, Uint64List, Int8List, Int16List, Int32List,
  /// Int64List, Flooat32List, Float64List, Inst32x3List, Float32x4List, and
  /// Float64x2List. These parameters are otherwise ignored.
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
  ///
  /// See [Success], [StepOption].
  Future<Success> resume(String isolateId, {StepOption step}) {
    Map m = {'isolateId': isolateId};
    if (step != null) m['step'] = _printEnum(step);
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
      String isolateId, ExceptionPauseMode mode) {
    return _call('setExceptionPauseMode',
        {'isolateId': isolateId, 'mode': _printEnum(mode)});
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
  /// Isolate | IsolateStart, IsolateRunnable, IsolateExit, IsolateUpdate
  /// Debug | PauseStart, PauseExit, PauseBreakpoint, PauseInterrupted,
  /// PauseException, Resume, BreakpointAdded, BreakpointResolved,
  /// BreakpointRemoved, Inspect
  /// GC | GC
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

  Stream<String> get onSend => _onSend.stream;

  Stream<String> get onReceive => _onReceive.stream;

  void dispose() {
    _streamSub.cancel();
    _completers.values.forEach((c) => c.completeError('disposed'));
  }

  Future<Response> _call(String method, [Map args = const {}]) {
    String id = '${++_id}';
    _completers[id] = new Completer();
    // The service protocol needs 'params' to be there.
    Map m = {'id': id, 'method': method, 'params': args};
    if (args != null) m['params'] = args;
    String message = JSON.encode(m);
    _onSend.add(message);
    _writeMessage(message);
    return _completers[id].future;
  }

  void _processMessage(String message) {
    try {
      _onReceive.add(message);

      var json = JSON.decode(message);

      if (json['id'] == null && json['method'] == 'streamNotify') {
        Map params = json['params'];
        String streamId = params['streamId'];

        // TODO: These could be generated from a list.
        if (streamId == 'VM') {
          _vmController.add(_createObject(params['event']));
        } else if (streamId == 'Isolate') {
          _isolateController.add(_createObject(params['event']));
        } else if (streamId == 'Debug') {
          _debugController.add(_createObject(params['event']));
        } else if (streamId == 'GC') {
          _gcController.add(_createObject(params['event']));
        } else if (streamId == 'Stdout') {
          _stdoutController.add(_createObject(params['event']));
        } else if (streamId == 'Stderr') {
          _stderrController.add(_createObject(params['event']));
        } else {
          _log.warning('unknown streamId: ${streamId}');
        }
      } else if (json['id'] != null) {
        Completer completer = _completers.remove(json['id']);

        if (completer == null) {
          _log.severe('unmatched request response: ${message}');
        } else if (json['error'] != null) {
          completer.completeError(RPCError.parse(json['error']));
        } else {
          var result = json['result'];
          String type = result['type'];
          if (_typeFactories[type] == null) {
            completer.completeError(
                new RPCError(0, 'unknown response type ${type}'));
          } else {
            completer.complete(_createObject(result));
          }
        }
      } else {
        _log.severe('unknown message type: ${message}');
      }
    } catch (e, s) {
      _log.severe('unable to decode message: ${message}, ${e}\n${s}');
    }
  }
}

class RPCError {
  static RPCError parse(dynamic json) {
    return new RPCError(json['code'], json['message'], json['data']);
  }

  final int code;
  final String message;
  final Map data;

  RPCError(this.code, this.message, [this.data]);

  String toString() => '${code}: ${message}';
}

/// A logging handler you can pass to a [VmService] instance in order to get
/// notifications of non-fatal service protcol warnings and errors.
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

enum CodeKind { Dart, Native, Stub, Tag, Collected }

Map<String, CodeKind> _parseCodeKind = {
  'Dart': CodeKind.Dart,
  'Native': CodeKind.Native,
  'Stub': CodeKind.Stub,
  'Tag': CodeKind.Tag,
  'Collected': CodeKind.Collected
};

enum ErrorKind {
  /// The isolate has encountered an unhandled Dart exception.
  UnhandledException,

  /// The isolate has encountered a Dart language error in the program.
  LanguageError,

  /// The isolate has encounted an internal error. These errors should be
  /// reported as bugs.
  InternalError,

  /// The isolate has been terminated by an external source.
  TerminationError
}

Map<String, ErrorKind> _parseErrorKind = {
  'UnhandledException': ErrorKind.UnhandledException,
  'LanguageError': ErrorKind.LanguageError,
  'InternalError': ErrorKind.InternalError,
  'TerminationError': ErrorKind.TerminationError
};

/// Adding new values to `EventKind` is considered a backwards compatible
/// change. Clients should ignore unrecognized events.
enum EventKind {
  /// Notification that VM identifying information has changed. Currently used
  /// to notify of changes to the VM debugging name via setVMName.
  VMUpdate,

  /// Notification that a new isolate has started.
  IsolateStart,

  /// Notification that an isolate is ready to run.
  IsolateRunnable,

  /// Notification that an isolate has exited.
  IsolateExit,

  /// Notification that isolate identifying information has changed. Currently
  /// used to notify of changes to the isolate debugging name via setName.
  IsolateUpdate,

  /// An isolate has paused at start, before executing code.
  PauseStart,

  /// An isolate has paused at exit, before terminating.
  PauseExit,

  /// An isolate has paused at a breakpoint or due to stepping.
  PauseBreakpoint,

  /// An isolate has paused due to interruption via pause.
  PauseInterrupted,

  /// An isolate has paused due to an exception.
  PauseException,

  /// An isolate has started or resumed execution.
  Resume,

  /// A breakpoint has been added for an isolate.
  BreakpointAdded,

  /// An unresolved breakpoint has been resolved for an isolate.
  BreakpointResolved,

  /// A breakpoint has been removed.
  BreakpointRemoved,

  /// A garbage collection event.
  GC,

  /// Notification of bytes written, for example, to stdout/stderr.
  WriteEvent
}

Map<String, EventKind> _parseEventKind = {
  'VMUpdate': EventKind.VMUpdate,
  'IsolateStart': EventKind.IsolateStart,
  'IsolateRunnable': EventKind.IsolateRunnable,
  'IsolateExit': EventKind.IsolateExit,
  'IsolateUpdate': EventKind.IsolateUpdate,
  'PauseStart': EventKind.PauseStart,
  'PauseExit': EventKind.PauseExit,
  'PauseBreakpoint': EventKind.PauseBreakpoint,
  'PauseInterrupted': EventKind.PauseInterrupted,
  'PauseException': EventKind.PauseException,
  'Resume': EventKind.Resume,
  'BreakpointAdded': EventKind.BreakpointAdded,
  'BreakpointResolved': EventKind.BreakpointResolved,
  'BreakpointRemoved': EventKind.BreakpointRemoved,
  'GC': EventKind.GC,
  'WriteEvent': EventKind.WriteEvent
};

/// Adding new values to `InstanceKind` is considered a backwards compatible
/// change. Clients should treat unrecognized instance kinds as `PlainInstance`.
enum InstanceKind {
  /// A general instance of the Dart class Object.
  PlainInstance,

  /// null instance.
  Null,

  /// true or false.
  Bool,

  /// An instance of the Dart class double.
  Double,

  /// An instance of the Dart class int.
  Int,

  /// An instance of the Dart class String.
  String,

  /// An instance of the built-in VM List implementation. User-defined Lists
  /// will be PlainInstance.
  List,

  /// An instance of the built-in VM Map implementation. User-defined Maps will
  /// be PlainInstance.
  Map,

  /// Vector instance kinds.
  Float32x4,
  Float64x2,
  Int32x4,

  /// An instance of the built-in VM TypedData implementations. User-defined
  /// TypedDatas will be PlainInstance.
  Uint8ClampedList,
  Uint8List,
  Uint16List,
  Uint32List,
  Uint64List,
  Int8List,
  Int16List,
  Int32List,
  Int64List,
  Float32List,
  Float64List,
  Int32x4List,
  Float32x4List,
  Float64x2List,

  /// An instance of the Dart class StackTrace.
  StackTrace,

  /// An instance of the built-in VM Closure implementation. User-defined
  /// Closures will be PlainInstance.
  Closure,

  /// An instance of the Dart class MirrorReference.
  MirrorReference,

  /// An instance of the Dart class RegExp.
  RegExp,

  /// An instance of the Dart class WeakProperty.
  WeakProperty,

  /// An instance of the Dart class Type.
  Type,

  /// An instance of the Dart class TypeParameter.
  TypeParameter,

  /// An instance of the Dart class TypeRef.
  TypeRef,

  /// An instance of the Dart class BoundedType.
  BoundedType
}

Map<String, InstanceKind> _parseInstanceKind = {
  'PlainInstance': InstanceKind.PlainInstance,
  'Null': InstanceKind.Null,
  'Bool': InstanceKind.Bool,
  'Double': InstanceKind.Double,
  'Int': InstanceKind.Int,
  'String': InstanceKind.String,
  'List': InstanceKind.List,
  'Map': InstanceKind.Map,
  'Float32x4': InstanceKind.Float32x4,
  'Float64x2': InstanceKind.Float64x2,
  'Int32x4': InstanceKind.Int32x4,
  'Uint8ClampedList': InstanceKind.Uint8ClampedList,
  'Uint8List': InstanceKind.Uint8List,
  'Uint16List': InstanceKind.Uint16List,
  'Uint32List': InstanceKind.Uint32List,
  'Uint64List': InstanceKind.Uint64List,
  'Int8List': InstanceKind.Int8List,
  'Int16List': InstanceKind.Int16List,
  'Int32List': InstanceKind.Int32List,
  'Int64List': InstanceKind.Int64List,
  'Float32List': InstanceKind.Float32List,
  'Float64List': InstanceKind.Float64List,
  'Int32x4List': InstanceKind.Int32x4List,
  'Float32x4List': InstanceKind.Float32x4List,
  'Float64x2List': InstanceKind.Float64x2List,
  'StackTrace': InstanceKind.StackTrace,
  'Closure': InstanceKind.Closure,
  'MirrorReference': InstanceKind.MirrorReference,
  'RegExp': InstanceKind.RegExp,
  'WeakProperty': InstanceKind.WeakProperty,
  'Type': InstanceKind.Type,
  'TypeParameter': InstanceKind.TypeParameter,
  'TypeRef': InstanceKind.TypeRef,
  'BoundedType': InstanceKind.BoundedType
};

/// A `SentinelKind` is used to distinguish different kinds of `Sentinel`
/// objects.
///
/// Adding new values to `SentinelKind` is considered a backwards compatible
/// change. Clients must handle this gracefully.
enum SentinelKind {
  /// Indicates that the object referred to has been collected by the GC.
  Collected,

  /// Indicates that an object id has expired.
  Expired,

  /// Indicates that a variable or field has not been initialized.
  NotInitialized,

  /// Indicates that a variable or field is in the process of being initialized.
  BeingInitialized,

  /// Indicates that a variable has been eliminated by the optimizing compiler.
  OptimizedOut,

  /// Reserved for future use.
  Free
}

Map<String, SentinelKind> _parseSentinelKind = {
  'Collected': SentinelKind.Collected,
  'Expired': SentinelKind.Expired,
  'NotInitialized': SentinelKind.NotInitialized,
  'BeingInitialized': SentinelKind.BeingInitialized,
  'OptimizedOut': SentinelKind.OptimizedOut,
  'Free': SentinelKind.Free
};

/// An `ExceptionPauseMode` indicates how the isolate pauses when an exception
/// is thrown.
enum ExceptionPauseMode { None, Unhandled, All }

Map<String, ExceptionPauseMode> _parseExceptionPauseMode = {
  'None': ExceptionPauseMode.None,
  'Unhandled': ExceptionPauseMode.Unhandled,
  'All': ExceptionPauseMode.All
};

/// A `StepOption` indicates which form of stepping is requested in a [resume]
/// RPC.
enum StepOption { Into, Over, Out }

Map<String, StepOption> _parseStepOption = {
  'Into': StepOption.Into,
  'Over': StepOption.Over,
  'Out': StepOption.Out
};

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
  static BoundField _parse(Map json) => new BoundField._fromJson(json);

  BoundField();
  BoundField._fromJson(Map json) {
    decl = _createObject(json['decl']);
    value = _createObject(json['value']);
  }

  FieldRef decl;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

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
  static BoundVariable _parse(Map json) => new BoundVariable._fromJson(json);

  BoundVariable();
  BoundVariable._fromJson(Map json) {
    name = json['name'];
    value = _createObject(json['value']);
  }

  String name;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[BoundVariable name: ${name}, value: ${value}]';
}

/// A `Breakpoint` describes a debugger breakpoint.
///
/// A breakpoint is `resolved` when it has been assigned to a specific program
/// location. A breakpoint my remain unresolved when it is in code which has not
/// yet been compiled or in a library which has not been loaded (i.e. a deferred
/// library).
class Breakpoint extends Obj {
  static Breakpoint _parse(Map json) => new Breakpoint._fromJson(json);

  Breakpoint();
  Breakpoint._fromJson(Map json) : super._fromJson(json) {
    breakpointNumber = json['breakpointNumber'];
    resolved = json['resolved'];
    location = _createObject(json['location']);
  }

  /// A number identifying this breakpoint to the user.
  int breakpointNumber;

  /// Has this breakpoint been assigned to a specific program location?
  bool resolved;

  /// SourceLocation when breakpoint is resolved, UnresolvedSourceLocation when
  /// a breakpoint is not resolved.
  ///
  /// [location] can be one of [SourceLocation] or [UnresolvedSourceLocation].
  dynamic location;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Breakpoint && id == other.id;

  String toString() => '[Breakpoint ' //
      'type: ${type}, id: ${id}, breakpointNumber: ${breakpointNumber}, ' //
      'resolved: ${resolved}, location: ${location}]';
}

/// `ClassRef` is a reference to a `Class`.
class ClassRef extends ObjRef {
  static ClassRef _parse(Map json) => new ClassRef._fromJson(json);

  ClassRef();
  ClassRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
  }

  /// The name of this class.
  String name;

  int get hashCode => id.hashCode;

  operator ==(other) => other is ClassRef && id == other.id;

  String toString() => '[ClassRef type: ${type}, id: ${id}, name: ${name}]';
}

/// A `Class` provides information about a Dart language class.
class Class extends Obj {
  static Class _parse(Map json) => new Class._fromJson(json);

  Class();
  Class._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    error = _createObject(json['error']);
    isAbstract = json['abstract'];
    isConst = json['const'];
    library = _createObject(json['library']);
    location = _createObject(json['location']);
    superClass = _createObject(json['super']);
    interfaces = _createObject(json['interfaces']);
    fields = _createObject(json['fields']);
    functions = _createObject(json['functions']);
    subclasses = _createObject(json['subclasses']);
  }

  /// The name of this class.
  String name;

  /// The error which occurred during class finalization, if it exists.
  @optional ErrorRef error;

  /// Is this an abstract class?
  bool isAbstract;

  /// Is this a const class?
  bool isConst;

  /// The library which contains this class.
  LibraryRef library;

  /// The location of this class in the source code.
  @optional SourceLocation location;

  /// The superclass of this class, if any.
  @optional ClassRef superClass;

  /// A list of interface types for this class.
  ///
  /// The value will be of the kind: Type.
  List<InstanceRef> interfaces;

  /// A list of fields in this class. Does not include fields from superclasses.
  List<FieldRef> fields;

  /// A list of functions in this class. Does not include functions from
  /// superclasses.
  List<FuncRef> functions;

  /// A list of subclasses of this class.
  List<ClassRef> subclasses;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Class && id == other.id;

  String toString() => '[Class]';
}

class ClassList extends Response {
  static ClassList _parse(Map json) => new ClassList._fromJson(json);

  ClassList();
  ClassList._fromJson(Map json) : super._fromJson(json) {
    classes = _createObject(json['classes']);
  }

  List<ClassRef> classes;

  String toString() => '[ClassList type: ${type}, classes: ${classes}]';
}

/// `CodeRef` is a reference to a `Code` object.
class CodeRef extends ObjRef {
  static CodeRef _parse(Map json) => new CodeRef._fromJson(json);

  CodeRef();
  CodeRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    kind = _parseCodeKind[json['kind']];
  }

  /// A name for this code object.
  String name;

  /// What kind of code object is this?
  CodeKind kind;

  int get hashCode => id.hashCode;

  operator ==(other) => other is CodeRef && id == other.id;

  String toString() =>
      '[CodeRef type: ${type}, id: ${id}, name: ${name}, kind: ${kind}]';
}

/// A `Code` object represents compiled code in the Dart VM.
class Code extends ObjRef {
  static Code _parse(Map json) => new Code._fromJson(json);

  Code();
  Code._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    kind = _parseCodeKind[json['kind']];
  }

  /// A name for this code object.
  String name;

  /// What kind of code object is this?
  CodeKind kind;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Code && id == other.id;

  String toString() =>
      '[Code type: ${type}, id: ${id}, name: ${name}, kind: ${kind}]';
}

class ContextRef extends ObjRef {
  static ContextRef _parse(Map json) => new ContextRef._fromJson(json);

  ContextRef();
  ContextRef._fromJson(Map json) : super._fromJson(json) {
    length = json['length'];
  }

  /// The number of variables in this context.
  int length;

  int get hashCode => id.hashCode;

  operator ==(other) => other is ContextRef && id == other.id;

  String toString() =>
      '[ContextRef type: ${type}, id: ${id}, length: ${length}]';
}

/// A `Context` is a data structure which holds the captured variables for some
/// closure.
class Context extends Obj {
  static Context _parse(Map json) => new Context._fromJson(json);

  Context();
  Context._fromJson(Map json) : super._fromJson(json) {
    length = json['length'];
    parent = _createObject(json['parent']);
    variables = _createObject(json['variables']);
  }

  /// The number of variables in this context.
  int length;

  /// The enclosing context for this context.
  @optional Context parent;

  /// The variables in this context object.
  List<ContextElement> variables;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Context && id == other.id;

  String toString() => '[Context ' //
      'type: ${type}, id: ${id}, length: ${length}, variables: ${variables}]';
}

class ContextElement {
  static ContextElement _parse(Map json) => new ContextElement._fromJson(json);

  ContextElement();
  ContextElement._fromJson(Map json) {
    value = _createObject(json['value']);
  }

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[ContextElement value: ${value}]';
}

/// `ErrorRef` is a reference to an `Error`.
class ErrorRef extends ObjRef {
  static ErrorRef _parse(Map json) => new ErrorRef._fromJson(json);

  ErrorRef();
  ErrorRef._fromJson(Map json) : super._fromJson(json) {
    kind = _parseErrorKind[json['kind']];
    message = json['message'];
  }

  /// What kind of error is this?
  ErrorKind kind;

  /// A description of the error.
  String message;

  int get hashCode => id.hashCode;

  operator ==(other) => other is ErrorRef && id == other.id;

  String toString() =>
      '[ErrorRef type: ${type}, id: ${id}, kind: ${kind}, message: ${message}]';
}

/// An `Error` represents a Dart language level error. This is distinct from an
/// [rpc error].
class Error extends Obj {
  static Error _parse(Map json) => new Error._fromJson(json);

  Error();
  Error._fromJson(Map json) : super._fromJson(json) {
    kind = _parseErrorKind[json['kind']];
    message = json['message'];
    exception = _createObject(json['exception']);
    stacktrace = _createObject(json['stacktrace']);
  }

  /// What kind of error is this?
  ErrorKind kind;

  /// A description of the error.
  String message;

  /// If this error is due to an unhandled exception, this is the exception
  /// thrown.
  @optional InstanceRef exception;

  /// If this error is due to an unhandled exception, this is the stacktrace
  /// object.
  @optional InstanceRef stacktrace;

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
  static Event _parse(Map json) => new Event._fromJson(json);

  Event();
  Event._fromJson(Map json) : super._fromJson(json) {
    kind = _parseEventKind[json['kind']];
    isolate = _createObject(json['isolate']);
    vm = _createObject(json['vm']);
    timestamp = json['timestamp'];
    breakpoint = _createObject(json['breakpoint']);
    pauseBreakpoints = _createObject(json['pauseBreakpoints']);
    topFrame = _createObject(json['topFrame']);
    exception = _createObject(json['exception']);
    bytes = json['bytes'];
  }

  /// What kind of event is this?
  EventKind kind;

  /// The isolate with which this event is associated.
  ///
  /// This is provided for all event kinds except for:
  ///  - VMUpdate
  @optional IsolateRef isolate;

  /// The vm with which this event is associated.
  ///
  /// This is provided for the event kind:
  ///  - VMUpdate
  @optional VMRef vm;

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
  @optional Breakpoint breakpoint;

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
  @optional List<Breakpoint> pauseBreakpoints;

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
  @optional Frame topFrame;

  /// The exception associated with this event, if this is a PauseException
  /// event.
  @optional InstanceRef exception;

  /// An array of bytes, encoded as a base64 string.
  ///
  /// This is provided for the WriteEvent event.
  @optional String bytes;

  String toString() =>
      '[Event type: ${type}, kind: ${kind}, timestamp: ${timestamp}]';
}

/// An `FieldRef` is a reference to a `Field`.
class FieldRef extends ObjRef {
  static FieldRef _parse(Map json) => new FieldRef._fromJson(json);

  FieldRef();
  FieldRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    declaredType = _createObject(json['declaredType']);
    isConst = json['const'];
    isFinal = json['final'];
    isStatic = json['static'];
  }

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

  int get hashCode => id.hashCode;

  operator ==(other) => other is FieldRef && id == other.id;

  String toString() => '[FieldRef]';
}

/// A `Field` provides information about a Dart language field or variable.
class Field extends Obj {
  static Field _parse(Map json) => new Field._fromJson(json);

  Field();
  Field._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    declaredType = _createObject(json['declaredType']);
    isConst = json['const'];
    isFinal = json['final'];
    isStatic = json['static'];
    staticValue = _createObject(json['staticValue']);
    location = _createObject(json['location']);
  }

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
  @optional InstanceRef staticValue;

  /// The location of this field in the source code.
  @optional SourceLocation location;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Field && id == other.id;

  String toString() => '[Field]';
}

/// A `Flag` represents a single VM command line flag.
class Flag {
  static Flag _parse(Map json) => new Flag._fromJson(json);

  Flag();
  Flag._fromJson(Map json) {
    name = json['name'];
    comment = json['comment'];
    modified = json['modified'];
    valueAsString = json['valueAsString'];
  }

  /// The name of the flag.
  String name;

  /// A description of the flag.
  String comment;

  /// Has this flag been modified from its default setting?
  bool modified;

  /// The value of this flag as a string.
  ///
  /// If this property is absent, then the value of the flag was NULL.
  @optional String valueAsString;

  String toString() =>
      '[Flag name: ${name}, comment: ${comment}, modified: ${modified}]';
}

/// A `FlagList` represents the complete set of VM command line flags.
class FlagList extends Response {
  static FlagList _parse(Map json) => new FlagList._fromJson(json);

  FlagList();
  FlagList._fromJson(Map json) : super._fromJson(json) {
    flags = _createObject(json['flags']);
  }

  /// A list of all flags in the VM.
  List<Flag> flags;

  String toString() => '[FlagList type: ${type}, flags: ${flags}]';
}

class Frame extends Response {
  static Frame _parse(Map json) => new Frame._fromJson(json);

  Frame();
  Frame._fromJson(Map json) : super._fromJson(json) {
    index = json['index'];
    function = _createObject(json['function']);
    code = _createObject(json['code']);
    location = _createObject(json['location']);
    vars = _createObject(json['vars']);
  }

  int index;

  FuncRef function;

  CodeRef code;

  SourceLocation location;

  List<BoundVariable> vars;

  String toString() => '[Frame ' //
      'type: ${type}, index: ${index}, function: ${function}, code: ${code}, ' //
      'location: ${location}, vars: ${vars}]';
}

/// An `FuncRef` is a reference to a `Func`.
class FuncRef extends ObjRef {
  static FuncRef _parse(Map json) => new FuncRef._fromJson(json);

  FuncRef();
  FuncRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    isStatic = json['static'];
    isConst = json['const'];
  }

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

  int get hashCode => id.hashCode;

  operator ==(other) => other is FuncRef && id == other.id;

  String toString() => '[FuncRef ' //
      'type: ${type}, id: ${id}, name: ${name}, owner: ${owner}, ' //
      'isStatic: ${isStatic}, isConst: ${isConst}]';
}

/// A `Func` represents a Dart language function.
class Func extends Obj {
  static Func _parse(Map json) => new Func._fromJson(json);

  Func();
  Func._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    owner = _createObject(json['owner']);
    location = _createObject(json['location']);
    code = _createObject(json['code']);
  }

  /// The name of this function.
  String name;

  /// The owner of this function, which can be a Library, Class, or a Function.
  ///
  /// [owner] can be one of [LibraryRef], [ClassRef] or [FuncRef].
  dynamic owner;

  /// The location of this function in the source code.
  @optional SourceLocation location;

  /// The compiled code associated with this function.
  @optional CodeRef code;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Func && id == other.id;

  String toString() =>
      '[Func type: ${type}, id: ${id}, name: ${name}, owner: ${owner}]';
}

/// `InstanceRef` is a reference to an `Instance`.
class InstanceRef extends ObjRef {
  static InstanceRef _parse(Map json) => new InstanceRef._fromJson(json);

  InstanceRef();
  InstanceRef._fromJson(Map json) : super._fromJson(json) {
    kind = _parseInstanceKind[json['kind']];
    classRef = _createObject(json['class']);
    valueAsString = json['valueAsString'];
    valueAsStringIsTruncated = json['valueAsStringIsTruncated'] ?? false;
    length = json['length'];
    name = json['name'];
    typeClass = _createObject(json['typeClass']);
    parameterizedClass = _createObject(json['parameterizedClass']);
    pattern = _createObject(json['pattern']);
  }

  /// What kind of instance is this?
  InstanceKind kind;

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
  @optional String valueAsString;

  /// The valueAsString for String references may be truncated. If so, this
  /// property is added with the value 'true'.
  @optional bool valueAsStringIsTruncated;

  /// The length of a List or the number of associations in a Map.
  ///
  /// Provided for instance kinds:
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
  @optional int length;

  /// The name of a Type instance.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional String name;

  /// The corresponding Class if this Type is canonical.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional ClassRef typeClass;

  /// The parameterized class of a type parameter:
  ///
  /// Provided for instance kinds:
  ///  - TypeParameter
  @optional ClassRef parameterizedClass;

  /// The pattern of a RegExp instance.
  ///
  /// The pattern is always an instance of kind String.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional InstanceRef pattern;

  int get hashCode => id.hashCode;

  operator ==(other) => other is InstanceRef && id == other.id;

  String toString() => '[InstanceRef ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}]';
}

/// An `Instance` represents an instance of the Dart language class `Obj`.
class Instance extends Obj {
  static Instance _parse(Map json) => new Instance._fromJson(json);

  Instance();
  Instance._fromJson(Map json) : super._fromJson(json) {
    kind = _parseInstanceKind[json['kind']];
    classRef = _createObject(json['class']);
    valueAsString = json['valueAsString'];
    valueAsStringIsTruncated = json['valueAsStringIsTruncated'] ?? false;
    length = json['length'];
    offset = json['offset'];
    count = json['count'];
    name = json['name'];
    typeClass = _createObject(json['typeClass']);
    parameterizedClass = _createObject(json['parameterizedClass']);
    fields = _createObject(json['fields']);
    elements = _createObject(json['elements']);
    associations = _createObject(json['associations']);
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

  /// What kind of instance is this?
  InstanceKind kind;

  /// Instance references always include their class.
  ClassRef classRef;

  /// The value of this instance as a string.
  ///
  /// Provided for the instance kinds:
  ///  - Bool (true or false)
  ///  - Double (suitable for passing to Double.parse())
  ///  - Int (suitable for passing to int.parse())
  ///  - String (value may be truncated)
  @optional String valueAsString;

  /// The valueAsString for String references may be truncated. If so, this
  /// property is added with the value 'true'.
  @optional bool valueAsStringIsTruncated;

  /// The length of a List or the number of associations in a Map.
  ///
  /// Provided for instance kinds:
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
  @optional int length;

  /// The index of the first element or association returned. This is only
  /// provided when it is non-zero.
  ///
  /// Provided for instance kinds:
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
  @optional int offset;

  /// The number of elements or associations returned. This is only provided
  /// when it is less than length.
  ///
  /// Provided for instance kinds:
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
  @optional int count;

  /// The name of a Type instance.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional String name;

  /// The corresponding Class if this Type is canonical.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional ClassRef typeClass;

  /// The parameterized class of a type parameter:
  ///
  /// Provided for instance kinds:
  ///  - TypeParameter
  @optional ClassRef parameterizedClass;

  /// The fields of this Instance.
  @optional List<BoundField> fields;

  /// The elements of a List instance.
  ///
  /// Provided for instance kinds:
  ///  - List
  @optional List<dynamic> elements;

  /// The elements of a List instance.
  ///
  /// Provided for instance kinds:
  ///  - Map
  @optional List<MapAssociation> associations;

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
  @optional String bytes;

  /// The function associated with a Closure instance.
  ///
  /// Provided for instance kinds:
  ///  - Closure
  @optional FuncRef closureFunction;

  /// The context associated with a Closure instance.
  ///
  /// Provided for instance kinds:
  ///  - Closure
  @optional ContextRef closureContext;

  /// The referent of a MirrorReference instance.
  ///
  /// Provided for instance kinds:
  ///  - MirrorReference
  @optional InstanceRef mirrorReferent;

  /// The pattern of a RegExp instance.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional String pattern;

  /// Whether this regular expression is case sensitive.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional bool isCaseSensitive;

  /// Whether this regular expression matches multiple lines.
  ///
  /// Provided for instance kinds:
  ///  - RegExp
  @optional bool isMultiLine;

  /// The key for a WeakProperty instance.
  ///
  /// Provided for instance kinds:
  ///  - WeakProperty
  @optional InstanceRef propertyKey;

  /// The key for a WeakProperty instance.
  ///
  /// Provided for instance kinds:
  ///  - WeakProperty
  @optional InstanceRef propertyValue;

  /// The type arguments for this type.
  ///
  /// Provided for instance kinds:
  ///  - Type
  @optional TypeArgumentsRef typeArguments;

  /// The index of a TypeParameter instance.
  ///
  /// Provided for instance kinds:
  ///  - TypeParameter
  @optional int parameterIndex;

  /// The type bounded by a BoundedType instance - or - the referent of a
  /// TypeRef instance.
  ///
  /// The value will always be of one of the kinds: Type, TypeRef,
  /// TypeParameter, BoundedType.
  ///
  /// Provided for instance kinds:
  ///  - BoundedType
  ///  - TypeRef
  @optional InstanceRef targetType;

  /// The bound of a TypeParameter or BoundedType.
  ///
  /// The value will always be of one of the kinds: Type, TypeRef,
  /// TypeParameter, BoundedType.
  ///
  /// Provided for instance kinds:
  ///  - BoundedType
  ///  - TypeParameter
  @optional InstanceRef bound;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Instance && id == other.id;

  String toString() => '[Instance ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}]';
}

/// `IsolateRef` is a reference to an `Isolate` object.
class IsolateRef extends Response {
  static IsolateRef _parse(Map json) => new IsolateRef._fromJson(json);

  IsolateRef();
  IsolateRef._fromJson(Map json) : super._fromJson(json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
  }

  /// The id which is passed to the getIsolate RPC to load this isolate.
  String id;

  /// A numeric id for this isolate, represented as a string. Unique.
  String number;

  /// A name identifying this isolate. Not guaranteed to be unique.
  String name;

  int get hashCode => id.hashCode;

  operator ==(other) => other is IsolateRef && id == other.id;

  String toString() =>
      '[IsolateRef type: ${type}, id: ${id}, number: ${number}, name: ${name}]';
}

/// An `Isolate` object provides information about one isolate in the VM.
class Isolate extends Response {
  static Isolate _parse(Map json) => new Isolate._fromJson(json);

  Isolate();
  Isolate._fromJson(Map json) : super._fromJson(json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
    startTime = json['startTime'];
    livePorts = json['livePorts'];
    pauseOnExit = json['pauseOnExit'];
    pauseEvent = _createObject(json['pauseEvent']);
    rootLib = _createObject(json['rootLib']);
    libraries = _createObject(json['libraries']);
    breakpoints = _createObject(json['breakpoints']);
    error = _createObject(json['error']);
    exceptionPauseMode = _parseExceptionPauseMode[json['exceptionPauseMode']];
  }

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
  @optional LibraryRef rootLib;

  /// A list of all libraries for this isolate.
  ///
  /// Guaranteed to be initialized when the IsolateRunnable event fires.
  List<LibraryRef> libraries;

  /// A list of all breakpoints for this isolate.
  List<Breakpoint> breakpoints;

  /// The error that is causing this isolate to exit, if applicable.
  @optional Error error;

  /// The current pause on exception mode for this isolate.
  ExceptionPauseMode exceptionPauseMode;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Isolate && id == other.id;

  String toString() => '[Isolate]';
}

/// `LibraryRef` is a reference to a `Library`.
class LibraryRef extends ObjRef {
  static LibraryRef _parse(Map json) => new LibraryRef._fromJson(json);

  LibraryRef();
  LibraryRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    uri = json['uri'];
  }

  /// The name of this library.
  String name;

  /// The uri of this library.
  String uri;

  int get hashCode => id.hashCode;

  operator ==(other) => other is LibraryRef && id == other.id;

  String toString() =>
      '[LibraryRef type: ${type}, id: ${id}, name: ${name}, uri: ${uri}]';
}

/// A `Library` provides information about a Dart language library.
///
/// See [setLibraryDebuggable].
class Library extends Obj {
  static Library _parse(Map json) => new Library._fromJson(json);

  Library();
  Library._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    uri = json['uri'];
    debuggable = json['debuggable'];
    dependencies = _createObject(json['dependencies']);
    scripts = _createObject(json['scripts']);
    variables = _createObject(json['variables']);
    functions = _createObject(json['functions']);
    classes = _createObject(json['classes']);
  }

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

  int get hashCode => id.hashCode;

  operator ==(other) => other is Library && id == other.id;

  String toString() => '[Library]';
}

/// A `LibraryDependency` provides information about an import or export.
class LibraryDependency {
  static LibraryDependency _parse(Map json) =>
      new LibraryDependency._fromJson(json);

  LibraryDependency();
  LibraryDependency._fromJson(Map json) {
    isImport = json['isImport'];
    isDeferred = json['isDeferred'];
    prefix = json['prefix'];
    target = _createObject(json['target']);
  }

  /// Is this dependency an import (rather than an export)?
  bool isImport;

  /// Is this dependency deferred?
  bool isDeferred;

  /// The prefix of an 'as' import, or null.
  String prefix;

  /// The library being imported or exported.
  LibraryRef target;

  String toString() => '[LibraryDependency ' //
      'isImport: ${isImport}, isDeferred: ${isDeferred}, prefix: ${prefix}, ' //
      'target: ${target}]';
}

class MapAssociation {
  static MapAssociation _parse(Map json) => new MapAssociation._fromJson(json);

  MapAssociation();
  MapAssociation._fromJson(Map json) {
    key = _createObject(json['key']);
    value = _createObject(json['value']);
  }

  /// [key] can be one of [InstanceRef] or [Sentinel].
  dynamic key;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[MapAssociation key: ${key}, value: ${value}]';
}

/// A `Message` provides information about a pending isolate message and the
/// function that will be invoked to handle it.
class Message extends Response {
  static Message _parse(Map json) => new Message._fromJson(json);

  Message();
  Message._fromJson(Map json) : super._fromJson(json) {
    index = json['index'];
    name = json['name'];
    messageObjectId = json['messageObjectId'];
    size = json['size'];
    handler = _createObject(json['handler']);
    location = _createObject(json['location']);
  }

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
  @optional FuncRef handler;

  /// The source location of handler.
  @optional SourceLocation location;

  String toString() => '[Message ' //
      'type: ${type}, index: ${index}, name: ${name}, messageObjectId: ${messageObjectId}, ' //
      'size: ${size}]';
}

/// `NullRef` is a reference to an a `Null`.
class NullRef extends InstanceRef {
  static NullRef _parse(Map json) => new NullRef._fromJson(json);

  NullRef();
  NullRef._fromJson(Map json) : super._fromJson(json) {
    valueAsString = json['valueAsString'];
  }

  /// Always 'null'.
  String valueAsString;

  int get hashCode => id.hashCode;

  operator ==(other) => other is NullRef && id == other.id;

  String toString() => '[NullRef ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}, ' //
      'valueAsString: ${valueAsString}]';
}

/// A `Null` object represents the Dart language value null.
class Null extends Instance {
  static Null _parse(Map json) => new Null._fromJson(json);

  Null();
  Null._fromJson(Map json) : super._fromJson(json) {
    valueAsString = json['valueAsString'];
  }

  /// Always 'null'.
  String valueAsString;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Null && id == other.id;

  String toString() => '[Null ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}, ' //
      'valueAsString: ${valueAsString}]';
}

/// `ObjRef` is a reference to a `Obj`.
class ObjRef extends Response {
  static ObjRef _parse(Map json) => new ObjRef._fromJson(json);

  ObjRef();
  ObjRef._fromJson(Map json) : super._fromJson(json) {
    id = json['id'];
  }

  /// A unique identifier for an Object. Passed to the getObject RPC to load
  /// this Object.
  String id;

  int get hashCode => id.hashCode;

  operator ==(other) => other is ObjRef && id == other.id;

  String toString() => '[ObjRef type: ${type}, id: ${id}]';
}

/// An `Obj` is a persistent object that is owned by some isolate.
class Obj extends Response {
  static Obj _parse(Map json) => new Obj._fromJson(json);

  Obj();
  Obj._fromJson(Map json) : super._fromJson(json) {
    id = json['id'];
    classRef = _createObject(json['class']);
    size = json['size'];
  }

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
  @optional ClassRef classRef;

  /// The size of this object in the heap.
  ///
  /// If an object is not heap-allocated, then this field is omitted.
  ///
  /// Note that the size can be zero for some objects. In the current VM
  /// implementation, this occurs for small integers, which are stored entirely
  /// within their object pointers.
  @optional int size;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Obj && id == other.id;

  String toString() => '[Obj type: ${type}, id: ${id}]';
}

/// Every non-error response returned by the Service Protocol extends
/// `Response`. By using the `type` property, the client can determine which
/// [type] of response has been provided.
class Response {
  static Response _parse(Map json) => new Response._fromJson(json);

  Response();
  Response._fromJson(Map json) {
    type = json['type'];
  }

  /// Every response returned by the VM Service has the type property. This
  /// allows the client distinguish between different kinds of responses.
  String type;

  String toString() => '[Response type: ${type}]';
}

/// A `Sentinel` is used to indicate that the normal response is not available.
///
/// We use a `Sentinel` instead of an [error] for these cases because they do
/// not represent a problematic condition. They are normal.
class Sentinel extends Response {
  static Sentinel _parse(Map json) => new Sentinel._fromJson(json);

  Sentinel();
  Sentinel._fromJson(Map json) : super._fromJson(json) {
    kind = _parseSentinelKind[json['kind']];
    valueAsString = json['valueAsString'];
  }

  /// What kind of sentinel is this?
  SentinelKind kind;

  /// A reasonable string representation of this sentinel.
  String valueAsString;

  String toString() => '[Sentinel ' //
      'type: ${type}, kind: ${kind}, valueAsString: ${valueAsString}]';
}

/// `ScriptRef` is a reference to a `Script`.
class ScriptRef extends ObjRef {
  static ScriptRef _parse(Map json) => new ScriptRef._fromJson(json);

  ScriptRef();
  ScriptRef._fromJson(Map json) : super._fromJson(json) {
    uri = json['uri'];
  }

  /// The uri from which this script was loaded.
  String uri;

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
/// [lineNumber, (tokenPos, columnNumber)*]
/// ```
///
/// For example, a `tokenPosTable` with the value...
///
/// ```
/// [[1, 100, 5, 101, 8],[2, 102, 7]]
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
  static Script _parse(Map json) => new Script._fromJson(json);

  Script();
  Script._fromJson(Map json) : super._fromJson(json) {
    uri = json['uri'];
    library = _createObject(json['library']);
    source = json['source'];
    tokenPosTable = json['tokenPosTable'];
  }

  /// The uri from which this script was loaded.
  String uri;

  /// The library which owns this script.
  LibraryRef library;

  /// The source code for this script. For certain built-in scripts, this may be
  /// reconstructed without source comments.
  String source;

  /// A table encoding a mapping from token position to line and column.
  List<List<int>> tokenPosTable;

  int get hashCode => id.hashCode;

  operator ==(other) => other is Script && id == other.id;

  String toString() => '[Script ' //
      'type: ${type}, id: ${id}, uri: ${uri}, library: ${library}, ' //
      'source: ${source}, tokenPosTable: ${tokenPosTable}]';
}

/// The `SourceLocation` class is used to designate a position or range in some
/// script.
class SourceLocation extends Response {
  static SourceLocation _parse(Map json) => new SourceLocation._fromJson(json);

  SourceLocation();
  SourceLocation._fromJson(Map json) : super._fromJson(json) {
    script = _createObject(json['script']);
    tokenPos = json['tokenPos'];
    endTokenPos = json['endTokenPos'];
  }

  /// The script containing the source location.
  ScriptRef script;

  /// The first token of the location.
  int tokenPos;

  /// The last token of the location if this is a range.
  @optional int endTokenPos;

  String toString() =>
      '[SourceLocation type: ${type}, script: ${script}, tokenPos: ${tokenPos}]';
}

class Stack extends Response {
  static Stack _parse(Map json) => new Stack._fromJson(json);

  Stack();
  Stack._fromJson(Map json) : super._fromJson(json) {
    frames = _createObject(json['frames']);
    messages = _createObject(json['messages']);
  }

  List<Frame> frames;

  List<Message> messages;

  String toString() =>
      '[Stack type: ${type}, frames: ${frames}, messages: ${messages}]';
}

/// The `Success` type is used to indicate that an operation completed
/// successfully.
class Success extends Response {
  static Success _parse(Map json) => new Success._fromJson(json);

  Success();
  Success._fromJson(Map json) : super._fromJson(json) {}

  String toString() => '[Success type: ${type}]';
}

/// `TypeArgumentsRef` is a reference to a `TypeArguments` object.
class TypeArgumentsRef extends ObjRef {
  static TypeArgumentsRef _parse(Map json) =>
      new TypeArgumentsRef._fromJson(json);

  TypeArgumentsRef();
  TypeArgumentsRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
  }

  /// A name for this type argument list.
  String name;

  int get hashCode => id.hashCode;

  operator ==(other) => other is TypeArgumentsRef && id == other.id;

  String toString() =>
      '[TypeArgumentsRef type: ${type}, id: ${id}, name: ${name}]';
}

/// A `TypeArguments` object represents the type argument vector for some
/// instantiated generic type.
class TypeArguments extends Obj {
  static TypeArguments _parse(Map json) => new TypeArguments._fromJson(json);

  TypeArguments();
  TypeArguments._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
    types = _createObject(json['types']);
  }

  /// A name for this type argument list.
  String name;

  /// A list of types.
  ///
  /// The value will always be one of the kinds: Type, TypeRef, TypeParameter,
  /// BoundedType.
  List<InstanceRef> types;

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
  static UnresolvedSourceLocation _parse(Map json) =>
      new UnresolvedSourceLocation._fromJson(json);

  UnresolvedSourceLocation();
  UnresolvedSourceLocation._fromJson(Map json) : super._fromJson(json) {
    script = _createObject(json['script']);
    scriptUri = json['scriptUri'];
    tokenPos = json['tokenPos'];
    line = json['line'];
    column = json['column'];
  }

  /// The script containing the source location if the script has been loaded.
  @optional ScriptRef script;

  /// The uri of the script containing the source location if the script has yet
  /// to be loaded.
  @optional String scriptUri;

  /// An approximate token position for the source location. This may change
  /// when the location is resolved.
  @optional int tokenPos;

  /// An approximate line number for the source location. This may change when
  /// the location is resolved.
  @optional int line;

  /// An approximate column number for the source location. This may change when
  /// the location is resolved.
  @optional int column;

  String toString() => '[UnresolvedSourceLocation type: ${type}]';
}

/// See [Versioning].
class Version extends Response {
  static Version _parse(Map json) => new Version._fromJson(json);

  Version();
  Version._fromJson(Map json) : super._fromJson(json) {
    major = json['major'];
    minor = json['minor'];
  }

  /// The major version number is incremented when the protocol is changed in a
  /// potentially incompatible way.
  int major;

  /// The minor version number is incremented when the protocol is changed in a
  /// backwards compatible way.
  int minor;

  String toString() =>
      '[Version type: ${type}, major: ${major}, minor: ${minor}]';
}

/// `VMRef` is a reference to a `VM` object.
class VMRef extends Response {
  static VMRef _parse(Map json) => new VMRef._fromJson(json);

  VMRef();
  VMRef._fromJson(Map json) : super._fromJson(json) {
    name = json['name'];
  }

  /// A name identifying this vm. Not guaranteed to be unique.
  String name;

  String toString() => '[VMRef type: ${type}, name: ${name}]';
}

class VM extends Response {
  static VM _parse(Map json) => new VM._fromJson(json);

  VM();
  VM._fromJson(Map json) : super._fromJson(json) {
    architectureBits = json['architectureBits'];
    targetCPU = json['targetCPU'];
    hostCPU = json['hostCPU'];
    version = json['version'];
    pid = json['pid'];
    startTime = json['startTime'];
    isolates = _createObject(json['isolates']);
  }

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

  String toString() => '[VM]';
}
