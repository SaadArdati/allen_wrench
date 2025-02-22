import 'dart:async';

import 'package:allen_wrench/allen_wrench.dart';
import 'package:flutter/material.dart';

void main() {
  AllenLogger.init();
  runApp(const MyApp());
}

/// Root widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allen Wrench Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

/// Main home page widget.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Home page state that uses both the LoadingMixin and LoggerMixin.
///
/// The [AsyncStateMixin] provides asynchronous loading behavior and exposes a
/// ValueNotifier called [stateNotifier] with the current [OperationState].
///
/// The [LoggerMixin] provides logging functions (such as [info] for info, [debug]
/// for debug, etc.) to track behavior.
class _MyHomePageState extends State<MyHomePage>
    with AsyncStateMixin<String, MyHomePage>, LoggerMixin<MyHomePage> {
  /// A toggle to simulate an error during the fetch.
  bool simulateError = false;

  /// A counter to show that state is updated on every successful fetch.
  int fetchCount = 0;

  /// Simulates a network/data fetch.
  ///
  /// If [simulateError] is true, an error is thrown; otherwise, the method
  /// waits 2 seconds to simulate network latency and increments [fetchCount].
  @override
  FutureOr<String> fetch() async {
    try {
      info('Starting fetch. simulateError: $simulateError');
      await Future.delayed(const Duration(seconds: 2));
      if (simulateError) {
        throw Exception('Simulated error on fetch attempt #${fetchCount + 1}');
      }
      fetchCount++;
      info('Fetch completed successfully (count: $fetchCount).');

      return 'Fetch successful (count: $fetchCount)';
    } catch (e, s) {
      error('Something went wrong! :(', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoadingMixin Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Simulate Error:'),
                Switch(
                  value: simulateError,
                  onChanged: (value) {
                    setState(() {
                      simulateError = value;
                      debug('simulateError set to $simulateError');
                    });
                  },
                ),
              ],
            ),
          ),
          // Buttons to trigger reloads.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    info('Manual reload requested with alertOnly=false');
                    load(alertOnly: false);
                  },
                  child: const Text('Reload (alertOff)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    info('Manual reload requested with alertOnly=true');
                    reload(alertOnly: true);
                  },
                  child: const Text('Reload (alertOn)'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: ValueListenableBuilder<OperationState>(
                valueListenable: stateNotifier,
                builder:
                    (context, state, _) => switch (state) {
                      LoadingOperation op when !op.alertOnly => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading data...'),
                        ],
                      ),
                      ErrorOperation op when !op.alertOnly => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${op.message}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => reload(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                      ErrorOperation() ||
                      LoadingOperation() ||
                      SuccessOperation() => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data loaded successfully!\nFetch count: $fetchCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    },
              ),
            ),
          ),
          // Display the current state type for debugging.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder<OperationState>(
              valueListenable: stateNotifier,
              builder: (context, state, _) {
                return Text(
                  'Current State: ${state.runtimeType}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
