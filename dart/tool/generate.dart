// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:path/path.dart';

import 'common/generate_common.dart';
import 'dart/generate_dart.dart' as dart show Api, api, DartGenerator;
import 'java/generate_java.dart' as java show Api, api, JavaGenerator;

/// Parse the 'service.md' into a model and generate both Dart and Java
/// libraries.
main(List<String> args) {
  String appDirPath = dirname(Platform.script.toFilePath());

  // Parse service.md into a model.
  var file = new File(join(appDirPath, 'service.md'));
  var document = new Document();
  var nodes = document.parseLines(file.readAsStringSync().split('\n'));
  print('Parsed ${file.path}.');
  print('Service protocol version ${ApiParseUtil.parseVersionString(nodes)}.');

  // Generate code from the model.
  _generateDart(appDirPath, nodes);
  _generateJava(appDirPath, nodes);
}

void _generateDart(String appDirPath, List<Node> nodes) {
  print('');
  var outDirPath = normalize(join(appDirPath, '..', 'lib'));
  var outDir = new Directory(outDirPath);
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  var outputFile = new File(join(outDirPath, 'vm_service_lib.dart'));
  var generator = new dart.DartGenerator();
  dart.api = new dart.Api();
  dart.api.parse(nodes);
  dart.api.generate(generator);
  outputFile.writeAsStringSync(generator.toString());
  Process.runSync('dartfmt', ['-w', outDirPath]);
  print('Wrote Dart to ${outputFile.path}.');
}

void _generateJava(String appDirPath, List<Node> nodes) {
  print('');
  var srcDirPath = normalize(join(appDirPath, '..', '..', 'java', 'src'));
  assert(new Directory(srcDirPath).existsSync());
  var generator = new java.JavaGenerator(srcDirPath);
  java.api = new java.Api();
  java.api.parse(nodes);
  java.api.generate(generator);
  print('Wrote Java to $srcDirPath.');
}
