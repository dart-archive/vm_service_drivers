// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library generate_vm_service_lib_java;

import 'package:markdown/markdown.dart';

import '../common/generate_common.dart';
import '../common/parser.dart';
import '../common/src_gen_common.dart';
import 'src_gen_java.dart';

export 'src_gen_java.dart' show JavaGenerator;

const String servicePackage = 'org.dartlang.vm.service';

const vmServiceJavadoc = '''
{@link VmService} allows control of and access to information in a running
Dart VM instance.
<br/>
Launch the Dart VM with the arguments:
<pre>
--pause_isolates_on_start
--observe
--enable-vm-service=some-port
</pre>
where <strong>some-port</strong> is a port number of your choice
which this client will use to communicate with the Dart VM.
See https://www.dartlang.org/tools/dart-vm/ for more details.
Once the VM is running, instantiate a new {@link VmService}
to connect to that VM via {@link VmService#connect(String)}
or {@link VmService#localConnect(int)}.
<br/>
Calls to {@link VmService} should not be nested.
More specifically, you should not make any calls to {@link VmService}
from within any {@link Consumer} method.
''';

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

class Api extends Member with ApiParseUtil {
  int serviceMajor;
  int serviceMinor;
  String serviceVersion;
  List<Method> methods = [];
  List<Enum> enums = [];
  List<Type> types = [];

  String get docs => null;

  String get name => 'api';

  void addProperty(String typeName, String propertyName, {String javadoc}) {
    var t = types.firstWhere((t) => t.name == typeName);
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

    // Set default value for unspecified property
    setDefaultValue('Instance', 'valueAsStringIsTruncated');
    setDefaultValue('InstanceRef', 'valueAsStringIsTruncated');

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

    gen.writeType('$servicePackage.VmService', (TypeWriter writer) {
      writer.addImport('com.google.gson.JsonObject');
      writer.addImport('$servicePackage.consumer.*');
      writer.addImport('$servicePackage.element.*');
      writer.javadoc = vmServiceJavadoc;
      writer.superclassName = '$servicePackage.VmServiceBase';
      writer.addField('versionMajor', 'int',
          modifiers: 'public static final',
          value: '$serviceMajor',
          javadoc:
              'The major version number of the protocol supported by this client.');
      writer.addField('versionMinor', 'int',
          modifiers: 'public static final',
          value: '$serviceMinor',
          javadoc:
              'The minor version number of the protocol supported by this client.');
      for (var m in methods) {
        m.generateVmServiceMethod(writer);
      }
      writer.addMethod('forwardResponse', [
        new JavaMethodArg('consumer', 'Consumer'),
        new JavaMethodArg('responseType', 'String'),
        new JavaMethodArg('json', 'JsonObject')
      ], (StatementWriter writer) {
        var generatedForwards = new Set<String>();

        var sorted = methods.toList()
          ..sort((m1, m2) {
            return m1.consumerTypeName.compareTo(m2.consumerTypeName);
          });
        for (var m in sorted) {
          if (generatedForwards.add(m.consumerTypeName)) {
            m.generateVmServiceForward(writer);
          }
        }
        writer.addLine('logUnknownResponse(consumer, json);');
      }, modifiers: null, isOverride: true);
    });

    for (var m in methods) {
      m.generateConsumerInterface(gen);
    }
    for (var t in types) {
      t.generateElement(gen);
    }
    for (var e in enums) {
      e.generateEnum(gen);
    }
  }

  Type getType(String name) =>
      types.firstWhere((t) => t.name == name, orElse: () => null);

  bool isEnumName(String typeName) => enums.any((Enum e) => e.name == typeName);

