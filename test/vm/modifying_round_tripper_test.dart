@TestOn('vm')

import 'package:xhttp/src/vm.dart';
import 'package:xhttp/xhttp.dart';
import 'package:test/test.dart';

import 'handlers.dart';
import 'local_server.dart';

void main() {
  group(ModifyingRoundTripper, () {
    test('should modify every request', () async {
      final server = LocalServer();
      await server.start(echo());

      // Header key-value pair to embed in requests.
      const header = 'Authorization';
      const value = 'Bearer token';

      Request modify(Request request) {
        final clone = Request.from(request);
        clone.headers[header] = value;
        return clone;
      }

      final roundTripper = ModifyingRoundTripper(
        base: defaultRoundTripper(),
        modify: modify,
      );

      var request = Request(method: MethodGet, url: server.url);
      expect(request.headers, isEmpty);
      var response = await roundTripper.send(request);
      expect(response.request.headers, containsPair(header, value));

      request = Request(method: MethodGet, url: server.url);
      expect(request.headers, isEmpty);
      response = await roundTripper.send(request);
      expect(response.request.headers, containsPair(header, value));

      server.stop();
    });
  });
}
