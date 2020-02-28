import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http_parser/http_parser.dart';
import 'package:quiver/core.dart';

import 'byte_stream.dart';
import 'request.dart';

// An HTTP response.
class Response {
  /// Constructs a [Response].
  const Response({
    @required this.request,
    @required this.statusCode,
    this.bodyBytes,
    this.statusText = '',
    this.headers = const {},
  })  : assert(request != null),
        assert(bodyBytes != null),
        assert(statusCode != null),
        assert(statusText != null),
        assert(headers != null);

  /// The [Request] that generated this response.
  final Request request;

  /// The response body as a list of bytes.
  final ByteStream bodyBytes;

  /// The response headers.
  final Map<String, String> headers;

  /// The status code returned by the server.
  final int statusCode;

  /// Human-readable context for [statusCode].
  final String statusText;

  /// The decoded body of this [Response].
  ///
  /// The encoding type is determeined by the response's 'charset' field in the
  /// 'content-type' header.
  Future<String> get body =>
      bodyBytes.bytesToString(_encodingForHeaders(headers));

  @override
  bool operator ==(Object other) =>
      other is Response && other.hashCode == hashCode;

  @override
  int get hashCode => hashObjects([
        request,
        statusCode,
        statusText,
        bodyBytes,
        headers,
      ]);
}

/// Returns the encoding to use for a response with the given headers.
///
/// Defaults to [latin1] if the headers don't specify a charset or if that
/// charset is unknown.
Encoding _encodingForHeaders(Map<String, String> headers) =>
    _encodingForCharset(_contentTypeForHeaders(headers).parameters['charset']);

/// Returns the [Encoding] that corresponds to [charset].
///
/// Returns [fallback] if [charset] is null or if no [Encoding] was found that
/// corresponds to [charset].
Encoding _encodingForCharset(String charset, [Encoding fallback = latin1]) {
  if (charset == null) return fallback;
  return Encoding.getByName(charset) ?? fallback;
}

/// Returns the [MediaType] object for the given headers's content-type.
///
/// Defaults to `application/octet-stream`.
MediaType _contentTypeForHeaders(Map<String, String> headers) {
  var contentType = headers['content-type'];
  if (contentType != null) return MediaType.parse(contentType);
  return MediaType('application', 'octet-stream');
}
