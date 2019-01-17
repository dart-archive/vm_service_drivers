// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is a generated file.

/// A library for asserting correct responses from the VM Service.

import 'package:vm_service_lib/vm_service_lib.dart' as vms;

dynamic assertNotNull(dynamic obj) {
  if (obj == null) throw 'assert failed';
  return obj;
}

bool assertBool(bool obj) {
  assertNotNull(obj);
  return obj;
}

int assertInt(int obj) {
  assertNotNull(obj);
  return obj;
}

double assertDouble(double obj) {
  assertNotNull(obj);
  return obj;
}

List<int> assertInts(List<int> list) {
  for (int elem in list) {
    assertInt(elem);
  }
  return list;
}

List<String> assertStrings(List<String> list) {
  for (String elem in list) {
    assertString(elem);
  }
  return list;
}

String assertString(String obj) {
  assertNotNull(obj);
  if (obj.isEmpty) throw 'expected non-zero length string';
  return obj;
}

vms.Success assertSuccess(vms.Success obj) {
  assertNotNull(obj);
  if (obj.type != 'Success') throw 'expected Success';
  return obj;
}

/// Assert PauseStart, PauseExit, PauseBreakpoint, PauseInterrupted,
/// PauseException, Resume, BreakpointAdded, BreakpointResolved,
/// BreakpointRemoved, and Inspect events.
vms.Event assertDebugEvent(vms.Event event) {
  assertEvent(event);
  if (event.kind == vms.EventKind.kPauseBreakpoint ||
      event.kind == vms.EventKind.kBreakpointAdded ||
      event.kind == vms.EventKind.kBreakpointRemoved ||
      event.kind == vms.EventKind.kBreakpointResolved) {
    assertBreakpoint(event.breakpoint);
  }
  if (event.kind == vms.EventKind.kPauseBreakpoint) {
    for (vms.Breakpoint elem in event.pauseBreakpoints) {
      assertBreakpoint(elem);
    }
  }
  if (event.kind == vms.EventKind.kPauseBreakpoint ||
      event.kind == vms.EventKind.kPauseInterrupted ||
      event.kind == vms.EventKind.kPauseException ||
      event.kind == vms.EventKind.kResume) {
    // For PauseInterrupted events, there will be no top frame if the isolate is
    // idle (waiting in the message loop).
    // For the Resume event, the top frame is provided at all times except for
    // the initial resume event that is delivered when an isolate begins
    // execution.
    if (event.topFrame != null ||
        (event.kind != vms.EventKind.kPauseInterrupted &&
            event.kind != vms.EventKind.kResume)) {
      assertFrame(event.topFrame);
    }
  }
  if (event.kind == vms.EventKind.kPauseException) {
    assertInstanceRef(event.exception);
  }
  if (event.kind == vms.EventKind.kPauseBreakpoint ||
      event.kind == vms.EventKind.kPauseInterrupted) {
    assertBool(event.atAsyncSuspension);
  }
  if (event.kind == vms.EventKind.kInspect) {
    assertInstanceRef(event.inspectee);
  }
  return event;
}

/// Assert IsolateStart, IsolateRunnable, IsolateExit, IsolateUpdate,
/// and ServiceExtensionAdded events.
vms.Event assertIsolateEvent(vms.Event event) {
  assertEvent(event);
  if (event.kind == vms.EventKind.kServiceExtensionAdded) {
    assertString(event.extensionRPC);
  }
  return event;
}

String assertCodeKind(String obj) {
  if (obj == "Collected") return obj;
  if (obj == "Dart") return obj;
  if (obj == "Native") return obj;
  if (obj == "Stub") return obj;
  if (obj == "Tag") return obj;
  throw "invalid CodeKind: $obj";
}

String assertErrorKind(String obj) {
  if (obj == "InternalError") return obj;
  if (obj == "LanguageError") return obj;
  if (obj == "TerminationError") return obj;
  if (obj == "UnhandledException") return obj;
  throw "invalid ErrorKind: $obj";
}

