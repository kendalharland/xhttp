import 'package:xhttp/xhttp.dart';
import 'package:xhttp/src/byte_stream.dart';
import 'package:test/test.dart';

import 'src/callback_round_tripper.dart';

void main() {
  group(ModifyingRoundTripper, () {
    test('should modify every request', () async {
      // Header key-value pair to embed in requests.
      const header = 'Authorization';
      const value = 'Bearer token';

      final base = CallbackRoundTripper(
        doSend: (request) async => Response(
            request: request,
            statusCode: 200,
            bodyBytes: ByteStream.fromBytes([])),
      );

      Request modify(Request request) {
        final clone = Request.from(request);
        clone.headers[header] = value;
        return clone;
      }

      final roundTripper = ModifyingRoundTripper(base: base, modify: modify);

      var request = Request(
        method: MethodGet,
        url: Uri.parse('http://test.com'),
      );
      expect(request.headers, isEmpty);
      var response = await roundTripper.send(request);
      expect(response.request.headers, containsPair(header, value));

      expect(request.headers, isEmpty);
      response = await roundTripper.send(request);
      expect(response.request.headers, containsPair(header, value));
    });
  });
}
