// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library generate_vm_service_lib_java;

import 'package:markdown/markdown.dart';

import '../common/parser.dart';
import '../common/src_gen_common.dart';
import 'src_gen_java.dart';

export 'src_gen_java.dart' show JavaGenerator;

Api api;

String _coerceRefType(String typeName) {
  if (typeName == 'Object') typeName = 'Obj';
  if (typeName == '@Object') typeName = 'ObjRef';
  if (typeName == 'Function') typeName = 'Func';
  if (typeName == '@Function') typeName = 'FuncRef';
  if (typeName.startsWith('@')) typeName = typeName.substring(1) + 'Ref';
  if (typeName == 'string') typeName = 'String';
  return typeName;
}

class Api extends Member {
  List<Method> methods = [];
  List<Enum> enums = [];
  List<Type> types = [];

  String get docs => null;

  String get name => 'api';

  void addProperty(String typeName, String propertyName, {String javadoc}) {
    var t = types.firstWhere((t) => t.name == 'LibraryRef');
    for (var f in t.fields) {
      if (f.name == propertyName) {
        print('$typeName already has $propertyName field');
        return;
      }
    }
    var f = new TypeField(t, javadoc);
    f.name = propertyName;
    f.type = new MemberType();
    f.type.types = [new TypeRef('String')];
    t.fields.add(f);
    print('added $propertyName field to $typeName');
  }

  void generate(JavaGenerator gen) {
    _setFileHeader();

    // Add undocumented "id" property
    addProperty('LibraryRef', 'id', javadoc: 'The id of this library.');

    // Hack to populate method argument docs
    for (var m in methods) {
      for (var a in m.args) {
        if (a.hasDocs) continue;
        var t = types.firstWhere((t) => t.name == a.type, orElse: () => null);
        if (t != null) {
          a.docs = t.docs;
          continue;
        }
        var e = enums.firstWhere((e) => e.name == a.type, orElse: () => null);
        if (e != null) {
          a.docs = e.docs;
          continue;
        }
      }
    }

    gen.writeType('com.google.dart.observatory.Observatory',
        (TypeWriter writer) {
      writer.addImport('com.google.gson.JsonObject');
      writer.addImport('com.google.dart.observatory.consumer.*');
      writer.addImport('com.google.dart.observatory.element.*');
      writer.superclassName = 'com.google.dart.observatory.ObservatoryBase';
      for (var m in methods) {
        m.generateObservatoryMethod(writer);
      }
      writer.addMethod('forwardResponse', [
        new JavaMethodArg('consumer', 'Consumer'),
        new JavaMethodArg('responseType', 'String'),
        new JavaMethodArg('json', 'JsonObject')
      ], (StatementWriter writer) {
        var generatedForwards = new Set<String>();

        var sorted = methods.toList()
          ..removeWhere((m) {
            if (m.returnType.isMultipleReturns) {
              print('skipped forward for ${m.returnType.name}');
              return true;
            } else {
              return false;
            }
          })
          ..sort((m1, m2) {
            return m1.returnType.consumerTypeName
                .compareTo(m2.returnType.consumerTypeName);
          });
        for (var m in sorted) {
          if (generatedForwards.add(m.returnType.consumerTypeName)) {
            m.generateObservatoryForward(writer);
          }
        }
        writer.addLine('logUnknownResponse(consumer, json);');
      }, modifiers: null);
    });

    var generatedConsumers = new Set<String>();
    for (var m in methods) {
      if (generatedConsumers.add(m.returnType.consumerTypeName)) {
        m.generateConsumerInterface(gen);
      }
    }
    for (var t in types) {
      t.generateElement(gen);
    }
    for (var e in enums) {
      e.generateEnum(gen);
    }

// gen.write('Map<String, Function> _typeFactories = {');
// types.forEach((Type type) {
//   //if (type.isResponse)
//   gen.write("'${type.rawName}': ${type.name}.parse");
//   gen.writeln(type == types.last ? '' : ',');
// });
// gen.writeln('};');
// gen.writeln();
// gen.writeStatement('class Observatory {');
// gen.writeStatement('StreamSubscription _streamSub;');
// gen.writeStatement('Function _writeMessage;');
// gen.writeStatement('int _id = 0;');
// gen.writeStatement('Map<String, Completer> _completers = {};');
// gen.writeln();
// gen.writeln("StreamController _onSend = new StreamController.broadcast();");
// gen.writeln("StreamController _onReceive = new StreamController.broadcast();");
// gen.writeln();
// gen.writeln("StreamController<Event> _isolateController = new StreamController.broadcast();");
// gen.writeln("StreamController<Event> _debugController = new StreamController.broadcast();");
// gen.writeln("StreamController<Event> _gcController = new StreamController.broadcast();");
// gen.writeln("StreamController<Event> _stdoutController = new StreamController.broadcast();");
// gen.writeln("StreamController<Event> _stderrController = new StreamController.broadcast();");
// gen.writeln();
// gen.writeStatement(
//     'Observatory(Stream<String> inStream, void writeMessage(String message)) {');
// gen.writeStatement('_streamSub = inStream.listen(_processMessage);');
// gen.writeStatement('_writeMessage = writeMessage;');
// gen.writeln('}');
// gen.writeln();
// gen.writeln("Stream<Event> get onIsolateEvent => _isolateController.stream;");
// gen.writeln("Stream<Event> get onDebugEvent => _debugController.stream;");
// gen.writeln("Stream<Event> get onGcEvent => _gcController.stream;");
// gen.writeln("Stream<Event> get onStdoutEvent => _stdoutController.stream;");
// gen.writeln("Stream<Event> get onStderrEvent => _stderrController.stream;");
// gen.writeln();
// methods.forEach((m) => m.generate(gen));
// gen.out(_implCode);
// gen.writeStatement('}');
// gen.writeln();
// gen.writeln(_rpcError);
// gen.writeln('// enums');
// enums.forEach((e) => e.generate(gen));
// gen.writeln();
// gen.writeln('// types');
// types.forEach((t) => t.generate(gen));
  }

