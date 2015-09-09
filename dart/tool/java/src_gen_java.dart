// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library to generate Java source code. See [JavaGenerator].
library src_gen_java;

import 'dart:io';

import 'package:path/path.dart';

import '../common/src_gen_common.dart';

/// The maximum length for javadoc comments.
int colBoundary = 80;

/// The header for every generated file.
String fileHeader;

String classNameFor(String typeName) {
  var index = typeName.lastIndexOf('.');
  return index > 0 ? typeName.substring(index + 1) : typeName;
}

String pkgNameFor(String typeName) {
  var index = typeName.lastIndexOf('.');
  return index > 0 ? typeName.substring(0, index) : '';
}

typedef WriteStatements(StatementWriter writer);
typedef WriteType(TypeWriter writer);

/// [JavaGenerator] generates java source files, one per Java type.
/// Typical usage:
///
///    var generator = new JavaGenerator('/path/to/java/src');
///    generator.writeType('some.package.Foo', (TypeWriter) writer) {
///      ...
///    });
///    ...
///
class JavaGenerator {
  /// The java source directory into which files are generated.
  final String srcDirPath;

  JavaGenerator(this.srcDirPath);

  /// Generate a Java class/interface in the given package
  void writeType(String typeName, WriteType write) {
    var classWriter = new TypeWriter(typeName);
    write(classWriter);
    var pkgDirPath = join(srcDirPath, joinAll(pkgNameFor(typeName).split('.')));
    var pkgDir = new Directory(pkgDirPath);
    if (!pkgDir.existsSync()) pkgDir.createSync(recursive: true);
    var classFilePath = join(pkgDirPath, '${classNameFor(typeName)}.java');
    var classFile = new File(classFilePath);
    classFile.writeAsStringSync(classWriter.toSource());
  }
}

class JavaMethodArg {
  final String name;
  final String typeName;

  JavaMethodArg(this.name, this.typeName);
}

class StatementWriter {
  final StringBuffer _content = new StringBuffer();

  void addLine(String line) {
    _content.writeln('    $line');
  }

  String toSource() => _content.toString();
}

/// [TypeWriter] describes a Java type to be generated.
/// Typical usage:
///
///     writer.addImport('package.one.Bar');
///     writer.addImport('package.two.*');
///     writer.superclassName = 'package.three.Blat';
///     writer.addMethod('foo', [
///       new JavaMethodArg('arg1', 'LocalType'),
///       new JavaMethodArg('arg2', 'java.util.List'),
///     ], (StatementWriter writer) {
///       ...
///     });
///
/// The [toSource()] method generates the source,
/// but need not be called if used in conjunction with
/// [JavaGenerator].
class TypeWriter {
  final String pkgName;
  final String className;
  bool isInterface = false;
  bool isEnum = false;
  String javadoc;
  String modifiers = 'public';
  final Set<String> _imports = new Set<String>();
  String superclassName;
  List<String> interfaceNames = <String>[];
  final StringBuffer _content = new StringBuffer();
  final Map<String, String> _methods = new Map<String, String>();

  TypeWriter(String typeName)
      : this.pkgName = pkgNameFor(typeName),
        this.className = classNameFor(typeName);

  String get kind {
    if (isInterface) return 'interface';
    if (isEnum) return 'enum';
    return 'class';
  }

  void addConstructor(Iterable<JavaMethodArg> args, WriteStatements write,
      {String javadoc, String modifiers: 'public'}) {
    _content.writeln();
    if (javadoc != null && javadoc.isNotEmpty) {
      _content.writeln('  /**');
      wrap(javadoc.trim(), colBoundary - 6)
          .split('\n')
          .forEach((line) => _content.writeln('   * $line'));
      _content.writeln('   */');
    }
    _content.write('  $modifiers $className(');
    _content.write(
        args.map((a) => '${classNameFor(a.typeName)} ${a.name}').join(', '));
    _content.write(')');
    if (write != null) {
      _content.writeln(' {');
      StatementWriter writer = new StatementWriter();
      write(writer);
      _content.write(writer.toSource());
      _content.writeln('  }');
    } else {
      _content.writeln(';');
    }
  }

  void addEnumValue(String name, {String javadoc, bool isLast}) {
    _content.writeln();
    if (javadoc != null && javadoc.isNotEmpty) {
      _content.writeln('  /**');
      wrap(javadoc.trim(), colBoundary - 6)
          .split('\n')
          .forEach((line) => _content.writeln('   * $line'));
      _content.writeln('   */');
    }
    _content.write('  $name');
    if (!isLast) {
      _content.writeln(',');
    } else {
      _content.writeln(';');
    }
  }

  void addImport(String typeName) {
    if (typeName == null || typeName.isEmpty) return;
    var pkgName = pkgNameFor(typeName);
    if (pkgName.isNotEmpty && pkgName != this.pkgName) {
      _imports.add(typeName);
    }
  }

  void addMethod(
      String name, Iterable<JavaMethodArg> args, WriteStatements write,
      {String javadoc, String modifiers: 'public', String returnType: 'void'}) {
    var mthDecl = new StringBuffer();
    if (javadoc != null && javadoc.isNotEmpty) {
      mthDecl.writeln('  /**');
      wrap(javadoc.trim(), colBoundary - 6)
          .split('\n')
          .forEach((line) => mthDecl.writeln('   * $line'));
      mthDecl.writeln('   */');
    }
    mthDecl.write('  ');
    if (modifiers != null && modifiers.isNotEmpty) {
      mthDecl.write('$modifiers ');
    }
    mthDecl.write('$returnType $name(');
    mthDecl.write(
        args.map((a) => '${classNameFor(a.typeName)} ${a.name}').join(', '));
    mthDecl.write(')');
    if (write != null) {
      mthDecl.writeln(' {');
      StatementWriter writer = new StatementWriter();
      write(writer);
      mthDecl.write(writer.toSource());
      mthDecl.writeln('  }');
    } else {
      mthDecl.writeln(';');
    }
    var key = (modifiers != null && modifiers.contains('public'))
        ? '1 $name'
        : '2 $name';
    _methods[key] = mthDecl.toString();
  }

  String toSource() {
    var buffer = new StringBuffer();
    if (fileHeader != null) buffer.write(fileHeader);
    if (pkgName != null) {
      buffer.writeln('package $pkgName;');
      buffer.writeln();
    }
    buffer.writeln('// This is a generated file.');
    buffer.writeln();
    addImport(superclassName);
    interfaceNames.forEach((t) => addImport(t));
    if (_imports.isNotEmpty) {
      var sorted = _imports.toList()..sort();
      for (String typeName in sorted) buffer.writeln('import $typeName;');
      buffer.writeln();
    }
    if (javadoc != null && javadoc.isNotEmpty) {
      buffer.writeln('/**');
      wrap(javadoc.trim(), colBoundary - 4)
          .split('\n')
          .forEach((line) => buffer.writeln(' * $line'));
      buffer.writeln(' */');
    }
    buffer.write('$modifiers $kind $className');
    if (superclassName != null) {
      buffer.write(' extends ${classNameFor(superclassName)}');
    }
    if (interfaceNames.isNotEmpty) {
      var classNames = interfaceNames.map((t) => classNameFor(t));
      buffer.write(
          ' ${isInterface ? 'extends' : 'implements'} ${classNames.join(', ')}');
    }
    buffer.writeln(' {');
    buffer.write(_content.toString());
    _methods.keys.toList()
      ..sort()
      ..forEach((mthName) {
        buffer.writeln();
        buffer.write(_methods[mthName]);
      });
    buffer.writeln('}');
    return buffer.toString();
  }
}
