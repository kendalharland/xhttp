@TestOn('vm')

import 'package:test/test.dart';
import 'package:xhttp/xhttp.dart';

import 'vm/handlers.dart';
import 'vm/local_server.dart';

void main() {
  group(Response, () {
    group('body', () {
      LocalServer server;

      setUp(() {
        server = LocalServer();
      });

      tearDown(() {
        server.stop();
        server = null;
      });

      test('decodes the response body according to the content-type', () async {
        const message = 'blåbærgrød';
        await server.start(sendEncoded('utf-8', message));
        final response = await Client().get(server.url);
        expect(response.body, completion(message));
      });

      test('throws if the body contains invalid characters', () async {
        const message = 'blåbærgrød';
        await server.start(sendEncoded('utf-8', message));
        final response = await Client().get(server.url);

        response.headers['content-type'] = 'text/plain; charset=ascii';
        expect(
          response.body,
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('non-ASCII'),
          )),
        );
      });
    });
  });
}
