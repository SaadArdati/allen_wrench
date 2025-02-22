import 'dart:async';

import 'package:flutter/widgets.dart';

/// A mixin that provides Stream subscription management capabilities.
///
/// This mixin maintains a list of active [StreamSubscription]s and provides methods
/// to safely subscribe to streams and cancel all subscriptions when needed.
///
/// Example usage:
/// ```dart
/// class MyClass with StreamSubscriberMixin {
///   void initialize() {
///     listen(myStream, (data) {
///       // Handle stream data
///     });
///   }
///
///   void cleanup() {
///     cancelSubscriptions();
///   }
/// }
/// ```
mixin StreamSubscriberMixin {
  /// Internal list of active stream subscriptions.
  final _subscriptions = <StreamSubscription>[];

  /// Subscribes to a [Stream] and automatically manages its subscription.
  ///
  /// This method wraps [Stream.listen] and stores the subscription for later cleanup.
  ///
  /// Parameters:
  /// * [stream] - The stream to subscribe to
  /// * [onData] - Callback function that handles each data event
  /// * [onError] - Optional callback for error handling
  /// * [onDone] - Optional callback when the stream is closed
  /// * [cancelOnError] - Whether to cancel the subscription on error
  StreamSubscription<T> listen<T>(
    Stream<T> stream,
    void Function(T data) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Cancels all active stream subscriptions.
  ///
  /// Returns a [Future] that completes when all subscriptions have been canceled.
  Future<void> cancelSubscriptions() =>
      _subscriptions.map((subscription) => subscription.cancel()).wait;
}

/// A mixin specifically designed for Flutter [State] objects to manage Stream subscriptions.
///
/// This mixin extends [State] to automatically handle stream subscription cleanup
/// when the widget is disposed. It provides the same subscription management capabilities
/// as [StreamSubscriberMixin] but integrates with Flutter's widget lifecycle.
///
/// Example usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with StreamSubscriberStateMixin {
///   @override
///   void initState() {
///     super.initState();
///     listen(myStream, (data) {
///       setState(() {
///         // Update widget state
///       });
///     });
///   }
/// }
/// ```
mixin StreamSubscriberStateMixin<K extends StatefulWidget> on State<K> {
  /// Internal list of active stream subscriptions.
  final _subscriptions = <StreamSubscription>[];

  /// Subscribes to a [Stream] and automatically manages its subscription.
  ///
  /// This method wraps [Stream.listen] and stores the subscription for later cleanup.
  ///
  /// Parameters:
  /// * [stream] - The stream to subscribe to
  /// * [onData] - Callback function that handles each data event
  /// * [onError] - Optional callback for error handling
  /// * [onDone] - Optional callback when the stream is closed
  /// * [cancelOnError] - Whether to cancel the subscription on error
  StreamSubscription<T> listen<T>(
    Stream<T> stream,
    void Function(T data) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }

  /// Cancels all active stream subscriptions.
  ///
  /// Returns a [Future] that completes when all subscriptions have been canceled.
  Future<void> cancelSubscriptions() =>
      _subscriptions.map((subscription) => subscription.cancel()).wait;
}
