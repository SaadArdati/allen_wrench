library;

import 'package:logger/logger.dart';
import 'package:universal_io/io.dart' as io;

import 'log_message.dart';
import 'printer.dart';

export 'log_message.dart';
export 'mixin.dart';
export 'printer.dart';

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

/// A convenient logger wrapper that:
/// 1) Prints emojis in the console.
/// 2) Accepts a generic type T for each log method (or pass a class name).
/// 3) Allows optional file logging if a file path is provided in [init()].
/// 4) Provides detailed stack traces with async chain support.
///
/// Note: actual file logging only works on native platforms. On the web, the
/// 'universal_io' package won't perform real file I/O, but it prevents import errors.
class AllenLogger {
  /// The underlying [Logger] instance, configured via [init].
  static Logger? _logger;

  /// Initialize the logger with optional file logging.
  ///
  /// - [enableFileOutput]: Turn on or off file logging.
  /// - [filePath]: The path to which logs should be written if [enableFileOutput] is true.
  /// - [enableNameExtraction]: Whether to extract class/method names from stack traces.
  ///   Defaults to false in release mode to avoid issues with obfuscation.
  static void init({
    bool enableFileOutput = false,
    String? filePath,
    bool? enableNameExtraction,
    bool verbose = true,
    bool noBoxing = false,
    bool noPrefix = false,
  }) {
    // Choose output(s) based on whether file logging is enabled and a valid file path is provided.
    LogOutput output;
    if (enableFileOutput && filePath != null && filePath.isNotEmpty) {
      output = MultiOutput([
        ConsoleOutput(),
        FileOutput(file: io.File(filePath)),
      ]);
    } else {
      output = ConsoleOutput();
    }

    LogPrinter printer = AllenPrettyPrinter(
      lineLength: 120,
      colors: !kIsWeb && io.stdout.supportsAnsiEscapes,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.none,
      noBoxingByDefault: noBoxing,
    );
    if (!noPrefix) {
      printer = PrefixPrinter(printer);
    }

    _logger = Logger(
      printer: printer,
      output: output,
      level: verbose ? Level.all : Level.info,
    );
  }

  /// Set the minimum log level at runtime.
  static void setLogLevel(Level level) {
    Logger.level = level;
  }

  /// Throws a [StateError] if the logger isn't initialized.
  static void _ensureInitialized() {
    if (_logger == null) {
      throw StateError('HyperLogger.init() has not been called yet.');
    }
  }

  // ---------------------------------------------------------------------------
  // Logging Methods
  // ---------------------------------------------------------------------------