  Type getType(String name) =>
      types.firstWhere((t) => t.name == name, orElse: () => null);

  bool isEnumName(String typeName) => enums.any((Enum e) => e.name == typeName);

  void parse(List<Node> nodes) {
    // Look for h3 nodes
    // the pre following it is the definition
    // the optional p following that is the dcumentation

    String h3Name = null;

    for (int i = 0; i < nodes.length; i++) {
      Node node = nodes[i];

      if (isPre(node) && h3Name != null) {
        String definition = textForCode(node);
        String docs = null;

        if (i + 1 < nodes.length && isPara(nodes[i + 1])) {
          Element p = nodes[++i];
          docs = collapseWhitespace(TextOutputVisitor.printText(p));
        }

        _parse(h3Name, definition, docs);
      } else if (isH3(node)) {
        h3Name = textForElement(node);
      } else if (isHeader(node)) {
        h3Name = null;
      }
    }
  }

  void _parse(String name, String definition, [String docs]) {
    name = name.trim();
    definition = definition.trim();
    if (docs != null) docs = docs.trim();

    if (name.substring(0, 1).toLowerCase() == name.substring(0, 1)) {
      methods.add(new Method(name, definition, docs));
    } else if (definition.startsWith('class ')) {
      types.add(new Type(this, name, definition, docs));
    } else if (definition.startsWith('enum ')) {
      enums.add(new Enum(name, definition, docs));
    } else {
      throw 'unexpected entity: ${name}, ${definition}';
    }
  }

  void _setFileHeader() {
    fileHeader = r'''/*
 * Copyright (c) 2015, the Dart project authors.
 *
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
''';
  }

  static String printNode(Node n) {
    if (n is Text) {
      return n.text;
    } else if (n is Element) {
      if (n.tag != 'h3') return n.tag;
      return '${n.tag}:[${n.children.map((c) => printNode(c)).join(', ')}]';
    } else {
      return '${n}';
    }
  }
}

class Enum extends Member {
  final String name;
  final String docs;

  List<EnumValue> enums = [];

  Enum(this.name, String definition, [this.docs]) {
    _parse(new Tokenizer(definition).tokenize());
  }

  String get elementTypeName => 'com.google.dart.observatory.element.$name';

  void generateEnum(JavaGenerator gen) {
    gen.writeType(elementTypeName, (TypeWriter writer) {
      writer.javadoc = docs;
      writer.isEnum = true;
      int count = 0;
      for (var value in enums) {
        ++count;
        writer.addEnumValue(value.name,
            javadoc: value.docs, isLast: count == enums.length);
      }
    });
  }

