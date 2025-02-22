/// A structured message format for logging that combines a text message with
/// additional contextual data and metadata.
///
/// The [LogMessage] class provides a standardized way to create log entries that
/// include:
/// * A human-readable message
/// * Optional structured data
/// * The type/class where the log was created
/// * The optional method name where the log was created
/// * A stack trace for debugging context
///
/// Example usage:
/// ```dart
/// final logMessage = LogMessage(
///   'User authentication failed',
///   AuthService,
///   data: {'userId': '123', 'reason': 'invalid_credentials'},
///   method: 'authenticate',
///   callerStackTrace: StackTrace.current,
/// );
/// ```
class LogMessage {
  /// The human-readable message describing the log entry.
  final String message;

  /// Additional structured data associated with the log entry.
  ///
  /// This can be any object that provides context about the log event,
  /// such as an error object, a map of values, or other relevant data.
  final Object? data;

  /// The Type (usually a class) where this log message was created.
  ///
  /// This helps identify the source of the log message in the codebase.
  final Type type;

  /// The name of the method where this log message was created.
  ///
  /// When provided, this gives more specific context about where in the
  /// code the log was generated.
  final String? method;

  /// The stack trace captured when this log message was created.
  ///
  /// This provides debugging context about where the log message was
  /// generated in the code.
  final StackTrace callerStackTrace;

  /// Creates a new [LogMessage] with the specified parameters.
  ///
  /// The [message] and [type] parameters are required. The [data],
  /// [method], and [callerStackTrace] parameters are optional but can
  /// provide valuable context for debugging.
  ///
  /// * [message] - A human-readable description of the log event
  /// * [type] - The Type/class where the log was created
  /// * [data] - Optional structured data associated with the log
  /// * [method] - Optional method name where the log was created
  /// * [callerStackTrace] - Stack trace for debugging context
  const LogMessage(
    this.message,
    this.type, {
    this.data,
    this.method,
    required this.callerStackTrace,
  });

  /// Returns the human-readable message of this log entry.
  ///
  /// This is useful when the log message needs to be displayed as a string,
  /// such as in simple logging outputs or debugging.
  @override
  String toString() => message;
}
