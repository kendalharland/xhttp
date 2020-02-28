import 'package:test/test.dart';
import 'package:xhttp/src/byte_stream.dart';
import 'package:xhttp/xhttp.dart';

import 'src/callback_round_tripper.dart';

void main() {
  group(Client, () {
    test('send sends a $Request', () async {
      final request = Request(
        url: Uri.parse('http://test.com'),
        method: MethodGet,
        headers: <String, String>{'content-type': 'application/json'},
        bodyBytes: ByteStream.fromBytes(<int>[1, 2, 3]),
      );

      final client = Client.withRoundTripper(CallbackRoundTripper(
        doSend: (r) => Future.value(_emptyResponse(r)),
        doClose: () {},
      ));

      final response = await client.send(request);
      client.close();
      expect(response.request, request);
    });

    test('get sends a GET $Request', () async {
      final client = Client.withRoundTripper(CallbackRoundTripper(
        doSend: (r) => Future.value(_emptyResponse(r)),
        doClose: () {},
      ));

      final url = Uri.parse('http://test.com');
      final response = await client.get(url);
      client.close();

      expect(response.request.method, MethodGet);
      expect(response.request.url, url);
    });

    group('post', () {
      test('sends a POST $Request', () async {
        final client = Client.withRoundTripper(CallbackRoundTripper(
          doSend: (r) => Future.value(_emptyResponse(r)),
          doClose: () {},
        ));

        final url = Uri.parse('http://test.com');
        final response = await client.post(
          url,
          contentType: 'test-content',
          bodyBytes: <int>[1, 2, 3],
        );
        client.close();

        expect(response.request.method, MethodPost);
        expect(response.request.url, url);
        expect(response.request.headers,
            containsPair('content-type', 'test-content'));
      });

      test('only sets content-type header if non-null', () async {
         final client = Client.withRoundTripper(CallbackRoundTripper(
          doSend: (r) => Future.value(_emptyResponse(r)),
          doClose: () {},
        ));

        final url = Uri.parse('http://test.com');
        final response = await client.post(url);
        client.close();

        expect(response.request.headers.containsKey('content-type'), false);
      });
    });
  });
}

Response _emptyResponse(Request request) => Response(
      headers: {},
      bodyBytes: ByteStream.fromBytes(<int>[]),
      statusCode: 200,
      statusText: 'OK',
      request: request,
    );
