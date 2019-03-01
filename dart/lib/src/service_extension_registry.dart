// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../vm_service_lib.dart' show VmServerConnection, RPCError;

/// A registry of custom service extensions to [VmServerConnection]s in which
/// they were registered.
class ServiceExtensionRegistry {
  /// Maps service extensions registered through the protocol to the
  /// [VmServerConnection] in which they were registered.
  ///
  /// Note: this does not track services registered through `dart:developer`,
  /// only the services registered through the `_registerService` rpc method.
  final _extensionToConnection = <String, VmServerConnection>{};

  ServiceExtensionRegistry();

  /// Registers [extension] for [client].
  ///
  /// All future requests for [extension] will be routed to [client].
  void registerExtension(String extension, VmServerConnection client) async {
    if (_extensionToConnection.containsKey(extension)) {
      throw RPCError('registerExtension', 111, 'Service already registered');
    }
    _extensionToConnection[extension] = client;
    // Remove the mapping if the client disconnects.
    await client.done;
    _extensionToConnection.remove(extension);
  }

  /// Returns the [VmServerConnection] for a given [extension], or `null` if
  /// none is registered.
  ///
  /// The result of this function should not be stored, because clients may
  /// shut down at any time.
  VmServerConnection clientFor(String extension) =>
      _extensionToConnection[extension];
}