  /// **TRACE** – Very detailed logs, typically used for **fine-grained** or
  /// **high-volume** events.
  ///
  /// Use this when you need deep visibility into the flow of your application,
  /// such as function-level tracing or extremely verbose data for
  /// **troubleshooting**. Includes async stack chain support.
  ///
  /// ### Example
  ///
  /// ```dart
  /// HyperLogger.trace<SomeService>(
  ///   "Entering method X with params: $params",
  ///   method: "methodX", // Optional: auto-detected if not provided
  /// );
  /// ```
  static void trace<T>(String message, {Object? data, String? method}) {
    _ensureInitialized();
    _logger!.t(
      LogMessage(
        message,
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
    );
  }

  /// **DEBUG** – Information helpful during **development** or **debugging**.
  ///
  /// Use it to log variables, state changes, or any relevant context that
  /// helps you understand the internal behavior of your app without spamming
  /// production logs. Supports structured data output and async stack chains.
  ///
  /// ### Example
  ///
  /// ```dart
  /// HyperLogger.debug<DBHelper>(
  ///   "Query result",
  ///   data: records.toJson(),
  ///   method: "executeQuery", // Optional: auto-detected if not provided
  /// );
  /// ```
  static void debug<T>(String message, {Object? data, String? method}) {
    _ensureInitialized();
    _logger!.d(
      LogMessage(
        message,
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
    );
  }

  /// **INFO** – General events or key points in application flow.
  ///
  /// Use this for **high-level information** that would be helpful in
  /// production to understand the normal operation of the system.
  /// Supports structured data output and async stack chains.
  ///
  /// ### Example
  ///
  /// ```dart
  /// HyperLogger.info<AuthManager>(
  ///   "User logged in: $userId",
  ///   data: user.toJson(),
  ///   method: "login", // Optional: auto-detected if not provided
  /// );
  /// ```
  static void info<T>(String message, {Object? data, String? method}) {
    _ensureInitialized();
    _logger!.i(
      LogMessage(
        message,
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
    );
  }

  /// **WARNING** – Indications of potential problems.
  ///
  /// Use this when something suspicious or unexpected happened, but your
  /// application **can still continue** running. Includes async stack chain support.
  ///
  /// ### Example
  ///
  /// ```dart
  /// HyperLogger.warning<CacheHandler>(
  ///   "Cache miss for key: $cacheKey",
  ///   method: "getFromCache", // Optional: auto-detected if not provided
  /// );
  /// ```
  static void warning<T>(String message, {Object? data, String? method}) {
    _ensureInitialized();
    _logger!.w(
      LogMessage(
        message,
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
    );
  }

  /// **ERROR** – An error occurred, but the application can often **recover**.
  ///
  /// Use this when you catch exceptions or other errors that you can handle
  /// gracefully (e.g., by retrying or providing fallback logic). The system
  /// can usually still keep running after this.
  ///
  /// Features:
  /// - Automatic async stack chain capture
  /// - Smart error stack trace handling
  /// - Structured data support
  /// - Automatic method name detection
  ///
  /// ### Example
  ///
  /// ```dart
  /// try {
  ///   // Something throws an exception
  /// } catch (e, s) {
  ///   HyperLogger.error<MyRepo>(
  ///     "Failed to fetch data",
  ///     error: e,
  ///     stackTrace: s,
  ///     data: {'query': query},
  ///     method: "fetchData", // Optional: auto-detected if not provided
  ///   );
  /// }
  /// ```
  static void error<T>(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
    String? method,
  }) {
    _ensureInitialized();
    _logger!.e(
      LogMessage(
        message,
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// **FATAL** – A critical error that makes the app **no longer able** to continue.
  ///
  /// Use this when the application hits an **unrecoverable** problem or has
  /// to crash/exit immediately. Examples might be catastrophic configuration
  /// errors, data corruption, etc.
  ///
  /// Features:
  /// - Always captures full async stack chains
  /// - Smart error stack trace handling
  /// - Automatic method name detection
  ///
  /// ### Example
  ///
  /// ```dart
  /// void handleUncaughtError(Object error, StackTrace stack) {
  ///   HyperLogger.fatal<CrashHandler>(
  ///     "Uncaught error",
  ///     error: error,
  ///     stackTrace: stack,
  ///     method: "handleUncaughtError", // Optional: auto-detected if not provided
  ///   );
  ///   // Possibly exit the process or kill the app gracefully.
  /// }
  /// ```
  static void fatal<T>(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
    String? method,
  }) {
    _ensureInitialized();
    _logger!.f(
      LogMessage(
        message,
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// Logs the duration of an operation using a [Stopwatch].
  ///
  /// This is useful for performance monitoring and debugging. The output includes
  /// both milliseconds and seconds for better readability.
  ///
  /// Features:
  /// - Automatic async stack chain capture
  /// - Automatic method name detection
  /// - Formatted duration output
  ///
  /// ### Example
  ///
  /// ```dart
  /// final sw = Stopwatch()..start();
  /// // ... some operation ...
  /// sw.stop();
  /// HyperLogger.stopwatch<MyClass>(
  ///   "Operation completed",
  ///   sw,
  ///   method: "performOperation", // Optional: auto-detected if not provided
  /// );
  /// ```
  static void stopwatch<T>(
    String message,
    Stopwatch stopwatch, {
    Object? data,
    String? method,
  }) {
    _ensureInitialized();
    _logger!.i(
      LogMessage(
        '$message |=> Took ${stopwatch.elapsedMilliseconds}ms or ${stopwatch.elapsed.inSeconds}s',
        T,
        data: data,
        method: method,
        callerStackTrace: StackTrace.current,
      ),
    );
  }
}
