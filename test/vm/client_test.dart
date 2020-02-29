@TestOn('vm')

import 'package:test/test.dart';
import 'package:xhttp/src/byte_stream.dart';
import 'package:xhttp/xhttp.dart';

import 'handlers.dart';
import 'local_server.dart';

void main() {
  group(Client, () {
    LocalServer server;

    setUp(() {
      server = LocalServer();
    });

    tearDown(() {
      server.stop();
      server = null;
    });
    test('send sends a $Request', () async {
      await server.start(echo());

      final request = Request(
        url: server.url,
        method: MethodGet,
        headers: <String, String>{'content-type': 'application/json'},
        bodyBytes: ByteStream.fromBytes(<int>[1, 2, 3]),
      );

      final client = Client();
      final response = await client.send(request);
      client.close();
      expect(response.request, request);
    });

    test('get sends a GET $Request', () async {
      await server.start(echo());

      final client = Client();
      final response = await client.get(server.url);
      client.close();

      expect(response.statusCode, 200);
      expect(response.request.method, MethodGet);
      expect(response.request.url, server.url);
    });

    group('post', () {
      test('sends a POST $Request', () async {
        await server.start(echo());

        final client = Client();
        final response = await client.post(
          server.url,
          contentType: 'test-content',
          bodyBytes: <int>[1, 2, 3],
        );
        client.close();

        expect(response.request.method, MethodPost);
        expect(response.request.url, server.url);
        expect(response.request.headers,
            containsPair('content-type', 'test-content'));
      });

      test('only sets content-type header if non-null', () async {
        await server.start(echo());

        final client = Client();
        final response = await client.post(server.url);
        client.close();

        expect(response.request.headers.containsKey('content-type'), false);
      });
    });
  });
}
