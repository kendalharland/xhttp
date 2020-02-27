import 'package:test/test.dart';
import 'package:xhttp/src/request.dart';
import 'package:xhttp/src/response.dart';
import 'package:xhttp/xhttp.dart';

import 'src/callback_round_tripper.dart';

void main() {
  group(Client, () {
    group('send', () {
      test('sends a $Request', () {
        final request = Request(
          url: Uri.parse('http://test.com'),
          method: MethodGet,
          headers: <String, String>{'content-type': 'application/json'},
          bodyBytes: <int>[1, 2, 3],
        );

        Request gotRequest;

        final client = Client.withRoundTripper(CallbackRoundTripper(
          doSend: (request) async {
            gotRequest = request;
            return _emptyResponse(request);
          },
          doClose: () {},
        ));

        expect(gotRequest, null);
        client.send(request);
        client.close();
        expect(gotRequest, request);
      });
    });
  });
}

Response _emptyResponse(Request request) => Response(
      headers: {},
      bodyBytes: <int>[],
      statusCode: 200,
      statusText: 'OK',
      request: request,
    );
