import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:allen_wrench/utils/async_state_mixin.dart';

// Test widget that implements AsyncStateMixin
class TestWidget extends StatefulWidget {
  final bool loadOnInit;
  final Future<String> Function()? customFetch;
  final Duration fetchDelay;

  const TestWidget({
    super.key,
    this.loadOnInit = true,
    this.customFetch,
    this.fetchDelay = const Duration(milliseconds: 100),
  });

  @override
  State<TestWidget> createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget>
    with AsyncStateMixin<String, TestWidget> {
  @override
  bool get loadOnInit => widget.loadOnInit;

  @override
  Future<String> fetch() async {
    await Future.delayed(widget.fetchDelay);
    if (widget.customFetch != null) {
      return widget.customFetch!();
    }
    return 'test data';
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  group('AsyncStateMixin', () {
    testWidgets('initializes with loading state when loadOnInit is true', (
      tester,
    ) async {
      await tester.pumpWidget(const TestWidget());

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.state, isA<LoadingOperation>());
      expect((state.state as LoadingOperation).alertOnly, false);

      // Advance time to complete the fetch
      await tester.pumpAndSettle();
    });

    testWidgets('does not load automatically when loadOnInit is false', (
      tester,
    ) async {
      await tester.pumpWidget(const TestWidget(loadOnInit: false));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.state, isA<LoadingOperation>());
      expect((state.state as LoadingOperation).alertOnly, true);
    });

    testWidgets('transitions through states correctly during successful load', (
      tester,
    ) async {
      await tester.pumpWidget(const TestWidget());

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Initial loading state
      expect(state.state, isA<LoadingOperation>());
      expect((state.state as LoadingOperation).alertOnly, false);

      // Advance time to complete the fetch
      await tester.pumpAndSettle();

      // Should be in success state with correct data
      expect(state.state, isA<SuccessOperation<String>>());
      expect((state.state as SuccessOperation<String>).data, 'test data');
    });

    testWidgets('handles errors correctly', (tester) async {
      final exception = Exception('Test error');

      await tester.pumpWidget(
        TestWidget(customFetch: () async => throw exception),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.state, isA<LoadingOperation>());

      // Advance time to complete the fetch
      await tester.pumpAndSettle();

      // Should be in error state
      expect(state.state, isA<ErrorOperation>());
      final errorState = state.state as ErrorOperation;
      expect(errorState.exception, exception);
      expect(errorState.message, exception.toString());
    });

    testWidgets('reload uses alert-only by default', (tester) async {
      await tester.pumpWidget(const TestWidget(loadOnInit: false));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Trigger reload
      state.reload();

      // Need to pump one frame to let the state update
      await tester.pump();

      // Should be in loading state with alertOnly = true
      expect(state.state, isA<LoadingOperation>());
      expect((state.state as LoadingOperation).alertOnly, true);

      // Advance time to complete the fetch
      await tester.pumpAndSettle();
    });

    testWidgets('load respects alertOnly parameter', (tester) async {
      await tester.pumpWidget(const TestWidget(loadOnInit: false));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Load with alertOnly = true
      state.load(alertOnly: true);

      // Need to pump one frame to let the state update
      await tester.pump();

      expect(state.state, isA<LoadingOperation>());
      expect((state.state as LoadingOperation).alertOnly, true);

      // Advance time to complete the fetch
      await tester.pumpAndSettle();
    });

    testWidgets('disposes stateNotifier properly', (tester) async {
      late ValueNotifier<OperationState> notifier;

      await tester.pumpWidget(
        TestWidget(fetchDelay: const Duration(milliseconds: 100)),
      );

      await tester.pump();

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      notifier = state.stateNotifier;

      // Verify we're in loading state
      expect(state.state, isA<LoadingOperation>());

      // Rebuild with a different widget to trigger dispose
      await tester.pumpWidget(Container());

      // Make sure all timers are handled
      await tester.pumpAndSettle();

      // Try to add a listener after dispose - this should throw
      expect(() => notifier.addListener(() {}), throwsFlutterError);
    });

    testWidgets('handles unmount during async operation', (tester) async {
      // Create a Completer to control when the fetch completes
      final completer = Completer<String>();

      await tester.pumpWidget(TestWidget(customFetch: () => completer.future));

      // Need to pump one frame to let initState complete
      await tester.pump();

      // Verify we're in loading state
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.state, isA<LoadingOperation>());

      // Unmount the widget before completing the future
      await tester.pumpWidget(Container());

      // Complete the future after unmount
      completer.complete('test data');
      await tester.pumpAndSettle();

      // No errors should be thrown
    });

    testWidgets('error state preserves stack trace', (tester) async {
      final exception = Exception('Test error');
      StackTrace? capturedStackTrace;

      await tester.pumpWidget(
        TestWidget(
          customFetch: () async {
            try {
              throw exception;
            } catch (e, stack) {
              capturedStackTrace = stack;
              rethrow;
            }
          },
        ),
      );

      // Need to pump one frame to let initState complete
      await tester.pump();

      // Verify we're in loading state
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.state, isA<LoadingOperation>());

      // Advance time to complete the fetch
      await tester.pumpAndSettle();

      expect(state.state, isA<ErrorOperation>());
      final errorState = state.state as ErrorOperation;
      expect(errorState.stackTrace, capturedStackTrace);
    });
  });
}