String assertEventKind(String obj) {
  if (obj == "BreakpointAdded") return obj;
  if (obj == "BreakpointRemoved") return obj;
  if (obj == "BreakpointResolved") return obj;
  if (obj == "Extension") return obj;
  if (obj == "GC") return obj;
  if (obj == "Inspect") return obj;
  if (obj == "IsolateExit") return obj;
  if (obj == "IsolateReload") return obj;
  if (obj == "IsolateRunnable") return obj;
  if (obj == "IsolateStart") return obj;
  if (obj == "IsolateUpdate") return obj;
  if (obj == "None") return obj;
  if (obj == "PauseBreakpoint") return obj;
  if (obj == "PauseException") return obj;
  if (obj == "PauseExit") return obj;
  if (obj == "PauseInterrupted") return obj;
  if (obj == "PausePostRequest") return obj;
  if (obj == "PauseStart") return obj;
  if (obj == "Resume") return obj;
  if (obj == "ServiceExtensionAdded") return obj;
  if (obj == "ServiceRegistered") return obj;
  if (obj == "ServiceUnregistered") return obj;
  if (obj == "VMUpdate") return obj;
  if (obj == "WriteEvent") return obj;
  throw "invalid EventKind: $obj";
}

String assertInstanceKind(String obj) {
  if (obj == "Bool") return obj;
  if (obj == "BoundedType") return obj;
  if (obj == "Closure") return obj;
  if (obj == "Double") return obj;
  if (obj == "Float32List") return obj;
  if (obj == "Float32x4") return obj;
  if (obj == "Float32x4List") return obj;
  if (obj == "Float64List") return obj;
  if (obj == "Float64x2") return obj;
  if (obj == "Float64x2List") return obj;
  if (obj == "Int") return obj;
  if (obj == "Int16List") return obj;
  if (obj == "Int32List") return obj;
  if (obj == "Int32x4") return obj;
  if (obj == "Int32x4List") return obj;
  if (obj == "Int64List") return obj;
  if (obj == "Int8List") return obj;
  if (obj == "List") return obj;
  if (obj == "Map") return obj;
  if (obj == "MirrorReference") return obj;
  if (obj == "Null") return obj;
  if (obj == "PlainInstance") return obj;
  if (obj == "RegExp") return obj;
  if (obj == "StackTrace") return obj;
  if (obj == "String") return obj;
  if (obj == "Type") return obj;
  if (obj == "TypeParameter") return obj;
  if (obj == "TypeRef") return obj;
  if (obj == "Uint16List") return obj;
  if (obj == "Uint32List") return obj;
  if (obj == "Uint64List") return obj;
  if (obj == "Uint8ClampedList") return obj;
  if (obj == "Uint8List") return obj;
  if (obj == "WeakProperty") return obj;
  throw "invalid InstanceKind: $obj";
}

String assertSentinelKind(String obj) {
  if (obj == "BeingInitialized") return obj;
  if (obj == "Collected") return obj;
  if (obj == "Expired") return obj;
  if (obj == "Free") return obj;
  if (obj == "NotInitialized") return obj;
  if (obj == "OptimizedOut") return obj;
  throw "invalid SentinelKind: $obj";
}

String assertFrameKind(String obj) {
  if (obj == "AsyncActivation") return obj;
  if (obj == "AsyncCausal") return obj;
  if (obj == "AsyncSuspensionMarker") return obj;
  if (obj == "Regular") return obj;
  throw "invalid FrameKind: $obj";
}

String assertSourceReportKind(String obj) {
  if (obj == "Coverage") return obj;
  if (obj == "PossibleBreakpoints") return obj;
  throw "invalid SourceReportKind: $obj";
}

String assertExceptionPauseMode(String obj) {
  if (obj == "All") return obj;
  if (obj == "None") return obj;
  if (obj == "Unhandled") return obj;
  throw "invalid ExceptionPauseMode: $obj";
}

String assertStepOption(String obj) {
  if (obj == "Into") return obj;
  if (obj == "Out") return obj;
  if (obj == "Over") return obj;
  if (obj == "OverAsyncSuspension") return obj;
  if (obj == "Rewind") return obj;
  throw "invalid StepOption: $obj";
}

vms.BoundField assertBoundField(vms.BoundField obj) {
  assertNotNull(obj);
  assertFieldRef(obj.decl);
  if (obj.value is vms.InstanceRef) {
    assertInstanceRef(obj.value);
  } else if (obj.value is vms.Sentinel) {
    assertSentinel(obj.value);
  } else {
    throw "Unexpected value: ${obj.value}";
  }
  return obj;
}

