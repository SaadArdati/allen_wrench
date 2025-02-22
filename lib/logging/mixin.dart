import 'logging.dart';

/// A mixin that provides convenient logging methods using the HyperLogger.
///
/// The mixin declares methods for logging messages at various levels, including:
///   - Informational messages with [info]
///   - Debug messages with [debug]
///   - Warning messages with [warning]
///   - Error messages with [error]
///   - Operation duration messages with [stopwatch]
///
/// The generic type parameter `T` is used to indicate the context (usually the class)
/// from which the logging originates.
mixin LoggerMixin<T> {
  /// Logs an informational message.
  ///
  /// [msg] is the message string to be logged.
  /// Optional parameters:
  ///   - [data]: Additional data to include in the log.
  ///   - [method]: The method name to associate with the message.
  void info(String msg, {Object? data, String? method}) =>
      AllenLogger.info<T>(msg, data: data, method: method);

  /// Logs a debug message.
  ///
  /// [msg] is the debug message string.
  /// Optional parameters:
  ///   - [data]: Any supplemental data to log.
  ///   - [method]: The method name for the log entry.
  void debug(String msg, {Object? data, String? method}) =>
      AllenLogger.debug<T>(msg, data: data, method: method);

  /// Logs a warning message.
  ///
  /// Warnings indicate potential issues without stopping the application.
  /// [msg] is the warning message string.
  /// Optional parameter:
  ///   - [method]: The name of the method where the warning occurred.
  void warning(String msg, {String? method}) =>
      AllenLogger.warning<T>(msg, method: method);

  /// Logs an error message.
  ///
  /// [message] is the error message string.
  /// Optional parameters:
  ///   - [error]: The error object to log.
  ///   - [stackTrace]: The stack trace associated with the error. If not provided,
  ///     the current stack trace is used.
  ///   - [data]: Additional data that provides context about the error.
  ///   - [method]: The method name where the error occurred.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
    String? method,
  }) => AllenLogger.error<T>(
    message,
    error: error,
    stackTrace: stackTrace ?? StackTrace.current,
    data: data,
    method: method,
  );

  /// Logs the duration of an operation.
  ///
  /// [message] is the description of the operation.
  /// [stopwatch] is the [Stopwatch] instance used to track the duration.
  /// The output includes elapsed time in both milliseconds and seconds.
  /// Optional parameter:
  ///   - [method]: The method name associated with the operation.
  void stopwatch(String message, Stopwatch stopwatch, {String? method}) =>
      AllenLogger.stopwatch<T>(message, stopwatch, method: method);
}