  void _parse(Token token) {
    new EnumParser(token).parseInto(this);
  }
}

class EnumParser extends Parser {
  EnumParser(Token startToken) : super(startToken);

  void parseInto(Enum e) {
    // enum ErrorKind { UnhandledException, Foo, Bar }
    // enum name { (comment* name ,)+ }
    expect('enum');

    Token t = expectName();
    validate(t.text == e.name, 'enum name ${e.name} equals ${t.text}');
    expect('{');

    while (!t.eof) {
      if (consume('}')) break;
      String docs = collectComments();
      t = expectName();
      consume(',');

      e.enums.add(new EnumValue(e, t.text, docs));
    }
  }
}

class EnumValue extends Member {
  final Enum parent;
  final String name;
  final String docs;

  EnumValue(this.parent, this.name, [this.docs]);

  bool get isLast => parent.enums.last == this;
}

abstract class Member {
  String get docs => null;
  bool get hasDocs => docs != null;

  String get name;

  String toString() => name;
}

class MemberType extends Member {
  List<TypeRef> types = [];

  MemberType();

  String get consumerTypeName {
    if (types.isEmpty) return null;
    if (types.length == 1) {
      return 'com.google.dart.observatory.consumer.${types.first.ref}Consumer';
    }
    return null;
  }

  bool get isEnum => types.length == 1 && api.isEnumName(types.first.name);

  bool get isMultipleReturns => types.length > 1;

  bool get isSimple => types.length == 1 && types.first.isSimple;

  String get name {
    if (types.isEmpty) return '';
    if (types.length == 1) return types.first.ref;
    return 'dynamic';
  }

  void parse(Parser parser) {
    // foo|bar[]|baz
    bool loop = true;
    while (loop) {
      Token t = parser.expectName();
      TypeRef ref = new TypeRef(_coerceRefType(t.text));
      while (parser.consume('[')) {
        parser.expect(']');
        ref.arrayDepth++;
      }
      types.add(ref);
      loop = parser.consume('|');
    }
  }
}

class Method extends Member {
  final String name;
  final String docs;

  MemberType returnType = new MemberType();
  List<MethodArg> args = [];

  Method(this.name, String definition, [this.docs]) {
    _parse(new Tokenizer(definition).tokenize());
  }

  bool get hasArgs => args.isNotEmpty;

  bool get hasOptionalArgs => args.any((MethodArg arg) => arg.optional);

  void generateConsumerInterface(JavaGenerator gen) {
    // TODO Generate consumer for dynamic
    if (returnType.isMultipleReturns) {
      print('skipped consumer $name');
      return;
    }

    gen.writeType(returnType.consumerTypeName, (TypeWriter writer) {
      writer.javadoc = returnType.docs;
      writer.interfaceNames
          .add('com.google.dart.observatory.consumer.Consumer');
      writer.isInterface = true;
      for (var t in returnType.types) {
        writer.addImport(t.elementTypeName);
        writer.addMethod("received",
            [new JavaMethodArg('response', t.elementTypeName)], null);
      }
    });
  }

  void generateObservatoryForward(StatementWriter writer) {
    var jsonType = returnType.name;
    var consumerName = classNameFor(returnType.consumerTypeName);
    for (var t in returnType.types) {
      var responseName = classNameFor(t.elementTypeName);
      writer.addLine('if (consumer instanceof $consumerName) {');
      writer.addLine('  $responseName response = new $responseName(json);');
      writer.addLine('  if (responseType.equals("$jsonType")) {');
      writer.addLine('    (($consumerName) consumer).received(response);');
      writer.addLine('    return;');
      writer.addLine('  }');
      writer.addLine('}');
    }
  }