vms.BoundVariable assertBoundVariable(vms.BoundVariable obj) {
  assertNotNull(obj);
  assertString(obj.name);
  if (obj.value is vms.InstanceRef) {
    assertInstanceRef(obj.value);
  } else if (obj.value is vms.TypeArgumentsRef) {
    assertTypeArgumentsRef(obj.value);
  } else if (obj.value is vms.Sentinel) {
    assertSentinel(obj.value);
  } else {
    throw "Unexpected value: ${obj.value}";
  }
  assertInt(obj.declarationTokenPos);
  assertInt(obj.scopeStartTokenPos);
  assertInt(obj.scopeEndTokenPos);
  return obj;
}

List<vms.BoundVariable> assertBoundVariables(List<vms.BoundVariable> list) {
  for (vms.BoundVariable elem in list) {
    assertBoundVariable(elem);
  }
  return list;
}

vms.Breakpoint assertBreakpoint(vms.Breakpoint obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInt(obj.breakpointNumber);
  assertBool(obj.resolved);
  if (obj.location is vms.SourceLocation) {
    assertSourceLocation(obj.location);
  } else if (obj.location is vms.UnresolvedSourceLocation) {
    assertUnresolvedSourceLocation(obj.location);
  } else {
    throw "Unexpected value: ${obj.location}";
  }
  return obj;
}

List<vms.Breakpoint> assertBreakpoints(List<vms.Breakpoint> list) {
  for (vms.Breakpoint elem in list) {
    assertBreakpoint(elem);
  }
  return list;
}

vms.ClassRef assertClassRef(vms.ClassRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  return obj;
}

List<vms.ClassRef> assertClassRefs(List<vms.ClassRef> list) {
  for (vms.ClassRef elem in list) {
    assertClassRef(elem);
  }
  return list;
}

vms.Class assertClass(vms.Class obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertBool(obj.isAbstract);
  assertBool(obj.isConst);
  assertObjRef(obj.library);
  assertInstanceRefs(obj.interfaces);
  assertFieldRefs(obj.fields);
  assertFuncRefs(obj.functions);
  assertClassRefs(obj.subclasses);
  return obj;
}

vms.ClassList assertClassList(vms.ClassList obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertClassRefs(obj.classes);
  return obj;
}

vms.CodeRef assertCodeRef(vms.CodeRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertCodeKind(obj.kind);
  return obj;
}

List<vms.CodeRef> assertCodeRefs(List<vms.CodeRef> list) {
  for (vms.CodeRef elem in list) {
    assertCodeRef(elem);
  }
  return list;
}

vms.Code assertCode(vms.Code obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertCodeKind(obj.kind);
  return obj;
}

vms.ContextRef assertContextRef(vms.ContextRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInt(obj.length);
  return obj;
}

List<vms.ContextRef> assertContextRefs(List<vms.ContextRef> list) {
  for (vms.ContextRef elem in list) {
    assertContextRef(elem);
  }
  return list;
}

vms.Context assertContext(vms.Context obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInt(obj.length);
  assertContextElements(obj.variables);
  return obj;
}

vms.ContextElement assertContextElement(vms.ContextElement obj) {
  assertNotNull(obj);
  if (obj.value is vms.InstanceRef) {
    assertInstanceRef(obj.value);
  } else if (obj.value is vms.Sentinel) {
    assertSentinel(obj.value);
  } else {
    throw "Unexpected value: ${obj.value}";
  }
  return obj;
}

List<vms.ContextElement> assertContextElements(List<vms.ContextElement> list) {
  for (vms.ContextElement elem in list) {
    assertContextElement(elem);
  }
  return list;
}

vms.ErrorRef assertErrorRef(vms.ErrorRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertErrorKind(obj.kind);
  assertString(obj.message);
  return obj;
}

List<vms.ErrorRef> assertErrorRefs(List<vms.ErrorRef> list) {
  for (vms.ErrorRef elem in list) {
    assertErrorRef(elem);
  }
  return list;
}

vms.Error assertError(vms.Error obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertErrorKind(obj.kind);
  assertString(obj.message);
  return obj;
}

vms.Event assertEvent(vms.Event obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertEventKind(obj.kind);
  assertInt(obj.timestamp);
  return obj;
}

vms.ExtensionData assertExtensionData(vms.ExtensionData obj) {
  assertNotNull(obj);
  return obj;
}

vms.FieldRef assertFieldRef(vms.FieldRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertObjRef(obj.owner);
  assertInstanceRef(obj.declaredType);
  assertBool(obj.isConst);
  assertBool(obj.isFinal);
  assertBool(obj.isStatic);
  return obj;
}

