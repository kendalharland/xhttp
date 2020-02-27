import 'dart:async';

import 'package:meta/meta.dart';

import 'request.dart';
import 'response.dart';

/// Executes HTTP [Request] objects on behalf of [Client].
abstract class RoundTripper {
  /// Sends an HTTP [Request].
  Future<Response> send(Request request);

  /// Closes the [RoundTripper] and cleans up any resources associated with it.
  ///
  /// Always do this or else the Dart process may hang.
  void close();
}

/// A [RoundTripper] that modifies each [Request] before sending.
///
/// It can be used - for example - to embed access credentials in every request
/// before sending.
class ModifyingRoundTripper implements RoundTripper {
  /// Constructs a [ModifyingRoundTripper].
  ///
  /// [base] is the [RoundTripper] to eventually execute the [Request].
  /// [modify] transforms the [Request] before sending.
  const ModifyingRoundTripper({
    @required this.base,
    @required this.modify,
  })  : assert(base != null),
        assert(modify != null);

  /// The underlying [RoundTripper] that eventually executes the [Request].
  final RoundTripper base;

  /// Modifies a [Request] before sending.
  final Request Function(Request) modify;

  @override
  void close() {
    base.close();
  }

  @override
  Future<Response> send(Request request) => base.send(modify(request));
}
