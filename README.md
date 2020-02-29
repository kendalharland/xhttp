A cross-platform HTTP library for Dart with an emphasis on composition.

[![pub package](https://img.shields.io/pub/v/xhttp.svg)](https://pub.dev/packages/xhttp)
[![Build Status](https://travis-ci.org/kharland/xhttp.svg?branch=master)](https://travis-ci.org/kharland/xhttp)

This is an alternative to [package:http].

# Motivation

[package:http] has two design choices that led to the creation of this package:

1. Inheritance over composition.
2. Streaming-responses in `send`.

These design choices make it harder to add application-specific behavior to HTTP
clients. A common example is to embed authorization headers in every request:

## Problem example

Code that embeds user credentials in HTTP requests ends up being repeated often
in apps with many small components, such as Flutter apps. Those components often
must work properly regardless of whether a user is signed in. Ideally, we'd be
able to pass each component a `Client` object, and the component doesn't have
to know whether the `Client` has been configured to send credentials (user
signed in) or not (user signed out).

To accomplish this we can extend `package:http`'s `BaseClient` with a custom
type that holds onto the credentials, and pass that to components. The downside
is that we had to implement an entire client just to modify headers.

Another option is to write a `Request` factory that always produces requests
with authentication headers, but then every component needs access to that
factory object as well as the client.

Aside: Another small nitpick is that `Client.send` returns a `StreamedResponse`,
so apps that specify their own headers are stuck with the streaming API when
they probably don't want it, or at least they may not want every single request
to be streamed. The decision to stream or not stream should be scoped to the
piece of code that reads the `Request` body, not the code holding the `Client`.

# XHTTP

XHTTP solves the above problems by making `Client` a concrete type, and
pushing platform and app specific behaviors down into smaller, focused classes.
For example streaming vs. all-at-once responses are handled by the `Response`
type; Browser vs. VM functionality is implemented by `RoundTripper` which sends
requests and manages request resources.

## RoundTripper

The `Client` in `package:xhttp` relies on a `RoundTripper` to execute each
`Request`.  `RoundTripper` manages the underlying request resources and
execution. Users that need custom client behavior can probably get by using
`ModifyingRoundTripper` which transforms requests using a callback. Other users
can subtype or compose different `RoundTripper` implementations as needed.

## Streaming Requests

Each `Request` body is a `ByteStream`. The stream can be read incrementally via
`Request.bodyBytes` or all at once using `Request.body`.

## Examples

### Stream the response body.

```dart
Future<void> main() async {
  final client = Client();
  final response = await client.get(Uri.parse(exampleURL));
  response.bodyBytes.listen(decodeAndPrint);
  client.close();
}
```

### Consume the response body all at once.

```dart
Future<void> main() async {
  final client = Client();
  final response = await client.get(Uri.parse(exampleURL));
  print(await response.body);
  client.close();
}
```

### Embed OAuth2 tokens in requests.

```dart
const token = 'secret-auth-token';

Request authenticate(Request request) {
    final clone = Request.clone(request);
    clone.headers['Authorizaton'] = 'Bearer \$token';
    return clone;
}

final transport = ModifyingRoundTripper(authenticate);
final client = Client.withRoundTripper(transport);
client.get('https://myapp.com/protected/resource');
```


[package:http]: https://pub.dev/packages/http