List<vms.FieldRef> assertFieldRefs(List<vms.FieldRef> list) {
  for (vms.FieldRef elem in list) {
    assertFieldRef(elem);
  }
  return list;
}

vms.Field assertField(vms.Field obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertObjRef(obj.owner);
  assertInstanceRef(obj.declaredType);
  assertBool(obj.isConst);
  assertBool(obj.isFinal);
  assertBool(obj.isStatic);
  return obj;
}

vms.Flag assertFlag(vms.Flag obj) {
  assertNotNull(obj);
  assertString(obj.name);
  assertString(obj.comment);
  assertBool(obj.modified);
  return obj;
}

List<vms.Flag> assertFlags(List<vms.Flag> list) {
  for (vms.Flag elem in list) {
    assertFlag(elem);
  }
  return list;
}

vms.FlagList assertFlagList(vms.FlagList obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertFlags(obj.flags);
  return obj;
}

vms.Frame assertFrame(vms.Frame obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertInt(obj.index);
  return obj;
}

List<vms.Frame> assertFrames(List<vms.Frame> list) {
  for (vms.Frame elem in list) {
    assertFrame(elem);
  }
  return list;
}

vms.FuncRef assertFuncRef(vms.FuncRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  if (obj.owner is vms.LibraryRef) {
    assertLibraryRef(obj.owner);
  } else if (obj.owner is vms.ClassRef) {
    assertClassRef(obj.owner);
  } else if (obj.owner is vms.FuncRef) {
    assertFuncRef(obj.owner);
  } else {
    throw "Unexpected value: ${obj.owner}";
  }
  assertBool(obj.isStatic);
  assertBool(obj.isConst);
  return obj;
}

List<vms.FuncRef> assertFuncRefs(List<vms.FuncRef> list) {
  for (vms.FuncRef elem in list) {
    assertFuncRef(elem);
  }
  return list;
}

vms.Func assertFunc(vms.Func obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  if (obj.owner is vms.LibraryRef) {
    assertLibraryRef(obj.owner);
  } else if (obj.owner is vms.ClassRef) {
    assertClassRef(obj.owner);
  } else if (obj.owner is vms.FuncRef) {
    assertFuncRef(obj.owner);
  } else {
    throw "Unexpected value: ${obj.owner}";
  }
  return obj;
}

vms.InstanceRef assertInstanceRef(vms.InstanceRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInstanceKind(obj.kind);
  assertClassRef(obj.classRef);
  return obj;
}

List<vms.InstanceRef> assertInstanceRefs(List<vms.InstanceRef> list) {
  for (vms.InstanceRef elem in list) {
    assertInstanceRef(elem);
  }
  return list;
}

vms.Instance assertInstance(vms.Instance obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInstanceKind(obj.kind);
  return obj;
}

vms.IsolateRef assertIsolateRef(vms.IsolateRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.number);
  assertString(obj.name);
  return obj;
}

List<vms.IsolateRef> assertIsolateRefs(List<vms.IsolateRef> list) {
  for (vms.IsolateRef elem in list) {
    assertIsolateRef(elem);
  }
  return list;
}

vms.Isolate assertIsolate(vms.Isolate obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.number);
  assertString(obj.name);
  assertInt(obj.startTime);
  assertBool(obj.runnable);
  assertInt(obj.livePorts);
  assertBool(obj.pauseOnExit);
  assertEvent(obj.pauseEvent);
  assertLibraryRefs(obj.libraries);
  assertBreakpoints(obj.breakpoints);
  assertExceptionPauseMode(obj.exceptionPauseMode);
  return obj;
}

vms.LibraryRef assertLibraryRef(vms.LibraryRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertString(obj.uri);
  return obj;
}

List<vms.LibraryRef> assertLibraryRefs(List<vms.LibraryRef> list) {
  for (vms.LibraryRef elem in list) {
    assertLibraryRef(elem);
  }
  return list;
}

vms.Library assertLibrary(vms.Library obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertString(obj.uri);
  assertBool(obj.debuggable);
  assertLibraryDependencies(obj.dependencies);
  assertScriptRefs(obj.scripts);
  assertFieldRefs(obj.variables);
  assertFuncRefs(obj.functions);
  assertClassRefs(obj.classes);
  return obj;
}

