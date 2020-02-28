import 'dart:async';

import 'byte_stream.dart';
import 'request.dart';
import 'response.dart';
import 'round_tripper.dart';

// ignore: uri_does_not_exist
import 'round_tripper_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'vm.dart';

const MethodGet = 'get';
const MethodPost = 'post';

/// An HTTP client.
///
/// The client relies on a [RoundTripper] to send requests. Most client behavior
/// can be controlled by specifying the desired [RoundTripper] implementation.
class Client {
  /// Constructs a [Client] with a platform-approriate [RoundTripper].
  ///
  /// Throws an unsupported error a [RoundTripper] cannot be created for the
  /// current platform.
  factory Client() => Client.withRoundTripper(defaultRoundTripper());

  /// Constructs a new [Client] with the given [RoundTripper].
  const Client.withRoundTripper(this._rt);

  final RoundTripper _rt;

  /// Sends [request] and asynchronously returns the [Response].
  Future<Response> send(Request request) => _rt.send(request);

  /// Sends a GET request to [url] and asynchronously returns the response.
  ///
  /// If you need more fine-grained control over the request headers or other
  /// parameters, use [send].
  Future<Response> get(Uri url) => send(Request(method: MethodGet, url: url));

  /// Sends a POST request to [url] and asynchronously returns the response.
  ///
  /// If you need more fine-grained control over the request headers or other
  /// parameters, use [send].
  Future<Response> post(
    Uri url, {
    String contentType,
    List<int> bodyBytes = const <int>[],
  }) {
    assert(bodyBytes != null);
    final body = ByteStream.fromBytes(bodyBytes);
    final headers = <String, String>{};
    if (contentType != null) {
      headers['content-type'] = contentType;
    }
    final request = Request(
      method: MethodPost,
      url: url,
      headers: headers,
      bodyBytes: body,
    );
    return send(request);
  }

  /// Closes the client and cleans up any resources associated with it.
  ///
  /// Always do this or else the Dart process may hang.
  void close() {
    _rt.close();
  }
}
