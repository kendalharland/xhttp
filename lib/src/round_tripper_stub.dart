import 'round_tripper.dart';

RoundTripper defaultRoundTripper() => throw UnsupportedError(
    'Cannot create a $RoundTripper without dart:html or dart:io.');
