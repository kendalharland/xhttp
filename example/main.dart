import 'package:xhttp/xhttp.dart';

const exampleURL = 'https://postman-echo.com/get?foo1=bar1&foo2=bar2';

Future<void> main() async {
  final client = Client();
  final response = await client.get(Uri.parse(exampleURL));
  print(await response.body);
  client.close();
}
