import 'dart:convert';
import 'dart:io';

import 'package:pedantic/pedantic.dart';
import 'package:xhttp/src/byte_stream.dart';

/// A Function that responds [HttpRequest] objects.
typedef Handler = void Function(HttpRequest request);

/// A [Handler] that echoes the [HttpRequest] back to the caller.
Handler echo({int statusCode = 200}) {
  assert(statusCode != null);
  return (HttpRequest request) async {
    request.response.statusCode = statusCode;

    if (request.contentLength > 0) {
      final requestBodyBytes = await ByteStream(request).toBytes();
      request.response
        ..contentLength = requestBodyBytes.length
        ..writeAll(requestBodyBytes);
    }

    return request.response.close();
  };
}

/// A [Handler] that redirects to [path].
Handler redirect(Uri to) {
  assert(to != null);
  return (HttpRequest request) async {
    request.response
      ..statusCode = 302
      ..headers.set('location', to);
    return request.response.close();
  };
}

/// A [Handler] that loops continuously.
Handler loop(resolve(String path)) {
  int salt = 1;
  return (HttpRequest request) async {
    request.response
      ..statusCode = 302
      ..headers.set('location', resolve('/?${salt++}'));
    return request.response.close();
  };
}

/// A [Handler] that responds with [message], sets the charset to [charset].
Handler sendEncoded(String charset, Object message) {
  return (HttpRequest request) {
    request.response
      ..statusCode = 200
      ..headers.set('content-type', 'text/plain; charset=$charset')
      ..write(message);
    return request.response.close();
  };
}
