import 'package:meta/meta.dart';
import 'package:xhttp/xhttp.dart';

class CallbackRoundTripper implements RoundTripper {
  const CallbackRoundTripper({
    @required this.doSend,
    this.doClose,
  });

  final Future<Response> Function(Request) doSend;
  final void Function() doClose;

  @override
  void close() => doClose == null ? null : doClose();

  @override
  Future<Response> send(Request request) => doSend(request);
}
