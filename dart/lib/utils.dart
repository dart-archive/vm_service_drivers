// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Map the URI (which may already be Observatory web app) to a WebSocket URI
/// for the VM service.
///
/// If the URI is already a VM Service WebSocket URI it will not be modified.
Uri getVmWsUriFromObservatoryUri(Uri uri) {
  final isSecure = uri.isScheme('wss') || uri.isScheme('https');
  final scheme = isSecure ? 'wss' : 'ws';

  final path = uri.path.endsWith('/ws')
      ? uri.path
      : (uri.path.endsWith('/') ? '${uri.path}ws' : '${uri.path}/ws');

  return uri.replace(scheme: scheme, path: path);
}
