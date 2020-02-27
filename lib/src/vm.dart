import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' show ByteStream, ClientException;

import 'request.dart';
import 'response.dart';
import 'round_tripper.dart';

/// Create a [VMRoundTripper].
///
/// Used from conditional imports, matches the definition in
/// `round_tripper_stub.dart`.
RoundTripper defaultRoundTripper() => VMRoundTripper();

/// A `dart:io`-based HTTP client.
class VMRoundTripper extends RoundTripper {
  /// The underlying `dart:io` HTTP client.
  HttpClient _inner;

  VMRoundTripper([HttpClient inner]) : _inner = inner ?? HttpClient();

  /// Sends an HTTP request and asynchronously returns the response.
  @override
  Future<Response> send(Request request) async {
    var requestBody = Uint8List.fromList(request.bodyBytes);
    var stream = ByteStream.fromBytes(requestBody ?? const []);

    try {
      var ioRequest = (await _inner.openUrl(request.method, request.url))
        // ..followRedirects = request.followRedirects
        // ..maxRedirects = request.maxRedirects
        // ..persistentConnection = request.persistentConnection
        ..contentLength = (request?.contentLength ?? -1);
      request.headers.forEach(ioRequest.headers.set);

      var response = await stream.pipe(ioRequest) as HttpClientResponse;

      var headers = <String, String>{};
      response.headers.forEach((key, values) {
        headers[key] = values.join(',');
      });

      final body = await ByteStream(response).toBytes();

      return Response(
        headers: headers,
        request: request,
        statusCode: response.statusCode,
        statusText: response.reasonPhrase,
        bodyBytes: body,
      );
    } on HttpException catch (error) {
      throw ClientException(error.message, error.uri);
    }
  }

  /// Closes the client.
  ///
  /// Terminates all active connections. If a client remains unclosed, the Dart
  /// process may not terminate.
  @override
  void close() {
    if (_inner != null) {
      _inner.close(force: true);
      _inner = null;
    }
  }
}