  void generateObservatoryMethod(TypeWriter writer) {
    // TODO(danrubel) move this to the Consumer's javadoc
//    String javadoc = docs == null ? '' : docs;
//    if (returnType.isMultipleReturns) {
//      javadoc += '\n\nThe return value can be one of '
//          '${joinLast(returnType.types.map((t) => '[${t}]'), ', ', ' or ')}.';
//      javadoc = javadoc.trim();
//    }

    // Update method docs
    var javadoc = new StringBuffer(docs);
    bool firstParamDoc = true;
    for (var a in args) {
      var paramDoc = new StringBuffer(a.docs ?? '');
      if (paramDoc.isEmpty) {}
      if (a.optional) {
        if (paramDoc.isNotEmpty) paramDoc.write(' ');
        paramDoc.write('This parameter is optional and may be null.');
      }
      if (paramDoc.isNotEmpty) {
        if (firstParamDoc) {
          javadoc.writeln();
          javadoc.writeln();
          firstParamDoc = false;
        }
        javadoc.writeln('@param ${a.name} $paramDoc');
      }
    }

    var mthArgs = args.map((a) => a.asJavaMethodArg).toList();
    if (!returnType.isMultipleReturns) {
      mthArgs.add(new JavaMethodArg(
          'consumer', classNameFor(returnType.consumerTypeName)));
    } else {
      print('skipped consumer arg in Observatory method $name');
    }

    writer.addMethod(name, mthArgs, (StatementWriter writer) {
      writer.addLine('JsonObject params = new JsonObject();');
      for (MethodArg arg in args) {
        var name = arg.name;
        String op = arg.optional ? 'if (${name} != null) ' : '';
        if (arg.type == 'String' || arg.type == 'int' || arg.type == 'bool') {
          writer.addLine('${op}params.addProperty("$name", $name);');
        } else if (arg.isEnumType) {
          writer.addLine('${op}params.addProperty("$name", $name.name());');
        } else {
          print('skipped addProperty ${name} in Observatory method $name');
          writer.addLine('// ${name} ${arg.type}');
        }
      }
      writer.addLine('request("$name", params, consumer);');
      if (returnType.isMultipleReturns) {
        writer
            .addLine('// Consumer: ${returnType.name} ${returnType.isSimple}');
      }
    }, javadoc: javadoc.toString());

//    if (docs != null) {
//      if (!hasArgs) {
//        gen.writeStatement("=> _call('${name}');");
//      } else if (hasOptionalArgs) {
//        gen.writeStatement('{');
//        gen.write('Map m = {');
//        gen.write(args
//            .where((MethodArg a) => !a.optional)
//            .map((arg) => "'${arg.name}': ${arg.name}")
//            .join(', '));
//        gen.writeln('};');
//        args.where((MethodArg a) => a.optional).forEach((MethodArg arg) {
//          String valueRef = arg.name;
//          if (api.isEnumName(arg.type)) {
//            valueRef = '${arg.name}.toString()';
//          }
//          gen.writeln(
//              "if (${arg.name} != null) m['${arg.name}'] = ${valueRef};");
//        });
//        gen.writeStatement("return _call('${name}', m);");
//        gen.writeStatement('}');
//      } else {
//        gen.writeStatement('{');
//        gen.write("return _call('${name}', {");
//        gen.write(args.map((arg) => "'${arg.name}': ${arg.name}").join(', '));
//        gen.writeStatement('});');
//        gen.writeStatement('}');
//      }
//    }
  }

  void _parse(Token token) {
    new MethodParser(token).parseInto(this);
  }
}

class MethodArg extends Member {
  final Method parent;
  String type;
  String name;
  String docs;
  bool optional = false;

  MethodArg(this.parent, this.type, this.name);

  get asJavaMethodArg =>
      new JavaMethodArg(name, type == 'bool' ? 'boolean' : type);

  /// Hacked enum arg type determination
  bool get isEnumType => name == 'step';
}

class MethodParser extends Parser {
  MethodParser(Token startToken) : super(startToken);

  void parseInto(Method method) {
    // method is return type, name, (, args )
    // args is type name, [optional], comma

    method.returnType.parse(this);

    Token t = expectName();
    validate(
        t.text == method.name, 'method name ${method.name} equals ${t.text}');

    expect('(');

    while (peek().text != ')') {
      Token type = expectName();
      Token name = expectName();
      MethodArg arg =
          new MethodArg(method, _coerceRefType(type.text), name.text);
      if (consume('[')) {
        expect('optional');
        expect(']');
        arg.optional = true;
      }
      method.args.add(arg);
      consume(',');
    }

    expect(')');
  }
}

class TextOutputVisitor implements NodeVisitor {
  StringBuffer buf = new StringBuffer();

  bool _inRef = false;
  TextOutputVisitor();

  String toString() => buf.toString().trim();

