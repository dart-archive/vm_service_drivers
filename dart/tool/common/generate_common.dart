// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library generate_vm_service_lib_common;

import 'package:markdown/markdown.dart';
import 'package:pub_semver/pub_semver.dart';

import 'src_gen_common.dart';

/// [ApiParseUtil] contains top level parsing utilities.
class ApiParseUtil {
  /// Extract the current VM Service version number as a String.
  static String parseVersionString(List<Node> nodes) {
    final RegExp regex = new RegExp(r'[\d.]+');

    // Extract version from header: `# Dart VM Service Protocol 2.0`.
    Element node = nodes.firstWhere((n) => isH1(n));
    Text text = node.children[0];
    Match match = regex.firstMatch(text.text);
    if (match == null) throw 'Unable to locate service protocol version';

    String ver = match.group(0);

    // Ensure that the version parses; this will throw a FormatException on
    // parse errors.
    new Version.parse(ver);

    return ver;
  }

  /// Extract the current VM Service version number.
  List<int> parseServiceVersion(List<Node> nodes) {
    // Extract version from header
    // e.g. # Dart VM Service Protocol 2.0
    Element node = nodes.firstWhere((n) => isH1(n));
    Text text = node.children[0];
    List<int> v1 = _versionFromText(text.text);

    // Extract version from paragraph
    // e.g. This document describes of _version 2.0_ of
    node = nodes.firstWhere((n) => isPara(n));
    node = node.children.firstWhere((n) => isEmphasis(n));
    text = node.children[0];
    List<int> v2 = _versionFromText(text.text);

    if (v1[0] != v2[0] || v1[1] != v2[1]) {
      print('Found multiple service versions: $v1 and $v2');
    }
    return v2;
  }

  List<int> _versionFromText(String text) {
    var version = <int>[];
    var start = text.indexOf(new RegExp(r'\d+\.\d+'));
    if (start == -1) throw 'failed to find version';
    var index = text.indexOf('.', start);
    var end = text.indexOf(new RegExp(r'!\d'), index + 1);
    if (end == -1) end = text.length;
    version.add(int.parse(text.substring(start, index)));
    version.add(int.parse(text.substring(index + 1, end)));
    return version;
  }
}