  void parse(List<Node> nodes) {
    var version = parseServiceVersion(nodes);
    serviceMajor = version[0];
    serviceMinor = version[1];
    serviceVersion = '$serviceMajor.$serviceMinor';

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

  void setDefaultValue(String typeName, String propertyName) {
    var type = types.firstWhere((t) => t.name == typeName);
    var field = type.fields.firstWhere((f) => f.name == propertyName);
    field.defaultValue = 'false';
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

  String get elementTypeName => '$servicePackage.element.$name';

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

  bool get hasSentinel => types.any((t) => t.name == 'Sentinel');

  bool get isEnum => types.length == 1 && api.isEnumName(types.first.name);

  bool get isMultipleReturns => types.length > 1;

  bool get isSimple => types.length == 1 && types.first.isSimple;

  bool get isValueAndSentinel => types.length == 2 && hasSentinel;

  String get name {
    if (types.isEmpty) return '';
    if (types.length == 1) return types.first.ref;
    return 'dynamic';
  }

  TypeRef get valueType {
    if (types.length == 1) return types.first;
    if (isValueAndSentinel) {
      return types.firstWhere((t) => t.name != 'Sentinel');
    }
    return null;
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

  String get consumerTypeName {
    String prefix;
    if (returnType.isMultipleReturns) {
      prefix = titleCase(name);
    } else {
      prefix = returnType.types.first.javaBoxedName;
    }
    return '$servicePackage.consumer.${prefix}Consumer';
  }

  bool get hasArgs => args.isNotEmpty;

  bool get hasOptionalArgs => args.any((MethodArg arg) => arg.optional);

  void generateConsumerInterface(JavaGenerator gen) {
    gen.writeType(consumerTypeName, (TypeWriter writer) {
      writer.javadoc = returnType.docs;
      writer.interfaceNames.add('$servicePackage.consumer.Consumer');
      writer.isInterface = true;
      for (var t in returnType.types) {
        writer.addImport(t.elementTypeName);
        writer.addMethod("received",
            [new JavaMethodArg('response', t.elementTypeName)], null);
      }
    });
  }

  void generateVmServiceForward(StatementWriter writer) {
    var consumerName = classNameFor(consumerTypeName);
    writer.addLine('if (consumer instanceof $consumerName) {');
    List<Type> types = returnType.types.map((ref) => ref.type).toList();
    for (int index = 0; index < types.length; ++index) {
      types.addAll(types[index].subtypes);
    }
    types.sort((t1, t2) => t1.name.compareTo(t2.name));
    for (var t in types) {

      // TODO(danrubel) rename classes to prevent collision
      // with common java types. e.g. "Class" --> "DartClass"
      if (t.name == 'Class' || t.name == 'Error') continue;

      var jsonType = t.name;
      var responseName = classNameFor(t.elementTypeName);
      writer.addLine('  if (responseType.equals("$jsonType")) {');
      writer.addLine(
          '    (($consumerName) consumer).received(new $responseName(json));');
      writer.addLine('    return;');
      writer.addLine('  }');
    }
    writer.addLine('}');
  }

  void generateVmServiceMethod(TypeWriter writer) {
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
    mthArgs.add(new JavaMethodArg('consumer', classNameFor(consumerTypeName)));
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
          print('skipped addProperty ${name} in VmService method $name');
          writer.addLine('// ${name} ${arg.type}');
        }
      }
      writer.addLine('request("$name", params, consumer);');
    }, javadoc: javadoc.toString());
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

  String get elementTypeName {
    if (isSimple) return null;
    return '$servicePackage.element.$name';
  }

  bool get isRef => name.endsWith('Ref');

  bool get isResponse {
    if (superName == null) return false;
    if (name == 'Response' || superName == 'Response') return true;
    return parent.getType(superName).isResponse;
  }

  bool get isSimple => name == 'int' || name == 'String' || name == 'bool';

  Iterable<Type> get subtypes =>
      api.types.toList()..retainWhere((t) => t.superName == name);