  void visitElementAfter(Element element) {
    if (element.tag == 'p') {
      buf.write('\n\n');
    } else if (element.tag == 'em') {
      buf.write(']');
      _inRef = false;
    }
  }

  bool visitElementBefore(Element element) {
    if (element.tag == 'em') {
      buf.write('[');
      _inRef = true;
    } else if (element.tag == 'p') {
      // Nothing to do.
    } else if (element.tag == 'a') {
      // Nothing to do - we're not writing out <a> refs (they won't resolve).
    } else {
      print('unknown tag: ${element.tag}');
      buf.write(renderToHtml([element]));
    }

    return true;
  }

  void visitText(Text text) {
    String t = text.text;
    if (_inRef) t = _coerceRefType(t);
    buf.write(t);
  }

  static String printText(Node node) {
    TextOutputVisitor visitor = new TextOutputVisitor();
    node.accept(visitor);
    return visitor.toString();
  }
}

class Type extends Member {
  final Api parent;
  String rawName;
  String name;
  String superName;
  final String docs;
  List<TypeField> fields = [];

  Type(this.parent, String categoryName, String definition, [this.docs]) {
    _parse(new Tokenizer(definition).tokenize());
  }

  bool get isRef => name.endsWith('Ref');

  bool get isResponse {
    if (superName == null) return false;
    if (name == 'Response' || superName == 'Response') return true;
    return parent.getType(superName).isResponse;
  }

  void generateElement(JavaGenerator gen) {
    gen.writeType('com.google.dart.observatory.element.$name',
        (TypeWriter writer) {
      if (fields.any((f) => f.type.types.any((t) => t.isArray))) {
        writer.addImport('com.google.gson.JsonObject');
      }
      writer.addImport('com.google.gson.JsonObject');
      writer.javadoc = docs;
      writer.superclassName = 'Element';
      writer.addConstructor(<JavaMethodArg>[
        new JavaMethodArg('json', 'com.google.gson.JsonObject')
      ], (StatementWriter writer) {
        writer.addLine('super(json);');
      });

      for (var field in fields) {
        field.generateAccessor(writer);
      }
    });
//        if (field.type.isSimple) {
//          writer.addMethod(name, args, write)
//        gen.writeln("${field.generatableName} = json['${field.name}'];");
//      } else if (field.type.isEnum) {
//        // Parse the enum.
//        String enumTypeName = field.type.types.first.name;
//        gen.writeln(
//            "${field.generatableName} = _parseEnum(${enumTypeName}.values, json['${field.name}']);");
//        } else {
//        gen.writeln(
//            "${field.generatableName} = createObject(json['${field.name}']);");
//        }

//    gen.writeln('}');
//    gen.writeln();
//    fields.forEach((TypeField field) => field.generate(gen));
//
//    List<TypeField> allFields = getAllFields();
//    if (allFields.length <= 7) {
//      String properties = allFields
//          .map(
//              (TypeField f) => "${f.generatableName}: \${${f.generatableName}}")
//          .join(', ');
//      if (properties.length > 70) {
//        gen.writeln("String toString() => '[${name} ' //\n'${properties}]';");
//      } else {
//        gen.writeln("String toString() => '[${name} ${properties}]';");
//      }
//    } else {
//      gen.writeln("String toString() => '[${name}]';");
//    }
//
//    gen.writeln('}');
  }

  List<TypeField> getAllFields() {
    if (superName == null) return fields;

    List<TypeField> all = [];
    all.insertAll(0, fields);

    Type s = getSuper();
    while (s != null) {
      all.insertAll(0, s.fields);
      s = s.getSuper();
    }

    return all;
  }

  Type getSuper() => superName == null ? null : api.getType(superName);

  void _parse(Token token) {
    new TypeParser(token).parseInto(this);
  }
}

// @Instance|@Error|Sentinel evaluate(
//     string isolateId,
//     string targetId [optional],
//     string expression)
class TypeField extends Member {
  static final Map<String, String> _nameRemap = {
    'const': 'isConst',
    'final': 'isFinal',
    'static': 'isStatic',
    'abstract': 'isAbstract',
    'super': 'superClass',
    'class': 'classRef'
  };

  final Type parent;
  final String _docs;
  MemberType type = new MemberType();
  String name;
  bool optional = false;

  TypeField(this.parent, this._docs);

