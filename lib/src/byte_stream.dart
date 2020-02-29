import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class ByteStream extends StreamView<List<int>> {
  ByteStream(Stream<List<int>> stream) : super(stream);

  factory ByteStream.fromBytes(List<int> bytes) =>
      ByteStream(Stream.fromIterable([bytes]));

  Future<Uint8List> toBytes() {
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback(
        (bytes) => completer.complete(Uint8List.fromList(bytes)));
    listen(sink.add,
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true);
    return completer.future;
  }

  Future<String> bytesToString([Encoding encoding = utf8]) =>
      encoding.decodeStream(this);

  Stream<String> toStringStream([Encoding encoding = utf8]) =>
      encoding.decoder.bind(this);
}
