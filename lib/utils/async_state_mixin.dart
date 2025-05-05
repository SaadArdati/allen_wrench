import 'dart:async';

import 'package:flutter/widgets.dart';

/// Represents the state of an asynchronous operation with loading, success,
/// and error states.
///
/// This sealed class serves as the base for the operation state hierarchy:
/// * [LoadingOperation] - Operation is in progress
/// * [SuccessOperation] - Operation completed successfully with data
/// * [ErrorOperation] - Operation failed with error details
sealed class OperationState<T extends Object> {
  /// Creates a state with an optional data parameter.
  ///
  /// [data] - The data associated with the operation, if any.
  const OperationState({T? data}) : _data = data;

  final T? _data;

  /// The data associated with the operation, if any.
  T? get data => _data;

  /// A convenience getter that determines whether [data] exists or not.
  bool get hasData => data != null;
}

/// Represents an operation that is currently in progress.
final class LoadingOperation<T extends Object> extends OperationState<T> {
  /// Creates a loading state with an optional alert-only flag.
  ///
  /// [data] - The last known data, if any.
  const LoadingOperation({super.data});
}

/// Represents a successfully completed operation with associated data.
final class SuccessOperation<T extends Object> extends OperationState<T> {
  /// Creates a success state with the operation's result data.
  const SuccessOperation({required T super.data});

  @override
  T get data => _data!;
}

/// Represents a failed operation with error details.
///
/// Provides comprehensive error information including an optional message,
/// the original exception, and stack trace for debugging.
final class ErrorOperation<T extends Object> extends OperationState<T> {
  /// Creates an error state with the specified error details.
  ///
  /// * [message] - Optional human-readable error message.
  /// * [exception] - Optional exception object that caused the error
  /// * [stackTrace] - Optional stack trace for debugging
  const ErrorOperation({
    this.message,
    this.exception,
    this.stackTrace,
    super.data,
  });

  /// Human-readable error message describing what went wrong.
  final String? message;

  /// The exception object that caused the error, if any.
  final Object? exception;

  /// Stack trace from when the error occurred, useful for debugging.
  final StackTrace? stackTrace;
}

/// A mixin that adds loading state management to a [StatefulWidget].
///
/// This mixin provides a standardized way to handle asynchronous operations
/// with loading, success, and error states. It automatically manages the
/// lifecycle of the state and provides methods for loading and reloading data.
///
/// Type parameters:
/// * [T] - The type of data that will be loaded
/// * [K] - The type of the StatefulWidget this mixin is used with
///
/// Example usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget>
///     with LoadingMixin<User, MyWidget> {
///
///   @override
///   Future<User> fetch() async {
///     return await userRepository.getCurrentUser();
///   }
/// }
/// ```
mixin AsyncStateMixin<T extends Object, K extends StatefulWidget> on State<K> {
  /// Notifier that broadcasts the current operation state.
  ///
  /// Listeners will be notified whenever the state changes between loading,
  /// success, and error states.
  final stateNotifier = ValueNotifier<OperationState<T>>(LoadingOperation<T>());

  /// The current operation state.
  OperationState<T> get state => stateNotifier.value;

  /// Whether to automatically load data when the widget is initialized.
  ///
  /// Override this to return false if you want to call loading at your
  /// own discretion.
  bool get loadOnInit => true;

  @override
  void initState() {
    super.initState();
    if (loadOnInit) {
      load();
    }
  }

  @override
  void dispose() {
    stateNotifier.dispose();
    super.dispose();
  }

  /// Fetches the data for this widget.
  ///
  /// This method must be implemented by classes using this mixin to define
  /// how to retrieve the data of type [T].
  FutureOr<T> fetch();

  /// Loads data and updates the operation state accordingly.
  ///
  /// * [cached] - If true, uses the last known data if available when notifying
  /// a new loading or exception state.
  ///
  /// This method handles the complete loading lifecycle:
  /// 1. Sets loading state
  /// 2. Attempts to fetch data
  /// 3. Updates state with success or error result
  FutureOr<void> load({bool cached = true}) async {
    final lastData =
        cached
            ? switch (stateNotifier.value) {
              LoadingOperation(:T data) ||
              ErrorOperation(:T data) ||
              SuccessOperation(:T data) => data,
              _ => null,
            }
            : null;
    stateNotifier.value = LoadingOperation(data: lastData);

    try {
      final result = await fetch();
      if (!mounted) return;
      stateNotifier.value = SuccessOperation(data: result);
    } catch (exception, stackTrace) {
      onError(exception, stackTrace);
      if (!mounted) return;
      stateNotifier.value = ErrorOperation(
        message: errorMessage(exception, stackTrace),
        exception: exception,
        stackTrace: stackTrace,
        data: lastData,
      );
    }
  }

  /// Converts an exception and stack trace into a human-readable error message.
  ///
  /// Override this method to provide custom error message formatting.
  String errorMessage(Object exception, StackTrace stackTrace) {
    return exception.toString();
  }

  /// A callback that is triggered when an error is thrown by [load] to
  /// externally handle any exceptions.
  void onError(Object exception, StackTrace stackTrace) {
    debugPrint(exception.toString());
    debugPrintStack(stackTrace: stackTrace, label: '$runtimeType');
  }

  /// Reloads the data with minimal loading indicators.
  ///
  /// This is a convenience method that calls [load] with [cached] defaulting
  /// to true, suitable for refresh operations.
  FutureOr<void> reload({bool cached = true}) => load();
}
