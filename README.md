# Allen Wrench

[![pub package](https://img.shields.io/pub/v/allen_wrench.svg)](https://pub.dev/packages/allen_wrench)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A collection of opinionated utilities for Flutter and Dart applications, focusing on logging, state utilities, and common development patterns.

## Features

### 🔍 Structured Logging

A powerful logging system built on top of the `logger` package with:

- Structured log messages with class and method context
- Beautiful console output with emoji support
- Stack trace formatting with async chain support
- Log levels: TRACE, DEBUG, INFO, WARNING, ERROR, FATAL
- Optional file output support
- Mixin support for easy integration

```dart
void main() {
  AllenLogger.init();
}

// Basic usage
AllenLogger.info<MyClass>("User logged in", data: {"userId": "123"});
// OR
AllenLogger.info("User logged in", data: {"userId": "123"});

// Using the mixin
class MyService with LoggerMixin<MyService> {
  void doSomething() {
    info("Operation started");
  }
}
```

### ⚡ State Utilities

A collection of lightweight mixins to handle common state-related tasks in Flutter applications.

#### Async Operation Handler

The `AsyncStateMixin` provides a simple, typed wrapper around async operations with loading, success, and error states. Perfect for handling API calls, data loading, and other async tasks. Features include:

- Automatic loading on widget initialization (configurable via `loadOnInit`)
- Two loading modes: full-screen and alert-only
- Automatic state management via `ValueNotifier`
- Type-safe success state
- Comprehensive error handling with messages and stack traces
- Reload capabilities with different loading modes

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with AsyncStateMixin<String, MyWidget> {
  @override
  FutureOr<String> fetch() async {
    // Implement your data fetching logic here
    return await dataService.fetchData();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stateNotifier,
      builder: (context, state, _) {
        return switch (state) {
          // Full-screen loading
          LoadingOperation(alertOnly: false) => const CircularProgressIndicator(),
          // Alert-only loading (minimal UI disruption)
          LoadingOperation(alertOnly: true) => const SmallLoadingIndicator(),
          // Success with typed data
          SuccessOperation<String>(data: final result) => Text(result),
          // Error with full context
          ErrorOperation(message: final message) => ErrorView(
            message: message,
            onRetry: () => reload(), // Convenient reload method
          ),
        };
      },
    );
  }
}
```

Key Methods:
- `fetch()`: Override to implement your data loading logic
- `load(alertOnly: bool)`: Trigger a load with optional alert-only mode
- `reload({alertOnly = true})`: Convenience method for reloading with alert-only by default
- `errorMessage(exception, stackTrace)`: Override to customize error messages

Usage with Other Mixins:
```dart
class _MyWidgetState extends State<MyWidget> 
    with AsyncStateMixin<Data, MyWidget>, LoggerMixin<MyWidget> {
  
  @override
  FutureOr<Data> fetch() async {
    try {
      info('Starting data fetch...');
      final result = await dataService.fetchData();
      info('Fetch completed successfully');
      return result;
    } catch (e, s) {
      error('Fetch failed', error: e, stackTrace: s);
      rethrow;
    }
  }
}
```

#### Stream Subscription Helper

The `StreamSubscriberMixin` and `StreamSubscriberStateMixin` provide convenient utilities for managing stream subscriptions with automatic cleanup:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with StreamSubscriberStateMixin {
  @override
  void initState() {
    super.initState();
    // Subscription is automatically cleaned up in dispose()
    listen(
      userStream,
      (user) => setState(() => this.user = user),
    );
  }
}
```

### 🎯 Utilities

#### Unique ID Generation

Generate unique, sortable, timestamp-based IDs:

```dart
final id = generateId(); // Returns a 20-character string identifier
```

Features of generated IDs:
- Based on timestamps for natural sorting
- Contains 72-bits of random data to prevent collisions
- Lexicographically sortable
- Monotonically increasing
- URL-safe characters

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  allen_wrench: ^1.0.0
```

### Initialize Logging

```dart
void main() {
  AllenLogger.init(
    enableFileOutput: true,
    filePath: 'logs/app.log',
    printEmojis: true,
    lineLength: 120,
  );
  
  runApp(MyApp());
}
```

## Additional Documentation

### Logging Levels

- **TRACE**: Very detailed logs for fine-grained debugging
- **DEBUG**: Development-time debugging information
- **INFO**: General operational events
- **WARNING**: Potentially harmful situations
- **ERROR**: Error events that might still allow the application to continue running
- **FATAL**: Very severe error events that will presumably lead the application to abort

### Operation States

The `AsyncStateMixin` provides three states:

1. **LoadingOperation**: Operation in progress
   ```dart
   LoadingOperation(alertOnly: false)
   ```

2. **SuccessOperation**: Operation completed successfully
   ```dart
   SuccessOperation(data: result)
   ```

3. **ErrorOperation**: Operation failed
   ```dart
   ErrorOperation(
     alertOnly: false,
     message: "Failed to load data",
     exception: e,
     stackTrace: s,
   )
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

## License

```
BSD 3-Clause License

Copyright (c) 2025, Saad Ardati
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