  void generateElement(JavaGenerator gen) {
    gen.writeType('$servicePackage.element.$name', (TypeWriter writer) {
      if (fields.any((f) => f.type.types.any((t) => t.isArray))) {
        writer.addImport('com.google.gson.JsonObject');
      }
      writer.addImport('com.google.gson.JsonObject');
      writer.javadoc = docs;
      writer.superclassName = superName ?? 'Element';
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
  String defaultValue;

  TypeField(this.parent, this._docs);

  String get accessorName => 'get${titleCase(generatableName)}';

  String get docs {
    String str = _docs == null ? '' : _docs;
    if (type.isMultipleReturns) {
      str += '\n\n@return one of '
          '${joinLast(type.types.map((t) => '<code>${t}</code>'), ', ', ' or ')}';
      str = str.trim();
    }
    return str;
  }

  String get generatableName {
    return _nameRemap[name] != null ? _nameRemap[name] : name;
  }

  void generateAccessor(TypeWriter writer) {
    if (type.isMultipleReturns && !type.isValueAndSentinel) {
      print('skipped accessor for $name '
          '(${type.types.map((t) => t.name).join(',')}) '
          ' in ${writer.className}');
      return;
    }

    if (type.types.first.isArray) {
      writer.addImport('java.util.List');
    }
    writer.addMethod(accessorName, [], (StatementWriter writer) {
      type.valueType.generateAccessStatements(writer, name,
          canBeSentinel: type.isValueAndSentinel, defaultValue: defaultValue);
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
    return '$servicePackage.element.$name';
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

  Type get type => api.types.firstWhere((t) => t.name == name);

  void generateAccessStatements(StatementWriter writer, String propertyName,
      {bool canBeSentinel: false, String defaultValue}) {
    if (name == 'bool') {
      if (isArray) {
        print('skipped accessor body for $propertyName');
      } else {
        if (defaultValue != null) {
          writer.addImport('com.google.gson.JsonElement');
          writer.addLine('JsonElement elem = json.get("$propertyName");');
          writer.addLine(
              'return elem != null ? elem.getAsBoolean() : $defaultValue;');
        } else {
          writer.addLine('return json.get("$propertyName").getAsBoolean();');
        }
      }
    } else if (name == 'int') {
      if (arrayDepth > 1) {
        writer.addLine('return getListListInt("$propertyName");');
      } else if (arrayDepth == 1) {
        writer.addLine('return getListInt("$propertyName");');
      } else {
        writer.addLine('return json.get("$propertyName").getAsInt();');
      }
    } else if (name == 'String') {
      if (isArray) {
        print('skipped accessor body for $propertyName');
      } else {
        writer.addLine('return json.get("$propertyName").getAsString();');
      }
    } else if (isEnum) {
      if (isArray) {
        print('skipped accessor body for $propertyName');
      } else {
        writer.addLine(
            'return $javaUnboxedName.valueOf(json.get("$propertyName").getAsString());');
      }
    } else {
      if (arrayDepth > 1) {
        print('skipped accessor body for $propertyName');
      } else if (arrayDepth == 1) {
        writer.addImport('java.util.List');
        writer.addImport('java.util.ArrayList');
        writer.addImport('com.google.gson.JsonArray');
        writer
            .addLine('JsonArray array = json.getAsJsonArray("$propertyName");');
        writer.addLine('int size = array.size();');
        writer.addLine(
            'List<$javaBoxedName> result = new ArrayList<$javaBoxedName>();');
        writer.addLine('for (int index = 0; index < size; ++index) {');
        writer.addLine(
            '  result.add(new $javaBoxedName((JsonObject) array.get(index)));');
        writer.addLine('}');
        writer.addLine('return result;');
      } else {
        if (canBeSentinel) {
          writer.addImport('com.google.gson.JsonElement');
          writer.addLine('JsonElement elem = json.get("$propertyName");');
          writer.addLine('if (!elem.isJsonObject()) return null;');
          writer.addLine('JsonObject child = elem.getAsJsonObject();');
          writer.addLine('String type = child.get("type").getAsString();');
          writer.addLine('if ("Sentinel".equals(type)) return null;');
          writer.addLine('return new $name(child);');
        } else {
          writer.addLine(
              'return new $name((JsonObject) json.get("$propertyName"));');
        }
      }
    }
  }

  String toString() => ref;
}
