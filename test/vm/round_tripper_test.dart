@TestOn('vm')

import 'package:test/test.dart';
import 'package:xhttp/src/vm.dart';
import 'package:xhttp/xhttp.dart';

import 'handlers.dart';
import 'local_server.dart';

void main() {
  group(VMRoundTripper, () {
    LocalServer server;

    setUp(() {
      server = LocalServer();
    });

    tearDown(() {
      server.stop();
      server = null;
    });

    test('without redirects', () async {
      await server.start((r) => redirect(server.url.resolve('/'))(r));

      final request = Request(
        url: server.url,
        method: MethodGet,
        followRedirects: false,
      );
      final response = await VMRoundTripper().send(request);

      expect(response.statusCode, 302);
    });

    group('follows redirects', () {
      test('when followsRedirects is true', () async {
        await server.start((request) {
          switch (request.uri.path) {
            case '/':
              return echo()(request);
            default:
              return redirect(server.url.resolve('/'))(request);
          }
        });

        final roundTripper = VMRoundTripper();
        final response = await roundTripper.send(Request(
          url: server.url,
          method: MethodGet,
          followRedirects: true,
          maxRedirects: 5,
        ));

        expect(response.statusCode, 200);
      });

      test('when maxRedirects is exceeded', () async {
        await server.start(loop((String next) => server.url.resolve(next)));

        final request = Request(
          url: server.url,
          method: MethodGet,
          followRedirects: true,
          maxRedirects: 5,
        );

        expect(
          VMRoundTripper().send(request),
          throwsA(isA<ClientException>().having(
            (e) => e.message,
            'message',
            'Redirect limit exceeded',
          )),
        );
      });
    });
  });
}
