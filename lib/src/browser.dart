import 'dart:html';
import 'dart:async';
import 'dart:typed_data';

import 'package:pedantic/pedantic.dart' show unawaited;

import 'byte_stream.dart';
import 'client_exception.dart';
import 'request.dart';
import 'response.dart';
import 'round_tripper.dart';

/// Create a [BrowserRoundTripper].
///
/// Used from conditional imports, matches the definition in
/// `round_tripper_stub.dart`.
RoundTripper defaultRoundTripper() => BrowserRoundTripper();

class BrowserRoundTripper implements RoundTripper {
  /// The currently active XHRs.
  ///
  /// These are aborted if the client is closed.
  final _xhrs = <HttpRequest>{};

  /// Whether to send credentials such as cookies or authorization headers for
  /// cross-site requests.
  ///
  /// Defaults to `false`.
  bool withCredentials = false;

  /// Sends an HTTP request and asynchronously returns the response.
  @override
  Future<Response> send(Request request) async {
    var bytes = await request.bodyBytes.toBytes();
    var xhr = HttpRequest();
    _xhrs.add(xhr);
    xhr
      ..open(request.method, '${request.url}', async: true)
      ..responseType = 'blob'
      ..withCredentials = withCredentials;
    request.headers.forEach(xhr.setRequestHeader);

    var completer = Completer<Response>();
    unawaited(xhr.onLoad.first.then((_) {
      var blob = xhr.response as Blob ?? Blob([]);
      var reader = FileReader();

      reader.onLoad.first.then((_) {
        var bodyBytes = ByteStream.fromBytes(reader.result as Uint8List);
        final response = Response(
          bodyBytes: bodyBytes,
          statusCode: xhr.status,
          request: request,
          headers: xhr.responseHeaders,
          statusText: xhr.statusText,
        );
        completer.complete(response);
      });

      reader.onError.first.then((error) {
        completer.completeError(
          ClientException(error.toString(), request.url),
          StackTrace.current,
        );
      });

      reader.readAsArrayBuffer(blob);
    }));

    unawaited(xhr.onError.first.then((_) {
      // Unfortunately, the underlying XMLHttpRequest API doesn't expose any
      // specific information about the error itself.
      completer.completeError(
          ClientException('XMLHttpRequest error.', request.url),
          StackTrace.current);
    }));

    xhr.send(bytes);

    try {
      return await completer.future;
    } finally {
      _xhrs.remove(xhr);
    }
  }

  /// Closes the client.
  ///
  /// This terminates all active requests.
  @override
  void close() {
    for (var xhr in _xhrs) {
      xhr.abort();
    }
  }
}