vms.LibraryDependency assertLibraryDependency(vms.LibraryDependency obj) {
  assertNotNull(obj);
  assertBool(obj.isImport);
  assertBool(obj.isDeferred);
  assertString(obj.prefix);
  assertLibraryRef(obj.target);
  return obj;
}

List<vms.LibraryDependency> assertLibraryDependencies(
    List<vms.LibraryDependency> list) {
  for (vms.LibraryDependency elem in list) {
    assertLibraryDependency(elem);
  }
  return list;
}

vms.MapAssociation assertMapAssociation(vms.MapAssociation obj) {
  assertNotNull(obj);
  if (obj.key is vms.InstanceRef) {
    assertInstanceRef(obj.key);
  } else if (obj.key is vms.Sentinel) {
    assertSentinel(obj.key);
  } else {
    throw "Unexpected value: ${obj.key}";
  }
  if (obj.value is vms.InstanceRef) {
    assertInstanceRef(obj.value);
  } else if (obj.value is vms.Sentinel) {
    assertSentinel(obj.value);
  } else {
    throw "Unexpected value: ${obj.value}";
  }
  return obj;
}

vms.Message assertMessage(vms.Message obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertInt(obj.index);
  assertString(obj.name);
  assertString(obj.messageObjectId);
  assertInt(obj.size);
  return obj;
}

List<vms.Message> assertMessages(List<vms.Message> list) {
  for (vms.Message elem in list) {
    assertMessage(elem);
  }
  return list;
}

vms.NullValRef assertNullValRef(vms.NullValRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInstanceKind(obj.kind);
  assertClassRef(obj.classRef);
  return obj;
}

List<vms.NullValRef> assertNullValRefs(List<vms.NullValRef> list) {
  for (vms.NullValRef elem in list) {
    assertNullValRef(elem);
  }
  return list;
}

vms.NullVal assertNullVal(vms.NullVal obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertInstanceKind(obj.kind);
  return obj;
}

vms.ObjRef assertObjRef(vms.ObjRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  return obj;
}

List<vms.ObjRef> assertObjRefs(List<vms.ObjRef> list) {
  for (vms.ObjRef elem in list) {
    assertObjRef(elem);
  }
  return list;
}

vms.Obj assertObj(vms.Obj obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  return obj;
}

vms.ReloadReport assertReloadReport(vms.ReloadReport obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertBool(obj.success);
  return obj;
}

vms.Response assertResponse(vms.Response obj) {
  assertNotNull(obj);
  assertString(obj.type);
  return obj;
}

vms.Sentinel assertSentinel(vms.Sentinel obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertSentinelKind(obj.kind);
  assertString(obj.valueAsString);
  return obj;
}

vms.ScriptRef assertScriptRef(vms.ScriptRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.uri);
  return obj;
}

List<vms.ScriptRef> assertScriptRefs(List<vms.ScriptRef> list) {
  for (vms.ScriptRef elem in list) {
    assertScriptRef(elem);
  }
  return list;
}

vms.Script assertScript(vms.Script obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.uri);
  assertLibraryRef(obj.library);
  return obj;
}

vms.ScriptList assertScriptList(vms.ScriptList obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertScriptRefs(obj.scripts);
  return obj;
}

vms.SourceLocation assertSourceLocation(vms.SourceLocation obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertScriptRef(obj.script);
  assertInt(obj.tokenPos);
  return obj;
}

vms.SourceReport assertSourceReport(vms.SourceReport obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertSourceReportRanges(obj.ranges);
  assertScriptRefs(obj.scripts);
  return obj;
}

vms.SourceReportCoverage assertSourceReportCoverage(
    vms.SourceReportCoverage obj) {
  assertNotNull(obj);
  assertInts(obj.hits);
  assertInts(obj.misses);
  return obj;
}

vms.SourceReportRange assertSourceReportRange(vms.SourceReportRange obj) {
  assertNotNull(obj);
  assertInt(obj.scriptIndex);
  assertInt(obj.startPos);
  assertInt(obj.endPos);
  assertBool(obj.compiled);
  return obj;
}

List<vms.SourceReportRange> assertSourceReportRanges(
    List<vms.SourceReportRange> list) {
  for (vms.SourceReportRange elem in list) {
    assertSourceReportRange(elem);
  }
  return list;
}

vms.Stack assertStack(vms.Stack obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertFrames(obj.frames);
  assertMessages(obj.messages);
  return obj;
}

