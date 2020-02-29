import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

import 'byte_stream.dart';

// An HTTP request.
class Request {
  /// Constructs a [Request].
  ///
  /// The encoding of [bodyBytes] should be specific in the 'Content-Type'
  /// header of [headers].
  ///
  /// [url] and [method] must not be null.
  factory Request({
    @required String method,
    @required Uri url,
    Map<String, String> headers,
    ByteStream bodyBytes,
    bool followRedirects = true,
    int maxRedirects = 5,
  }) {
    assert(method != null);
    assert(url != null);
    assert(followRedirects != null);
    if (followRedirects) {
      assert(maxRedirects != null);
      assert(maxRedirects > 0);
    }
    bodyBytes ??= ByteStream.fromBytes(const []);
    headers ??= <String, String>{};
    headers = Map.from(headers); // Just in case this is immutable.
    return Request._(
      method: method,
      bodyBytes: bodyBytes,
      url: url,
      headers: headers,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
    );
  }

  /// Constructs a [Request] containing the same properties as [other].
  factory Request.from(Request other) => Request(
        method: other.method,
        url: other.url,
        headers: other.headers,
        bodyBytes: other.bodyBytes,
        followRedirects: other.followRedirects,
        maxRedirects: other.maxRedirects,
      );

  const Request._({
    @required this.method,
    @required this.bodyBytes,
    @required this.url,
    @required this.headers,
    @required this.followRedirects,
    @required this.maxRedirects,
  });

  /// Headers to send with this request.
  final Map<String, String> headers;

  /// The HTTP Method to use.
  final String method;

  /// The [Uri] to send the request to.
  final Uri url;

  /// The bytes of the request body.
  final ByteStream bodyBytes;

  /// Whether the client should follow redirects when resovling this request.
  final bool followRedirects;

  /// The maximum number of redirects to follow when [followRedirects] is true.
  ///
  /// If this is exceeded, the [BaseResponse] future completes with an error.
  final int maxRedirects;

  // TODO: Persistent connections.

  @override
  bool operator ==(Object other) =>
      other is Request && other.hashCode == hashCode;

  @override
  int get hashCode => hashObjects([
        headers,
        method,
        url,
        bodyBytes,
      ]);
}
