# Allen Wrench

[![pub package](https://img.shields.io/pub/v/allen_wrench.svg)](https://pub.dev/packages/allen_wrench)

A collection of opinionated utilities for Flutter and Dart applications, focusing on logging, state utilities, and common development patterns.

## Key Features

- **Structured Logging**
  - Structured log messages with class and method context
  - Beautiful console output
  - Stack trace formatting with async chain support
  - Multiple log levels (TRACE, DEBUG, INFO, WARNING, ERROR, FATAL)
  - Optional file output support
  - Easy integration via mixins

- **State Management Utilities**
  - AsyncStateMixin for handling async operations
  - Typed wrapper for loading, success, and error states
  - Stream subscription management with automatic cleanup

- **Development Utilities**
  - Unique ID generation with timestamp-based sorting
  - URL-safe character encoding
  - Monotonically increasing IDs
  - 72-bit random data for collision prevention

## Features

### Structured Logging

A powerful logging system built on top of the `logger` package with:

- Structured log messages with class and method context
- Beautiful console output with emoji support
- Stack trace formatting with async chain support
- Log levels: TRACE, DEBUG, INFO, WARNING, ERROR, FATAL
- Optional file output support
- Mixin support for easy integration

#### Example Log Output

![Example of Allen Wrench logs](https://raw.githubusercontent.com/SaadArdati/allen_wrench/main/assets/logs.png)

```
   INFO ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   INFO │ [MyHomePage.info] Starting fetch. simulateError: false
   INFO └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   INFO ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   INFO │ [MyHomePage.info] Fetch completed successfully (count: 1).
   INFO └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  DEBUG ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  DEBUG │ [MyHomePage.debug] simulateError set to true
  DEBUG └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  ERROR ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  ERROR │ [MyHomePage.error] Something went wrong! :(
  ERROR ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
  ERROR │ Exception: Simulated error on fetch attempt #2
  ERROR ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
  ERROR │ 
  ERROR │ ╔══════════════════════════════ asynchronous gap ══════════════════════════════╗
  ERROR │ #0 AsyncStateMixin.load  package:allen_wrench/utils/async_state_mixin.dart  152:22
  ERROR └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

#### Initialize Logging

Basic initialization with default settings:
```dart
void main() {
  AllenLogger.init();
  runApp(MyApp());
}
```

Advanced initialization with custom configuration:
```dart
void main() {
  AllenLogger.init(
    // Enable file output for persistent logging
    enableFileOutput: true,
    filePath: 'logs/app.log',
    
    // Customize output format
    printEmojis: true,
    lineLength: 120,
    
    // Set minimum log level (defaults to all in debug, info in release)
    verbose: true,
    
    // Customize output style
    noBoxing: false,
    noPrefix: false,
  );
  
  runApp(MyApp());
}
```

#### Basic Usage

```dart
// Basic logging
AllenLogger.info("User logged in", data: {"userId": "123"});

// Logging with class context
AllenLogger.info<MyClass>("Operation completed", data: {"status": "success"});

// Using the mixin
class MyService with LoggerMixin<MyService> {
  void doSomething() {
    info("Operation started");
  }
}

// Error logging with stack trace
try {
  // ... some operation
} catch (e, stack) {
  AllenLogger.error<MyClass>(
    "Operation failed",
    error: e,
    stackTrace: stack,
    data: {"operation": "sync"},
  );
}
```

#### Logging Levels

- **TRACE**: Very detailed logs for fine-grained debugging
- **DEBUG**: Development-time debugging information
- **INFO**: General operational events
- **WARNING**: Potentially harmful situations
- **ERROR**: Error events that might still allow the application to continue running
- **FATAL**: Very severe error events that will presumably lead the application to abort

### State Utilities

A collection of lightweight mixins to handle common state-related tasks in Flutter applications.

#### Async Operation Handler

The `AsyncStateMixin` provides a simple, typed wrapper around async operations with loading, success, and error states. Perfect for handling API calls, data loading, and other async tasks. Features include:

- Automatic loading on widget initialization (configurable via `loadOnInit`).
- Disambiguated UI for loading and error states.
- Optimized state management via `ValueNotifier`.
- Type-safe success state.
- Comprehensive error handling with messages and stack traces.
- Reload capabilities with different loading modes.

##### Operation States

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

##### Basic Usage

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
          LoadingOperation() => const CircularProgressIndicator(),
          ErrorOperation() => TextButton(
            onPressed: reload,
            child: const Text('Failed to load - Tap to retry'),
          ),
          SuccessOperation(data: final result) => Text(result),
        };
      },
    );
  }
}
```

##### Advanced Usage #1

This example demonstrates loading and displaying an image using AsyncStateMixin:

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageLoader extends StatefulWidget {
  const ImageLoader({super.key});

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader>
    with AsyncStateMixin<Uint8List, ImageLoader> {
  
  @override
  FutureOr<Uint8List> fetch() async {
    final response = await http.get(
      Uri.parse('https://picsum.photos/300/300'),
    );
    
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to load image: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OperationState>(
      valueListenable: stateNotifier,
      builder: (context, state, _) => switch (state) {
        LoadingOperation() => 
          const CircularProgressIndicator(),
        ErrorOperation() => 
          TextButton(
            onPressed: reload,
            child: const Text('Failed to load - Tap to retry'),
          ),
        SuccessOperation(data: final imageData) => 
          GestureDetector(
            onTap: reload,
            child: Image.memory(
              imageData,
              width: 300,
              height: 300,
            ),
          ),
      },
    );
  }
}
```

##### Advanced Usage #2

This example demonstrates comprehensive state handling with logging:

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  AllenLogger.init();
  runApp(const MyApp());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AsyncStateMixin<Uint8List, MyHomePage>, LoggerMixin<MyHomePage> {
  Uint8List? lastLoadedImage;

  @override
  FutureOr<Uint8List> fetch() async {
    try {
      info('Starting image fetch');
      final response = await http.get(
        Uri.parse('https://picsum.photos/300/300'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load image: ${response.statusCode}');
      }

      lastLoadedImage = response.bodyBytes;
      info('Image fetch completed');
      return lastLoadedImage!;
    } catch (e, s) {
      error('Image fetch failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Widget _buildImageView() {
    if (lastLoadedImage == null) {
      return const Text('No image loaded yet');
    }
    return Image.memory(
      lastLoadedImage!,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Demo'),
        actions: [
          TextButton(
            onPressed: () => load(alertOnly: false),
            child: const Text('Full'),
          ),
          TextButton(
            onPressed: () => reload(),
            child: const Text('Alert'),
          ),
        ],
      ),
      body: ValueListenableBuilder<OperationState>(
        valueListenable: stateNotifier,
        builder: (context, state, _) => switch (state) {
          LoadingOperation(alertOnly: false) => const Center(
            child: CircularProgressIndicator(),
          ),
          ErrorOperation(alertOnly: false) => Center(
            child: TextButton(
              onPressed: reload,
              child: const Text('Error - Tap to retry'),
            ),
          ),
          // Alert-only states show the current image if available
          LoadingOperation() || ErrorOperation() || SuccessOperation() => 
            _buildImageView(),
        },
      ),
    );
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

### Development Utilities

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

## Additional Documentation

### Development Utilities

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

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