  String get accessorName => 'get${titleCase(generatableName)}';

  String get docs {
    String str = _docs == null ? '' : _docs;
    if (type.isMultipleReturns) {
      str += '\n\n[${generatableName}] can be one of '
          '${joinLast(type.types.map((t) => '[${t}]'), ', ', ' or ')}.';
      str = str.trim();
    }
    return str;
  }

  String get generatableName {
    return _nameRemap[name] != null ? _nameRemap[name] : name;
  }

  void generateAccessor(TypeWriter writer) {
    if (type.isMultipleReturns) {
      // TODO(danrubel) generate accessors for dynamic
      print('skipped accessor for $name');
      return;
    }

    if (type.types.first.isArray) {
      writer.addImport('com.google.gson.JsonArray');
      writer.addImport('java.util.ArrayList');
      writer.addImport('java.util.List');
    }
    writer.addMethod(accessorName, [], (StatementWriter writer) {
      type.types.first.generateAccessStatements(writer, name);
    }, javadoc: docs, returnType: type.types.first.ref);
  }
}

class TypeParser extends Parser {
  TypeParser(Token startToken) : super(startToken);

  void parseInto(Type type) {
    // class ClassList extends Response {
    //   // Docs here.
    //   @Class[] classes [optional];
    // }
    expect('class');

    Token t = expectName();
    type.rawName = t.text;
    type.name = _coerceRefType(type.rawName);
    if (consume('extends')) {
      t = expectName();
      type.superName = _coerceRefType(t.text);
    }

    expect('{');

    while (peek().text != '}') {
      TypeField field = new TypeField(type, collectComments());
      field.type.parse(this);
      field.name = expectName().text;
      if (consume('[')) {
        expect('optional');
        expect(']');
        field.optional = true;
      }
      type.fields.add(field);
      expect(';');
    }

    expect('}');
  }
}

class TypeRef {
  String name;
  int arrayDepth = 0;

  TypeRef(this.name);

  String get elementTypeName {
    if (isSimple) return null;
    return 'com.google.dart.observatory.element.$name';
  }

  bool get isArray => arrayDepth > 0;

  /// Hacked enum determination
  bool get isEnum => name.endsWith('Kind');

  bool get isSimple => name == 'int' || name == 'String' || name == 'bool';

  String get javaBoxedName {
    if (name == 'bool') return 'Boolean';
    if (name == 'int') return 'Integer';
    return name;
  }

  String get javaUnboxedName => name == 'bool' ? 'boolean' : name;

  String get ref {
    if (arrayDepth == 2) return 'List<List<${javaBoxedName}>>';
    if (arrayDepth == 1) return 'List<${javaBoxedName}>';
    return javaUnboxedName;
  }

  void generateAccessStatements(StatementWriter writer, String propertyName) {
    if (name == 'bool') {
      if (isArray) {
        print('skipped accessor $propertyName');
      } else {
        writer.addLine('return json.get("$propertyName").getAsBoolean();');
      }
    } else if (name == 'int') {
      if (isArray) {
        print('skipped accessor $propertyName');
      } else {
        writer.addLine('return json.get("$propertyName").getAsInt();');
      }
    } else if (name == 'String') {
      if (isArray) {
        print('skipped accessor $propertyName');
      } else {
        writer.addLine('return json.get("$propertyName").getAsString();');
      }
    } else if (isEnum) {
      if (isArray) {
        print('skipped accessor $propertyName');
      } else {
        writer.addLine(
            'return $javaUnboxedName.valueOf(((JsonObject) json.get("$propertyName")).getAsString());');
      }
    } else {
      if (arrayDepth > 1) {
        print('skipped accessor $propertyName');
      } else if (arrayDepth == 1) {
        writer.addLine(
            'JsonArray array = (JsonArray) json.get("$propertyName");');
        writer.addLine('int size = array.size();');
        writer.addLine(
            'List<$javaBoxedName> result = new ArrayList<$javaBoxedName>();');
        writer.addLine('for (int index = 0; index < size; ++index) {');
        writer.addLine(
            '  result.add(new $javaBoxedName((JsonObject) array.get(index)));');
        writer.addLine('}');
        writer.addLine('return result;');
      } else {
        writer.addLine(
            'return new $name((JsonObject) json.get("$propertyName"));');
      }
    }
  }

  String toString() => ref;
}
