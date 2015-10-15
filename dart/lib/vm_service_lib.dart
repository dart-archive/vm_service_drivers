// This is a generated file.

/// A library to access the VM Service API.
library vm_service_lib;

import 'dart:async';
import 'dart:convert' show BASE64, JSON, JsonCodec;

const String vmServiceVersion = '3.0.0';

/// @optional
const String optional = 'optional';

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
  '@Null': NullRef.parse,
  'Null': Null.parse,
  '@Object': ObjRef.parse,
  'Object': Obj.parse,
  'Response': Response.parse,
  'Sentinel': Sentinel.parse,
  '@Script': ScriptRef.parse,
  'Script': Script.parse,
  'SourceLocation': SourceLocation.parse,
  'Stack': Stack.parse,
  'Success': Success.parse,
  '@TypeArguments': TypeArgumentsRef.parse,
  'TypeArguments': TypeArguments.parse,
  'UnresolvedSourceLocation': UnresolvedSourceLocation.parse,
  'Version': Version.parse,
  '@VM': VMRef.parse,
  'VM': VM.parse
};

String decodeBase64(String str) => new String.fromCharCodes(BASE64.decode(str));

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

  /// The [addBreakpoint] RPC is used to add a breakpoint at a specific line of
  /// some script.
  ///
  /// The [scriptId] parameter is used to specify the target script.
  ///
  /// The [line] parameter is used to specify the target line for the
  /// breakpoint. If there are multiple possible breakpoints on the target line,
  /// then the VM will place the breakpoint at the location which would execute
  /// soonest. If it is not possible to set a breakpoint at the target line, the
  /// breakpoint will be added at the next possible breakpoint location within
  /// the same function.
  ///
  /// The [column] parameter may be optionally specified. This is useful for
  /// targeting a specific breakpoint on a line with multiple possible
  /// breakpoints.
  ///
  /// If no breakpoint is possible at that line, the [102] (Cannot add
  /// breakpoint) error code is returned.
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  ///
  /// See Breakpoint.
  Future<Breakpoint> addBreakpoint(String isolateId, String scriptId, int line,
      [int column]) {
    Map m = {'isolateId': isolateId, 'scriptId': scriptId, 'line': line};
    if (column != null) m['column'] = column;
    return _call('addBreakpoint', m);
  }

  /// The [addBreakpoint] RPC is used to add a breakpoint at a specific line of
  /// some script. This RPC is useful when a script has not yet been assigned an
  /// id, for example, if a script is in a deferred library which has not yet
  /// been loaded.
  ///
  /// The [scriptUri] parameter is used to specify the target script.
  ///
  /// The [line] parameter is used to specify the target line for the
  /// breakpoint. If there are multiple possible breakpoints on the target line,
  /// then the VM will place the breakpoint at the location which would execute
  /// soonest. If it is not possible to set a breakpoint at the target line, the
  /// breakpoint will be added at the next possible breakpoint location within
  /// the same function.
  ///
  /// The [column] parameter may be optionally specified. This is useful for
  /// targeting a specific breakpoint on a line with multiple possible
  /// breakpoints.
  ///
  /// If no breakpoint is possible at that line, the [102] (Cannot add
  /// breakpoint) error code is returned.
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  ///
  /// See Breakpoint.
  Future<Breakpoint> addBreakpointWithScriptUri(
      String isolateId, String scriptUri, int line,
      [int column]) {
    Map m = {'isolateId': isolateId, 'scriptUri': scriptUri, 'line': line};
    if (column != null) m['column'] = column;
    return _call('addBreakpointWithScriptUri', m);
  }

  /// The [addBreakpointAtEntry] RPC is used to add a breakpoint at the
  /// entrypoint of some function.
  ///
  /// If no breakpoint is possible at the function entry, the [102] (Cannot add
  /// breakpoint) error code is returned.
  ///
  /// See Breakpoint.
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  Future<Breakpoint> addBreakpointAtEntry(String isolateId, String functionId) {
    return _call('addBreakpointAtEntry',
        {'isolateId': isolateId, 'functionId': functionId});
  }

  /// The [evaluate] RPC is used to evaluate an expression in the context of
  /// some target.
  ///
  /// [targetId] may refer to a Library, Class, or Instance.
  ///
  /// If [targetId] is a temporary id which has expired, then then [Expired]
  /// Sentinel is returned.
  ///
  /// If [targetId] refers to an object which has been collected by the VM's
  /// garbage collector, then the [Collected] Sentinel is returned.
  ///
  /// If an error occurs while evaluating the expression, an @Error reference
  /// will be returned.
  ///
  /// If the expression is evaluated successfully, an @Instance reference will
  /// be returned.
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

  /// The [evaluateInFrame] RPC is used to evaluate an expression in the context
  /// of a particular stack frame. [frameIndex] is the index of the desired
  /// Frame, with an index of [0] indicating the top (most recent) frame.
  ///
  /// If an error occurs while evaluating the expression, an @Error reference
  /// will be returned.
  ///
  /// If the expression is evaluated successfully, an @Instance reference will
  /// be returned.
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
  /// See FlagList.
  Future<FlagList> getFlagList() => _call('getFlagList');

  /// The [getIsolate] RPC is used to lookup an [Isolate] object by its [id].
  ///
  /// If [isolateId] refers to an isolate which has exited, then the [Collected]
  /// Sentinel is returned.
  ///
  /// See Isolate.
  ///
  /// The return value can be one of [Isolate] or [Sentinel].
  Future<dynamic> getIsolate(String isolateId) {
    return _call('getIsolate', {'isolateId': isolateId});
  }

  /// The [getObject] RPC is used to lookup an [object] from some isolate by its
  /// [id].
  ///
  /// If [objectId] is a temporary id which has expired, then then [Expired]
  /// Sentinel is returned.
  ///
  /// If [objectId] refers to a heap object which has been collected by the VM's
  /// garbage collector, then the [Collected] Sentinel is returned.
  ///
  /// If [objectId] refers to a non-heap object which has been deleted, then the
  /// [Collected] Sentinel is returned.
  ///
  /// If the object handle has not expired and the object has not been
  /// collected, then an Object will be returned.
  ///
  /// The [offset] and [count] parameters are used to request subranges of
  /// Instance objects with the kinds: List, Map, Uint8ClampedList, Uint8List,
  /// Uint16List, Uint32List, Uint64List, Int8List, Int16List, Int32List,
  /// Int64List, Flooat32List, Float64List, Inst32x3List, Float32x4List, and
  /// Float64x2List. These parameters are otherwise ignored.
  ///
  /// The return value can be one of [Obj] or [Sentinel].
  Future<dynamic> getObject(String isolateId, String objectId,
      [int offset, int count]) {
    Map m = {'isolateId': isolateId, 'objectId': objectId};
    if (offset != null) m['offset'] = offset;
    if (count != null) m['count'] = count;
    return _call('getObject', m);
  }

  /// The [getStack] RPC is used to retrieve the current execution stack and
  /// message queue for an isolate. The isolate does not need to be paused.
  ///
  /// See Stack.
  Future<Stack> getStack(String isolateId) {
    return _call('getStack', {'isolateId': isolateId});
  }

  /// The [getVersion] RPC is used to determine what version of the Service
  /// Protocol is served by a VM.
  ///
  /// See Version.
  Future<Version> getVersion() => _call('getVersion');

  /// The [getVM] RPC returns global information about a Dart virtual machine.
  ///
  /// See VM.
  Future<VM> getVM() => _call('getVM');

  /// The [pause] RPC is used to interrupt a running isolate. The RPC enqueues
  /// the interrupt request and potentially returns before the isolate is
  /// paused.
  ///
  /// When the isolate is paused an event will be sent on the [Debug] stream.
  ///
  /// See Success.
  Future<Success> pause(String isolateId) {
    return _call('pause', {'isolateId': isolateId});
  }

  /// The [removeBreakpoint] RPC is used to remove a breakpoint by its [id].
  ///
  /// Note that breakpoints are added and removed on a per-isolate basis.
  ///
  /// See Success.
  Future<Success> removeBreakpoint(String isolateId, String breakpointId) {
    return _call('removeBreakpoint',
        {'isolateId': isolateId, 'breakpointId': breakpointId});
  }

  /// The [resume] RPC is used to resume execution of a paused isolate.
  ///
  /// If the [step] parameter is not provided, the program will resume regular
  /// execution.
  ///
  /// If the [step] parameter is provided, it indicates what form of
  /// single-stepping to use.
  ///
  /// step | meaning
  /// ---- | -------
  /// Into | Single step, entering function calls
  /// Over | Single step, skipping over function calls
  /// Out | Single step until the current function exits
  ///
  /// See Success, StepOption.
  Future<Success> resume(String isolateId, [/*StepOption*/ String step]) {
    Map m = {'isolateId': isolateId};
    if (step != null) m['step'] = step;
    return _call('resume', m);
  }

  /// The [setExceptionPauseMode] RPC is used to control if an isolate pauses
  /// when an exception is thrown.
  ///
  /// mode | meaning
  /// ---- | -------
  /// None | Do not pause isolate on thrown exceptions
  /// Unhandled | Pause isolate on unhandled exceptions
  /// All  | Pause isolate on all thrown exceptions
  Future<Success> setExceptionPauseMode(
      String isolateId, ExceptionPauseMode mode) {
    return _call(
        'setExceptionPauseMode', {'isolateId': isolateId, 'mode': mode});
  }

  /// The [setLibraryDebuggable] RPC is used to enable or disable whether
  /// breakpoints and stepping work for a given library.
  ///
  /// See Success.
  Future<Success> setLibraryDebuggable(
      String isolateId, String libraryId, bool isDebuggable) {
    return _call('setLibraryDebuggable', {
      'isolateId': isolateId,
      'libraryId': libraryId,
      'isDebuggable': isDebuggable
    });
  }

  /// The [setName] RPC is used to change the debugging name for an isolate.
  ///
  /// See Success.
  Future<Success> setName(String isolateId, String name) {
    return _call('setName', {'isolateId': isolateId, 'name': name});
  }

  /// The [setVMName] RPC is used to change the debugging name for the vm.
  ///
  /// See Success.
  Future<Success> setVMName(String name) {
    return _call('setVMName', {'name': name});
  }

  /// The [streamCancel] RPC cancels a stream subscription in the VM.
  ///
  /// If the client is not subscribed to the stream, the [104] (Stream not
  /// subscribed) error code is returned.
  ///
  /// See Success.
  Future<Success> streamCancel(String streamId) {
    return _call('streamCancel', {'streamId': streamId});
  }

  /// The [streamListen] RPC subscribes to a stream in the VM. Once subscribed,
  /// the client will begin receiving events from the stream.
  ///
  /// If the client is not subscribed to the stream, the [103] (Stream already
  /// subscribed) error code is returned.
  ///
  /// The [streamId] parameter may have the following published values:
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
  /// Additionally, some embedders provide the [Stdout] and [Stderr] streams.
  /// These streams allow the client to subscribe to writes to stdout and
  /// stderr.
  ///
  /// streamId | event types provided
  /// -------- | -----------
  /// Stdout | WriteEvent
  /// Stderr | WriteEvent
  ///
  /// It is considered a [backwards compatible] change to add a new type of
  /// event to an existing stream. Clients should be written to handle this
  /// gracefully, perhaps by warning and ignoring.
  ///
  /// See Success.
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
          _vmController.add(createObject(params['event']));
        } else if (streamId == 'Isolate') {
          _isolateController.add(createObject(params['event']));
        } else if (streamId == 'Debug') {
          _debugController.add(createObject(params['event']));
        } else if (streamId == 'GC') {
          _gcController.add(createObject(params['event']));
        } else if (streamId == 'Stdout') {
          _stdoutController.add(createObject(params['event']));
        } else if (streamId == 'Stderr') {
          _stderrController.add(createObject(params['event']));
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
            completer.complete(createObject(result));
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

Object createObject(dynamic json) {
  if (json == null) return null;

  if (json is List) {
    return (json as List).map((e) => createObject(e)).toList();
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

abstract class Log {
  void warning(String message);
  void severe(String message);
}

class _NullLog implements Log {
  void warning(String message) {}
  void severe(String message) {}
}

// enums

class CodeKind {
  static const String Dart = 'Dart';
  static const String Native = 'Native';
  static const String Stub = 'Stub';
  static const String Tag = 'Tag';
  static const String Collected = 'Collected';
}

class ErrorKind {
  /// The isolate has encountered an unhandled Dart exception.
  static const String UnhandledException = 'UnhandledException';

  /// The isolate has encountered a Dart language error in the program.
  static const String LanguageError = 'LanguageError';

  /// The isolate has encounted an internal error. These errors should be
  /// reported as bugs.
  static const String InternalError = 'InternalError';

  /// The isolate has been terminated by an external source.
  static const String TerminationError = 'TerminationError';
}

/// Adding new values to [EventKind] is considered a backwards compatible
/// change. Clients should ignore unrecognized events.
class EventKind {
  /// Notification that VM identifying information has changed. Currently used
  /// to notify of changes to the VM debugging name via setVMName.
  static const String VMUpdate = 'VMUpdate';

  /// Notification that a new isolate has started.
  static const String IsolateStart = 'IsolateStart';

  /// Notification that an isolate is ready to run.
  static const String IsolateRunnable = 'IsolateRunnable';

  /// Notification that an isolate has exited.
  static const String IsolateExit = 'IsolateExit';

  /// Notification that isolate identifying information has changed. Currently
  /// used to notify of changes to the isolate debugging name via setName.
  static const String IsolateUpdate = 'IsolateUpdate';

  /// An isolate has paused at start, before executing code.
  static const String PauseStart = 'PauseStart';

  /// An isolate has paused at exit, before terminating.
  static const String PauseExit = 'PauseExit';

  /// An isolate has paused at a breakpoint or due to stepping.
  static const String PauseBreakpoint = 'PauseBreakpoint';

  /// An isolate has paused due to interruption via pause.
  static const String PauseInterrupted = 'PauseInterrupted';

  /// An isolate has paused due to an exception.
  static const String PauseException = 'PauseException';

  /// An isolate has started or resumed execution.
  static const String Resume = 'Resume';

  /// A breakpoint has been added for an isolate.
  static const String BreakpointAdded = 'BreakpointAdded';

  /// An unresolved breakpoint has been resolved for an isolate.
  static const String BreakpointResolved = 'BreakpointResolved';

  /// A breakpoint has been removed.
  static const String BreakpointRemoved = 'BreakpointRemoved';

  /// A garbage collection event.
  static const String GC = 'GC';

  /// Notification of bytes written, for example, to stdout/stderr.
  static const String WriteEvent = 'WriteEvent';
}

/// Adding new values to [InstanceKind] is considered a backwards compatible
/// change. Clients should treat unrecognized instance kinds as [PlainInstance].
class InstanceKind {
  /// A general instance of the Dart class Object.
  static const String PlainInstanceKind = 'PlainInstance';

  /// null instance.
  static const String NullKind = 'Null';

  /// true or false.
  static const String BoolKind = 'Bool';

  /// An instance of the Dart class double.
  static const String DoubleKind = 'Double';

  /// An instance of the Dart class int.
  static const String IntKind = 'Int';

  /// An instance of the Dart class String.
  static const String StringKind = 'String';

  /// An instance of the built-in VM List implementation. User-defined Lists
  /// will be PlainInstance.
  static const String ListKind = 'List';

  /// An instance of the built-in VM Map implementation. User-defined Maps will
  /// be PlainInstance.
  static const String MapKind = 'Map';

  /// Vector instance kinds.
  static const String Float32x4Kind = 'Float32x4';
  static const String Float64x2Kind = 'Float64x2';
  static const String Int32x4Kind = 'Int32x4';

  /// An instance of the built-in VM TypedData implementations. User-defined
  /// TypedDatas will be PlainInstance.
  static const String Uint8ClampedListKind = 'Uint8ClampedList';
  static const String Uint8ListKind = 'Uint8List';
  static const String Uint16ListKind = 'Uint16List';
  static const String Uint32ListKind = 'Uint32List';
  static const String Uint64ListKind = 'Uint64List';
  static const String Int8ListKind = 'Int8List';
  static const String Int16ListKind = 'Int16List';
  static const String Int32ListKind = 'Int32List';
  static const String Int64ListKind = 'Int64List';
  static const String Float32ListKind = 'Float32List';
  static const String Float64ListKind = 'Float64List';
  static const String Int32x4ListKind = 'Int32x4List';
  static const String Float32x4ListKind = 'Float32x4List';
  static const String Float64x2ListKind = 'Float64x2List';

  /// An instance of the Dart class StackTrace.
  static const String StackTraceKind = 'StackTrace';

  /// An instance of the built-in VM Closure implementation. User-defined
  /// Closures will be PlainInstance.
  static const String ClosureKind = 'Closure';

  /// An instance of the Dart class MirrorReference.
  static const String MirrorReferenceKind = 'MirrorReference';

  /// An instance of the Dart class RegExp.
  static const String RegExpKind = 'RegExp';

  /// An instance of the Dart class WeakProperty.
  static const String WeakPropertyKind = 'WeakProperty';

  /// An instance of the Dart class Type.
  static const String TypeKind = 'Type';

  /// An instance of the Dart class TypeParamer.
  static const String TypeParameterKind = 'TypeParameter';

  /// An instance of the Dart class TypeRef.
  static const String TypeRefKind = 'TypeRef';

  /// An instance of the Dart class BoundedType.
  static const String BoundedTypeKind = 'BoundedType';
}

/// A [SentinelKind] is used to distinguish different kinds of [Sentinel]
/// objects.
///
/// Adding new values to [SentinelKind] is considered a backwards compatible
/// change. Clients must handle this gracefully.
class SentinelKind {
  /// Indicates that the object referred to has been collected by the GC.
  static const String Collected = 'Collected';

  /// Indicates that an object id has expired.
  static const String Expired = 'Expired';

  /// Indicates that a variable or field has not been initialized.
  static const String NotInitialized = 'NotInitialized';

  /// Indicates that a variable or field is in the process of being initialized.
  static const String BeingInitialized = 'BeingInitialized';

  /// Indicates that a variable has been eliminated by the optimizing compiler.
  static const String OptimizedOut = 'OptimizedOut';

  /// Reserved for future use.
  static const String Free = 'Free';
}

/// An [ExceptionPauseMode] indicates how the isolate pauses when an exception
/// is thrown.
class ExceptionPauseMode {
  static const String None = 'None';
  static const String Unhandled = 'Unhandled';
  static const String All = 'All';
}

/// A [StepOption] indicates which form of stepping is requested in a resume
/// RPC.
class StepOption {
  static const String Into = 'Into';
  static const String Over = 'Over';
  static const String Out = 'Out';
}

// types

/// A [BoundField] represents a field bound to a particular value in an
/// [Instance].
///
/// If the field is uninitialized, the [value] will be the [NotInitialized]
/// Sentinel.
///
/// If the field is being initialized, the [value] will be the
/// [BeingInitialized] Sentinel.
class BoundField {
  static BoundField parse(Map json) => new BoundField.fromJson(json);

  BoundField();
  BoundField.fromJson(Map json) {
    decl = createObject(json['decl']);
    value = createObject(json['value']);
  }

  FieldRef decl;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[BoundField decl: ${decl}, value: ${value}]';
}

/// A [BoundVariable] represents a local variable bound to a particular value in
/// a [Frame].
///
/// If the variable is uninitialized, the [value] will be the [NotInitialized]
/// Sentinel.
///
/// If the variable is being initialized, the [value] will be the
/// [BeingInitialized] Sentinel.
///
/// If the variable has been optimized out by the compiler, the [value] will be
/// the [OptimizedOut] Sentinel.
class BoundVariable {
  static BoundVariable parse(Map json) => new BoundVariable.fromJson(json);

  BoundVariable();
  BoundVariable.fromJson(Map json) {
    name = json['name'];
    value = createObject(json['value']);
  }

  String name;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[BoundVariable name: ${name}, value: ${value}]';
}

/// A [Breakpoint] describes a debugger breakpoint.
///
/// A breakpoint is [resolved] when it has been assigned to a specific program
/// location. A breakpoint my remain unresolved when it is in code which has not
/// yet been compiled or in a library which has not been loaded (i.e. a deferred
/// library).
class Breakpoint extends Obj {
  static Breakpoint parse(Map json) => new Breakpoint.fromJson(json);

  Breakpoint();
  Breakpoint.fromJson(Map json) : super.fromJson(json) {
    breakpointNumber = json['breakpointNumber'];
    resolved = json['resolved'];
    location = createObject(json['location']);
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

  String toString() => '[Breakpoint ' //
      'type: ${type}, id: ${id}, breakpointNumber: ${breakpointNumber}, resolved: ${resolved}, location: ${location}]';
}

/// [ClassRef] is a reference to a [Class].
class ClassRef extends ObjRef {
  static ClassRef parse(Map json) => new ClassRef.fromJson(json);

  ClassRef();
  ClassRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
  }

  /// The name of this class.
  String name;

  String toString() => '[ClassRef type: ${type}, id: ${id}, name: ${name}]';
}

/// A [Class] provides information about a Dart language class.
class Class extends Obj {
  static Class parse(Map json) => new Class.fromJson(json);

  Class();
  Class.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    error = createObject(json['error']);
    isAbstract = json['abstract'];
    isConst = json['const'];
    library = createObject(json['library']);
    location = createObject(json['location']);
    superClass = createObject(json['super']);
    interfaces = createObject(json['interfaces']);
    fields = createObject(json['fields']);
    functions = createObject(json['functions']);
    subclasses = createObject(json['subclasses']);
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

  String toString() => '[Class]';
}

class ClassList extends Response {
  static ClassList parse(Map json) => new ClassList.fromJson(json);

  ClassList();
  ClassList.fromJson(Map json) : super.fromJson(json) {
    classes = createObject(json['classes']);
  }

  List<ClassRef> classes;

  String toString() => '[ClassList type: ${type}, classes: ${classes}]';
}

/// [CodeRef] is a reference to a [Code] object.
class CodeRef extends ObjRef {
  static CodeRef parse(Map json) => new CodeRef.fromJson(json);

  CodeRef();
  CodeRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    kind = json['kind'];
  }

  /// A name for this code object.
  String name;

  /// What kind of code object is this?
  /*CodeKind*/ String kind;

  String toString() =>
      '[CodeRef type: ${type}, id: ${id}, name: ${name}, kind: ${kind}]';
}

/// A [Code] object represents compiled code in the Dart VM.
class Code extends ObjRef {
  static Code parse(Map json) => new Code.fromJson(json);

  Code();
  Code.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    kind = json['kind'];
  }

  /// A name for this code object.
  String name;

  /// What kind of code object is this?
  /*CodeKind*/ String kind;

  String toString() =>
      '[Code type: ${type}, id: ${id}, name: ${name}, kind: ${kind}]';
}

class ContextRef extends ObjRef {
  static ContextRef parse(Map json) => new ContextRef.fromJson(json);

  ContextRef();
  ContextRef.fromJson(Map json) : super.fromJson(json) {
    length = json['length'];
  }

  /// The number of variables in this context.
  int length;

  String toString() =>
      '[ContextRef type: ${type}, id: ${id}, length: ${length}]';
}

/// A [Context] is a data structure which holds the captured variables for some
/// closure.
class Context extends Obj {
  static Context parse(Map json) => new Context.fromJson(json);

  Context();
  Context.fromJson(Map json) : super.fromJson(json) {
    length = json['length'];
    parent = createObject(json['parent']);
    variables = createObject(json['variables']);
  }

  /// The number of variables in this context.
  int length;

  /// The enclosing context for this context.
  @optional Context parent;

  /// The variables in this context object.
  List<ContextElement> variables;

  String toString() =>
      '[Context type: ${type}, id: ${id}, length: ${length}, variables: ${variables}]';
}

class ContextElement {
  static ContextElement parse(Map json) => new ContextElement.fromJson(json);

  ContextElement();
  ContextElement.fromJson(Map json) {
    value = createObject(json['value']);
  }

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[ContextElement value: ${value}]';
}

/// [ErrorRef] is a reference to an [Error].
class ErrorRef extends ObjRef {
  static ErrorRef parse(Map json) => new ErrorRef.fromJson(json);

  ErrorRef();
  ErrorRef.fromJson(Map json) : super.fromJson(json) {
    kind = json['kind'];
    message = json['message'];
  }

  /// What kind of error is this?
  /*ErrorKind*/ String kind;

  /// A description of the error.
  String message;

  String toString() =>
      '[ErrorRef type: ${type}, id: ${id}, kind: ${kind}, message: ${message}]';
}

/// An [Error] represents a Dart language level error. This is distinct from an
/// rpc error.
class Error extends Obj {
  static Error parse(Map json) => new Error.fromJson(json);

  Error();
  Error.fromJson(Map json) : super.fromJson(json) {
    kind = json['kind'];
    message = json['message'];
    exception = createObject(json['exception']);
    stacktrace = createObject(json['stacktrace']);
  }

  /// What kind of error is this?
  /*ErrorKind*/ String kind;

  /// A description of the error.
  String message;

  /// If this error is due to an unhandled exception, this is the exception
  /// thrown.
  @optional InstanceRef exception;

  /// If this error is due to an unhandled exception, this is the stacktrace
  /// object.
  @optional InstanceRef stacktrace;

  String toString() =>
      '[Error type: ${type}, id: ${id}, kind: ${kind}, message: ${message}]';
}

/// An [Event] is an asynchronous notification from the VM. It is delivered only
/// when the client has subscribed to an event stream using the streamListen
/// RPC.
///
/// For more information, see events.
class Event extends Response {
  static Event parse(Map json) => new Event.fromJson(json);

  Event();
  Event.fromJson(Map json) : super.fromJson(json) {
    kind = json['kind'];
    isolate = createObject(json['isolate']);
    vm = createObject(json['vm']);
    timestamp = json['timestamp'];
    breakpoint = createObject(json['breakpoint']);
    pauseBreakpoints = createObject(json['pauseBreakpoints']);
    topFrame = createObject(json['topFrame']);
    exception = createObject(json['exception']);
    bytes = json['bytes'];
  }

  /// What kind of event is this?
  /*EventKind*/ String kind;

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

/// An [FieldRef] is a reference to a [Field].
class FieldRef extends ObjRef {
  static FieldRef parse(Map json) => new FieldRef.fromJson(json);

  FieldRef();
  FieldRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    owner = createObject(json['owner']);
    declaredType = createObject(json['declaredType']);
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

  String toString() => '[FieldRef]';
}

/// A [Field] provides information about a Dart language field or variable.
class Field extends Obj {
  static Field parse(Map json) => new Field.fromJson(json);

  Field();
  Field.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    owner = createObject(json['owner']);
    declaredType = createObject(json['declaredType']);
    isConst = json['const'];
    isFinal = json['final'];
    isStatic = json['static'];
    staticValue = createObject(json['staticValue']);
    location = createObject(json['location']);
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

  String toString() => '[Field]';
}

/// A [Flag] represents a single VM command line flag.
class Flag {
  static Flag parse(Map json) => new Flag.fromJson(json);

  Flag();
  Flag.fromJson(Map json) {
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

/// A [FlagList] represents the complete set of VM command line flags.
class FlagList extends Response {
  static FlagList parse(Map json) => new FlagList.fromJson(json);

  FlagList();
  FlagList.fromJson(Map json) : super.fromJson(json) {
    flags = createObject(json['flags']);
  }

  /// A list of all flags in the VM.
  List<Flag> flags;

  String toString() => '[FlagList type: ${type}, flags: ${flags}]';
}

class Frame extends Response {
  static Frame parse(Map json) => new Frame.fromJson(json);

  Frame();
  Frame.fromJson(Map json) : super.fromJson(json) {
    index = json['index'];
    function = createObject(json['function']);
    code = createObject(json['code']);
    location = createObject(json['location']);
    vars = createObject(json['vars']);
  }

  int index;

  FuncRef function;

  CodeRef code;

  SourceLocation location;

  List<BoundVariable> vars;

  String toString() => '[Frame ' //
      'type: ${type}, index: ${index}, function: ${function}, code: ${code}, location: ${location}, vars: ${vars}]';
}

/// An [FuncRef] is a reference to a [Func].
class FuncRef extends ObjRef {
  static FuncRef parse(Map json) => new FuncRef.fromJson(json);

  FuncRef();
  FuncRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    owner = createObject(json['owner']);
    isStatic = json['static'];
    isConst = json['const'];
  }

  /// The name of this function.
  String name;

  /// The owner of this field, which can be a Library, Class, or a Function.
  ///
  /// [owner] can be one of [LibraryRef], [ClassRef] or [FuncRef].
  dynamic owner;

  /// Is this function static?
  bool isStatic;

  /// Is this function const?
  bool isConst;

  String toString() => '[FuncRef ' //
      'type: ${type}, id: ${id}, name: ${name}, owner: ${owner}, isStatic: ${isStatic}, isConst: ${isConst}]';
}

/// A [Func] represents a Dart language function.
class Func extends Obj {
  static Func parse(Map json) => new Func.fromJson(json);

  Func();
  Func.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    owner = createObject(json['owner']);
    location = createObject(json['location']);
    code = createObject(json['code']);
  }

  /// The name of this function.
  String name;

  /// The owner of this field, which can be a Library, Class, or a Function.
  ///
  /// [owner] can be one of [LibraryRef], [ClassRef] or [FuncRef].
  dynamic owner;

  /// The location of this function in the source code.
  @optional SourceLocation location;

  /// The compiled code associated with this function.
  @optional CodeRef code;

  String toString() =>
      '[Func type: ${type}, id: ${id}, name: ${name}, owner: ${owner}]';
}

/// [InstanceRef] is a reference to an [Instance].
class InstanceRef extends ObjRef {
  static InstanceRef parse(Map json) => new InstanceRef.fromJson(json);

  InstanceRef();
  InstanceRef.fromJson(Map json) : super.fromJson(json) {
    kind = json['kind'];
    classRef = createObject(json['class']);
    valueAsString = json['valueAsString'];
    valueAsStringIsTruncated = json['valueAsStringIsTruncated'] ?? false;
    length = json['length'];
    name = json['name'];
    typeClass = createObject(json['typeClass']);
    parameterizedClass = createObject(json['parameterizedClass']);
    pattern = createObject(json['pattern']);
  }

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

  String toString() =>
      '[InstanceRef type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}]';
}

/// An [Instance] represents an instance of the Dart language class [Obj].
class Instance extends Obj {
  static Instance parse(Map json) => new Instance.fromJson(json);

  Instance();
  Instance.fromJson(Map json) : super.fromJson(json) {
    kind = json['kind'];
    classRef = createObject(json['class']);
    valueAsString = json['valueAsString'];
    valueAsStringIsTruncated = json['valueAsStringIsTruncated'] ?? false;
    length = json['length'];
    offset = json['offset'];
    count = json['count'];
    name = json['name'];
    typeClass = createObject(json['typeClass']);
    parameterizedClass = createObject(json['parameterizedClass']);
    fields = createObject(json['fields']);
    elements = createObject(json['elements']);
    associations = createObject(json['associations']);
    bytes = json['bytes'];
    closureFunction = createObject(json['closureFunction']);
    closureContext = createObject(json['closureContext']);
    mirrorReferent = createObject(json['mirrorReferent']);
    pattern = json['pattern'];
    isCaseSensitive = json['isCaseSensitive'];
    isMultiLine = json['isMultiLine'];
    propertyKey = createObject(json['propertyKey']);
    propertyValue = createObject(json['propertyValue']);
    typeArguments = createObject(json['typeArguments']);
    parameterIndex = json['parameterIndex'];
    targetType = createObject(json['targetType']);
    bound = createObject(json['bound']);
  }

  /// What kind of instance is this?
  /*InstanceKind*/ String kind;

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

  String toString() =>
      '[Instance type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}]';
}

/// [IsolateRef] is a reference to an [Isolate] object.
class IsolateRef extends Response {
  static IsolateRef parse(Map json) => new IsolateRef.fromJson(json);

  IsolateRef();
  IsolateRef.fromJson(Map json) : super.fromJson(json) {
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

  String toString() =>
      '[IsolateRef type: ${type}, id: ${id}, number: ${number}, name: ${name}]';
}

/// An [Isolate] object provides information about one isolate in the VM.
class Isolate extends Response {
  static Isolate parse(Map json) => new Isolate.fromJson(json);

  Isolate();
  Isolate.fromJson(Map json) : super.fromJson(json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
    startTime = json['startTime'];
    livePorts = json['livePorts'];
    pauseOnExit = json['pauseOnExit'];
    pauseEvent = createObject(json['pauseEvent']);
    rootLib = createObject(json['rootLib']);
    libraries = createObject(json['libraries']);
    breakpoints = createObject(json['breakpoints']);
    error = createObject(json['error']);
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

  String toString() => '[Isolate]';
}

/// [LibraryRef] is a reference to a [Library].
class LibraryRef extends ObjRef {
  static LibraryRef parse(Map json) => new LibraryRef.fromJson(json);

  LibraryRef();
  LibraryRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    uri = json['uri'];
  }

  /// The name of this library.
  String name;

  /// The uri of this library.
  String uri;

  String toString() =>
      '[LibraryRef type: ${type}, id: ${id}, name: ${name}, uri: ${uri}]';
}

/// A [Library] provides information about a Dart language library.
///
/// See setLibraryDebuggable.
class Library extends Obj {
  static Library parse(Map json) => new Library.fromJson(json);

  Library();
  Library.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    uri = json['uri'];
    debuggable = json['debuggable'];
    dependencies = createObject(json['dependencies']);
    scripts = createObject(json['scripts']);
    variables = createObject(json['variables']);
    functions = createObject(json['functions']);
    classes = createObject(json['classes']);
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

  String toString() => '[Library]';
}

/// A [LibraryDependency] provides information about an import or export.
class LibraryDependency {
  static LibraryDependency parse(Map json) =>
      new LibraryDependency.fromJson(json);

  LibraryDependency();
  LibraryDependency.fromJson(Map json) {
    isImport = json['isImport'];
    isDeferred = json['isDeferred'];
    prefix = json['prefix'];
    target = createObject(json['target']);
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
      'isImport: ${isImport}, isDeferred: ${isDeferred}, prefix: ${prefix}, target: ${target}]';
}

class MapAssociation {
  static MapAssociation parse(Map json) => new MapAssociation.fromJson(json);

  MapAssociation();
  MapAssociation.fromJson(Map json) {
    key = createObject(json['key']);
    value = createObject(json['value']);
  }

  /// [key] can be one of [InstanceRef] or [Sentinel].
  dynamic key;

  /// [value] can be one of [InstanceRef] or [Sentinel].
  dynamic value;

  String toString() => '[MapAssociation key: ${key}, value: ${value}]';
}

/// A [Message] provides information about a pending isolate message and the
/// function that will be invoked to handle it.
class Message extends Response {
  static Message parse(Map json) => new Message.fromJson(json);

  Message();
  Message.fromJson(Map json) : super.fromJson(json) {
    index = json['index'];
    name = json['name'];
    messageObjectId = json['messageObjectId'];
    size = json['size'];
    handler = createObject(json['handler']);
    location = createObject(json['location']);
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
      'type: ${type}, index: ${index}, name: ${name}, messageObjectId: ${messageObjectId}, size: ${size}]';
}

/// [NullRef] is a reference to an a [Null].
class NullRef extends InstanceRef {
  static NullRef parse(Map json) => new NullRef.fromJson(json);

  NullRef();
  NullRef.fromJson(Map json) : super.fromJson(json) {
    valueAsString = json['valueAsString'];
  }

  /// Always 'null'.
  String valueAsString;

  String toString() => '[NullRef ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}, valueAsString: ${valueAsString}]';
}

/// A [Null] object represents the Dart language value null.
class Null extends Instance {
  static Null parse(Map json) => new Null.fromJson(json);

  Null();
  Null.fromJson(Map json) : super.fromJson(json) {
    valueAsString = json['valueAsString'];
  }

  /// Always 'null'.
  String valueAsString;

  String toString() => '[Null ' //
      'type: ${type}, id: ${id}, kind: ${kind}, classRef: ${classRef}, valueAsString: ${valueAsString}]';
}

/// [ObjRef] is a reference to a [Obj].
class ObjRef extends Response {
  static ObjRef parse(Map json) => new ObjRef.fromJson(json);

  ObjRef();
  ObjRef.fromJson(Map json) : super.fromJson(json) {
    id = json['id'];
  }

  /// A unique identifier for an Object. Passed to the getObject RPC to load
  /// this Object.
  String id;

  String toString() => '[ObjRef type: ${type}, id: ${id}]';
}

/// An [Obj] is a persistent object that is owned by some isolate.
class Obj extends Response {
  static Obj parse(Map json) => new Obj.fromJson(json);

  Obj();
  Obj.fromJson(Map json) : super.fromJson(json) {
    id = json['id'];
    classRef = createObject(json['class']);
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

  String toString() => '[Obj type: ${type}, id: ${id}]';
}

/// Every non-error response returned by the Service Protocol extends
/// [Response]. By using the [type] property, the client can determine which
/// type of response has been provided.
class Response {
  static Response parse(Map json) => new Response.fromJson(json);

  Response();
  Response.fromJson(Map json) {
    type = json['type'];
  }

  /// Every response returned by the VM Service has the type property. This
  /// allows the client distinguish between different kinds of responses.
  String type;

  String toString() => '[Response type: ${type}]';
}

/// A [Sentinel] is used to indicate that the normal response is not available.
///
/// We use a [Sentinel] instead of an error for these cases because they do not
/// represent a problematic condition. They are normal.
class Sentinel extends Response {
  static Sentinel parse(Map json) => new Sentinel.fromJson(json);

  Sentinel();
  Sentinel.fromJson(Map json) : super.fromJson(json) {
    kind = json['kind'];
    valueAsString = json['valueAsString'];
  }

  /// What kind of sentinel is this?
  /*SentinelKind*/ String kind;

  /// A reasonable string representation of this sentinel.
  String valueAsString;

  String toString() =>
      '[Sentinel type: ${type}, kind: ${kind}, valueAsString: ${valueAsString}]';
}

/// [ScriptRef] is a reference to a [Script].
class ScriptRef extends ObjRef {
  static ScriptRef parse(Map json) => new ScriptRef.fromJson(json);

  ScriptRef();
  ScriptRef.fromJson(Map json) : super.fromJson(json) {
    uri = json['uri'];
  }

  /// The uri from which this script was loaded.
  String uri;

  String toString() => '[ScriptRef type: ${type}, id: ${id}, uri: ${uri}]';
}

/// A [Script] provides information about a Dart language script.
///
/// The [tokenPosTable] is an array of int arrays. Each subarray consists of a
/// line number followed by [(tokenPos, columnNumber)] pairs:
class Script extends Obj {
  static Script parse(Map json) => new Script.fromJson(json);

  Script();
  Script.fromJson(Map json) : super.fromJson(json) {
    uri = json['uri'];
    library = createObject(json['library']);
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

  String toString() => '[Script ' //
      'type: ${type}, id: ${id}, uri: ${uri}, library: ${library}, source: ${source}, tokenPosTable: ${tokenPosTable}]';
}

/// The [SourceLocation] class is used to designate a position or range in some
/// script.
class SourceLocation extends Response {
  static SourceLocation parse(Map json) => new SourceLocation.fromJson(json);

  SourceLocation();
  SourceLocation.fromJson(Map json) : super.fromJson(json) {
    script = createObject(json['script']);
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
  static Stack parse(Map json) => new Stack.fromJson(json);

  Stack();
  Stack.fromJson(Map json) : super.fromJson(json) {
    frames = createObject(json['frames']);
    messages = createObject(json['messages']);
  }

  List<Frame> frames;

  List<Message> messages;

  String toString() =>
      '[Stack type: ${type}, frames: ${frames}, messages: ${messages}]';
}

/// The [Success] type is used to indicate that an operation completed
/// successfully.
class Success extends Response {
  static Success parse(Map json) => new Success.fromJson(json);

  Success();
  Success.fromJson(Map json) : super.fromJson(json) {}

  String toString() => '[Success type: ${type}]';
}

/// [TypeArgumentsRef] is a reference to a [TypeArguments] object.
class TypeArgumentsRef extends ObjRef {
  static TypeArgumentsRef parse(Map json) =>
      new TypeArgumentsRef.fromJson(json);

  TypeArgumentsRef();
  TypeArgumentsRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
  }

  /// A name for this type argument list.
  String name;

  String toString() =>
      '[TypeArgumentsRef type: ${type}, id: ${id}, name: ${name}]';
}

/// A [TypeArguments] object represents the type argument vector for some
/// instantiated generic type.
class TypeArguments extends Obj {
  static TypeArguments parse(Map json) => new TypeArguments.fromJson(json);

  TypeArguments();
  TypeArguments.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
    types = createObject(json['types']);
  }

  /// A name for this type argument list.
  String name;

  /// A list of types.
  ///
  /// The value will always be one of the kinds: Type, TypeRef, TypeParameter,
  /// BoundedType.
  List<InstanceRef> types;

  String toString() =>
      '[TypeArguments type: ${type}, id: ${id}, name: ${name}, types: ${types}]';
}

/// The [UnresolvedSourceLocation] class is used to refer to an unresolved
/// breakpoint location. As such, it is meant to approximate the final location
/// of the breakpoint but it is not exact.
///
/// Either the [script] or the [scriptUri] field will be present.
///
/// Either the [tokenPos] or the [line] field will be present.
///
/// The [column] field will only be present when the breakpoint was specified
/// with a specific column number.
class UnresolvedSourceLocation extends Response {
  static UnresolvedSourceLocation parse(Map json) =>
      new UnresolvedSourceLocation.fromJson(json);

  UnresolvedSourceLocation();
  UnresolvedSourceLocation.fromJson(Map json) : super.fromJson(json) {
    script = createObject(json['script']);
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

/// See Versioning.
class Version extends Response {
  static Version parse(Map json) => new Version.fromJson(json);

  Version();
  Version.fromJson(Map json) : super.fromJson(json) {
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

/// [VMRef] is a reference to a [VM] object.
class VMRef extends Response {
  static VMRef parse(Map json) => new VMRef.fromJson(json);

  VMRef();
  VMRef.fromJson(Map json) : super.fromJson(json) {
    name = json['name'];
  }

  /// A name identifying this vm. Not guaranteed to be unique.
  String name;

  String toString() => '[VMRef type: ${type}, name: ${name}]';
}

class VM extends Response {
  static VM parse(Map json) => new VM.fromJson(json);

  VM();
  VM.fromJson(Map json) : super.fromJson(json) {
    architectureBits = json['architectureBits'];
    targetCPU = json['targetCPU'];
    hostCPU = json['hostCPU'];
    version = json['version'];
    pid = json['pid'];
    startTime = json['startTime'];
    isolates = createObject(json['isolates']);
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