vms.TimelineEvent assertTimelineEvent(vms.TimelineEvent obj) {
  assertNotNull(obj);
  return obj;
}

vms.TypeArgumentsRef assertTypeArgumentsRef(vms.TypeArgumentsRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  return obj;
}

List<vms.TypeArgumentsRef> assertTypeArgumentsRefs(
    List<vms.TypeArgumentsRef> list) {
  for (vms.TypeArgumentsRef elem in list) {
    assertTypeArgumentsRef(elem);
  }
  return list;
}

vms.TypeArguments assertTypeArguments(vms.TypeArguments obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.id);
  assertString(obj.name);
  assertInstanceRefs(obj.types);
  return obj;
}

vms.UnresolvedSourceLocation assertUnresolvedSourceLocation(
    vms.UnresolvedSourceLocation obj) {
  assertNotNull(obj);
  assertString(obj.type);
  return obj;
}

vms.Version assertVersion(vms.Version obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertInt(obj.major);
  assertInt(obj.minor);
  return obj;
}

vms.VMRef assertVMRef(vms.VMRef obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.name);
  return obj;
}

List<vms.VMRef> assertVMRefs(List<vms.VMRef> list) {
  for (vms.VMRef elem in list) {
    assertVMRef(elem);
  }
  return list;
}

vms.VM assertVM(vms.VM obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertInt(obj.architectureBits);
  assertString(obj.targetCPU);
  assertString(obj.hostCPU);
  assertString(obj.version);
  assertInt(obj.pid);
  assertInt(obj.startTime);
  assertIsolateRefs(obj.isolates);
  return obj;
}

vms.CpuProfile assert_CpuProfile(vms.CpuProfile obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertInt(obj.sampleCount);
  assertInt(obj.samplePeriod);
  assertInt(obj.stackDepth);
  assertDouble(obj.timeSpan);
  assertInt(obj.timeOriginMicros);
  assertInt(obj.timeExtentMicros);
  assertCodeRegions(obj.codes);
  assertProfileFunctions(obj.functions);
  assertInts(obj.exclusiveCodeTrie);
  assertInts(obj.inclusiveCodeTrie);
  assertInts(obj.exclusiveFunctionTrie);
  assertInts(obj.inclusiveFunctionTrie);
  return obj;
}

vms.CodeRegion assertCodeRegion(vms.CodeRegion obj) {
  assertNotNull(obj);
  assertString(obj.kind);
  assertInt(obj.inclusiveTicks);
  assertInt(obj.exclusiveTicks);
  assertCodeRef(obj.code);
  return obj;
}

List<vms.CodeRegion> assertCodeRegions(List<vms.CodeRegion> list) {
  for (vms.CodeRegion elem in list) {
    assertCodeRegion(elem);
  }
  return list;
}

vms.ProfileFunction assertProfileFunction(vms.ProfileFunction obj) {
  assertNotNull(obj);
  assertString(obj.kind);
  assertInt(obj.inclusiveTicks);
  assertInt(obj.exclusiveTicks);
  assertFuncRef(obj.function);
  assertInts(obj.codes);
  return obj;
}

List<vms.ProfileFunction> assertProfileFunctions(
    List<vms.ProfileFunction> list) {
  for (vms.ProfileFunction elem in list) {
    assertProfileFunction(elem);
  }
  return list;
}

vms.AllocationProfile assertAllocationProfile(vms.AllocationProfile obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertString(obj.dateLastServiceGC);
  assertClassHeapStatss(obj.members);
  return obj;
}

vms.ClassHeapStats assertClassHeapStats(vms.ClassHeapStats obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertClassRef(obj.classRef);
  assertInts(obj.new_);
  assertInts(obj.old);
  assertInt(obj.promotedBytes);
  assertInt(obj.promotedInstances);
  return obj;
}

List<vms.ClassHeapStats> assertClassHeapStatss(List<vms.ClassHeapStats> list) {
  for (vms.ClassHeapStats elem in list) {
    assertClassHeapStats(elem);
  }
  return list;
}

vms.HeapSpace assertHeapSpace(vms.HeapSpace obj) {
  assertNotNull(obj);
  assertString(obj.type);
  assertDouble(obj.avgCollectionPeriodMillis);
  assertInt(obj.capacity);
  assertInt(obj.collections);
  assertInt(obj.external);
  assertString(obj.name);
  assertDouble(obj.time);
  assertInt(obj.used);
  return obj;
}
