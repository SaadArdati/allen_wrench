import 'dart:async';

import 'package:flutter/widgets.dart';

/// Represents the state of an asynchronous operation with loading, success,
/// and error states.
///
/// This sealed class serves as the base for the operation state hierarchy:
/// * [LoadingOperation] - Operation is in progress
/// * [SuccessOperation] - Operation completed successfully with data
/// * [ErrorOperation] - Operation failed with error details
sealed class OperationState {
  const OperationState();
}

/// Represents an operation that is currently in progress.
///
/// The [alertOnly] flag determines whether the loading state should trigger
/// a full loading indicator or just a minimal alert.
final class LoadingOperation extends OperationState {
  /// Creates a loading state with an optional alert-only flag.
  ///
  /// If [alertOnly] is true, the UI should show a minimal loading indicator
  /// instead of a full-screen loading state.
  const LoadingOperation({this.alertOnly = false});

  /// A flag that helps to determine how to display loading states on the UI
  /// side.
  final bool alertOnly;
}

/// Represents a successfully completed operation with associated data.
///
/// The type parameter [T] specifies the type of data returned by the operation.
final class SuccessOperation<T> extends OperationState {
  /// Creates a success state with the operation's result data.
  const SuccessOperation({required this.data});

  /// The data returned by the successful operation.
  final T data;
}

/// Represents a failed operation with error details.
///
/// Provides comprehensive error information including an optional message,
/// the original exception, and stack trace for debugging.
final class ErrorOperation extends OperationState {
  /// Creates an error state with the specified error details.
  ///
  /// * [alertOnly] - Whether to show a minimal error alert instead of full
  ///   error UI
  /// * [message] - Optional human-readable error message
  /// * [exception] - Optional exception object that caused the error
  /// * [stackTrace] - Optional stack trace for debugging
  const ErrorOperation({
    required this.alertOnly,
    this.message,
    this.exception,
    this.stackTrace,
  });

  /// A flag that helps to determine how to display error states on the UI side.
  final bool alertOnly;

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
mixin AsyncStateMixin<T, K extends StatefulWidget> on State<K> {
  /// Notifier that broadcasts the current operation state.
  ///
  /// Listeners will be notified whenever the state changes between loading,
  /// success, and error states.
  ValueNotifier<OperationState> stateNotifier = ValueNotifier(
    LoadingOperation(alertOnly: true),
  );

  /// The current operation state.
  OperationState get state => stateNotifier.value;

  /// Whether to automatically load data when the widget is initialized.
  ///
  /// Override this to return false if you want to call loading at your
  /// own discretion.
  bool get loadOnInit => true;

  @override
  void initState() {
    super.initState();
    if (loadOnInit) {
      load(alertOnly: false);
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
  /// * [alertOnly] - A flag that is delegated to the states to help determine
  ///  how to display loading and error states on the UI side.
  ///
  /// This method handles the complete loading lifecycle:
  /// 1. Sets loading state
  /// 2. Attempts to fetch data
  /// 3. Updates state with success or error result
  FutureOr<void> load({required bool alertOnly}) async {
    stateNotifier.value = LoadingOperation(alertOnly: alertOnly);

    try {
      final result = await fetch();
      if (!mounted) return;
      stateNotifier.value = SuccessOperation(data: result);
    } catch (exception, stackTrace) {
      if (!mounted) return;
      stateNotifier.value = ErrorOperation(
        alertOnly: alertOnly,
        message: errorMessage(exception, stackTrace),
        exception: exception,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts an exception and stack trace into a human-readable error message.
  ///
  /// Override this method to provide custom error message formatting.
  String errorMessage(Object exception, StackTrace stackTrace) {
    return exception.toString();
  }

  /// Reloads the data with minimal loading indicators.
  ///
  /// This is a convenience method that calls [load] with [alertOnly] defaulting
  /// to true, suitable for refresh operations.
  FutureOr<void> reload({bool alertOnly = true}) => load(alertOnly: alertOnly);
}
