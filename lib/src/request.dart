import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

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
    List<int> bodyBytes,
  }) {
    assert(method != null);
    assert(url != null);
    bodyBytes ??= <int>[];
    headers ??= <String, String>{};
    headers = Map.from(headers); // Just in case this is immutable.
    return Request._(
      method: method,
      bodyBytes: bodyBytes,
      url: url,
      headers: headers,
    );
  }

  /// Constructs a [Request] containing the same properties as [other].
  factory Request.from(Request other) => Request(
        method: other.method,
        url: other.url,
        headers: other.headers,
        bodyBytes: other.bodyBytes,
      );

  const Request._({
    @required this.method,
    @required this.bodyBytes,
    @required this.url,
    @required this.headers,
  });

  /// Headers to send with this request.
  final Map<String, String> headers;

  /// The HTTP Method to use.
  final String method;

  /// The [Uri] to send the request to.
  final Uri url;

  /// The bytes of the request body.
  final List<int> bodyBytes;

  /// The number of bytes in [bodyBytes].
  int get contentLength => bodyBytes?.length ?? 0;

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
