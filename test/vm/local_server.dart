import 'dart:async';
import 'dart:io';

import 'handlers.dart';

/// An HTTP server for testing that runs at 'http://localhost'.
class LocalServer {
  static const _host = 'localhost';
  HttpServer _server;

  /// The URL to use when sending requests to this server.
  ///
  /// Throws a [StateError] if the server is not running.
  Uri get url {
    if (_server == null) {
      throw StateError('server is not running');
    }
    return Uri.parse('http://$_host:${_server.port}');
  }

  /// Starts the server.
  ///
  /// Throws a [StateError] if the server is already running.
  Future<void> start(Handler handler) async {
    if (_server != null) {
      throw StateError('server is already running');
    }
    _server = (await HttpServer.bind(_host, 0))..listen(handler);
  }

  /// Stops the server.
  ///
  /// Does nothing if the server is not running.
  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }
}
