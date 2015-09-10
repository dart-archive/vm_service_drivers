// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library generate_vm_service_lib_common;

import 'package:markdown/markdown.dart';

import 'src_gen_common.dart';

var _NINE = '9'.codeUnitAt(0);
var _ZERO = '0'.codeUnitAt(0);

/// [ApiParseUtil] contains top level parsing utilities
class ApiParseUtil {
  /// Extract the current VM Service version number
  List<int> parseServiceVersion(List<Node> nodes) {
    Element node = nodes.firstWhere((n) => isH1(n));
    Text text = node.children[0];
    List<int> v1 = _versionFromText(text.text);
    node = nodes.firstWhere((n) => isPara(n));
    node = node.children.firstWhere((n) => isEmphasis(n));
    text = node.children[0];
    List<int> v2 = _versionFromText(text.text);
    if (v1[0] != v2[0] || v1[1] != v2[1]) {
      print('Found multiple service versions: $v1 and $v2');
    }
    return v2;
  }

  bool _isDigit(String text) {
    var ch = text.codeUnitAt(0);
    return _ZERO <= ch && ch <= _NINE;
  }

  List<int> _versionFromText(String text) {
    var version = <int>[];
    var index = text.indexOf('.');
    var start = index;
    while (start > 0 && _isDigit(text[start - 1])) --start;
    version.add(int.parse(text.substring(start, index)));
    var end = index + 1;
    while (end < text.length && _isDigit(text[end])) ++end;
    version.add(int.parse(text.substring(index + 1, end)));
    return version;
  }
}
