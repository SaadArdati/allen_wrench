import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:allen_wrench/utils/stream_subscription_mixin.dart';

class _TestStreamSubscriber with StreamSubscriberMixin {}

class _TestWidget extends StatefulWidget {
  const _TestWidget({required this.onInit, this.onBuild});

  final void Function(_TestWidgetState state) onInit;
  final VoidCallback? onBuild;

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with StreamSubscriberStateMixin {
  void handleStreamData() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.onInit(this);
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild?.call();
    return const SizedBox();
  }
}

void main() {
  group('StreamSubscriberMixin', () {
    late _TestStreamSubscriber subscriber;
    late StreamController<int> controller;

    setUp(() {
      subscriber = _TestStreamSubscriber();
      controller = StreamController<int>.broadcast();
    });

    tearDown(() async {
      await subscriber.cancelSubscriptions();
      await controller.close();
    });

    test('should receive stream data', () async {
      final receivedData = <int>[];
      subscriber.listen<int>(
        controller.stream,
        (data) => receivedData.add(data),
      );

      controller.add(1);
      controller.add(2);
      controller.add(3);
      await pumpEventQueue();

      expect(receivedData, equals([1, 2, 3]));
    });

    test('should handle multiple subscriptions to same stream', () async {
      final receivedData1 = <int>[];
      final receivedData2 = <int>[];

      subscriber.listen<int>(
        controller.stream,
        (data) => receivedData1.add(data),
      );

      subscriber.listen<int>(
        controller.stream,
        (data) => receivedData2.add(data),
      );

      controller.add(1);
      await pumpEventQueue();

      expect(receivedData1, equals([1]));
      expect(receivedData2, equals([1]));
    });

    test('should handle pause and resume', () async {
      final receivedData = <int>[];
      final subscription = subscriber.listen<int>(
        controller.stream,
        (data) => receivedData.add(data),
      );

      subscription.pause();
      controller.add(1);
      await pumpEventQueue();
      expect(receivedData, isEmpty);

      subscription.resume();
      await pumpEventQueue();
      expect(receivedData, equals([1]));

      controller.add(2);
      await pumpEventQueue();
      expect(receivedData, equals([1, 2]));

      await subscription.cancel();
    });

    test('should handle errors', () async {
      final errors = <String>[];
      final completer = Completer<void>();

      subscriber.listen<int>(
        controller.stream,
        (data) {},
        onError: (error) {
          errors.add(error.toString());
          completer.complete();
        },
      );

      controller.addError('test error');
      await completer.future;

      expect(errors.single, equals('test error'));
    });

    test(
      'should cancel subscription on error when cancelOnError is true',
      () async {
        final receivedData = <int>[];
        final completer = Completer<void>();

        subscriber.listen<int>(
          controller.stream,
          (data) => receivedData.add(data),
          onError: (error) => completer.complete(),
          cancelOnError: true,
        );

        controller.add(1);
        await pumpEventQueue();
        controller.addError('test error');
        await completer.future;
        controller.add(2);
        await pumpEventQueue();

        expect(receivedData, equals([1]));
      },
    );

    test('should call onDone when stream closes', () async {
      final completer = Completer<void>();

      subscriber.listen<int>(
        controller.stream,
        (data) {},
        onDone: completer.complete,
      );

      await controller.close();
      await completer.future;
      expect(completer.isCompleted, isTrue);
    });

    test('should not leak memory after cancellation', () async {
      final receivedData = <int>[];

      subscriber.listen<int>(
        controller.stream,
        (data) => receivedData.add(data),
      );

      await subscriber.cancelSubscriptions();
      controller.add(1);
      await pumpEventQueue();

      expect(receivedData, isEmpty);
    });

    test('should handle concurrent streams', () async {
      final receivedData = <List<int>>[];
      final streams = List.generate(
        3,
        (i) => Stream.fromIterable([i, i + 1, i + 2]),
      );

      for (final stream in streams) {
        subscriber.listen<int>(stream, (data) => receivedData.add([data]));
      }

      await pumpEventQueue();
      expect(
        receivedData,
        equals([
          [0],
          [1],
          [2],
          [1],
          [2],
          [3],
          [2],
          [3],
          [4],
        ]),
      );
    });
  });

  group('StreamSubscriberStateMixin', () {
    late StreamController<int> controller;

    setUp(() {
      controller = StreamController<int>.broadcast();
    });

    tearDown(() async {
      await controller.close();
    });

    testWidgets('should clean up subscriptions on dispose', (tester) async {
      final receivedData = <int>[];

      await tester.pumpWidget(
        _TestWidget(
          onInit: (state) {
            state.listen<int>(
              controller.stream,
              (data) => receivedData.add(data),
            );
          },
        ),
      );

      controller.add(1);
      await tester.pump();
      expect(receivedData, equals([1]));

      await tester.pumpWidget(const SizedBox());
      controller.add(2);
      await tester.pump();

      expect(receivedData, equals([1]));
    });

    testWidgets('should handle setState during stream events', (tester) async {
      final buildCount = ValueNotifier<int>(0);

      await tester.pumpWidget(
        _TestWidget(
          onInit: (state) {
            state.listen<int>(
              controller.stream,
              (_) => state.handleStreamData(),
            );
          },
          onBuild: () => buildCount.value++,
        ),
      );

      expect(buildCount.value, equals(1));

      controller.add(1);
      await tester.pump();
      await tester.pump(); // Extra pump for setState to complete

      expect(buildCount.value, equals(2));
    });

    testWidgets('should handle stream errors', (tester) async {
      final errors = <String>[];
      final completer = Completer<void>();

      await tester.pumpWidget(
        _TestWidget(
          onInit: (state) {
            state.listen<int>(
              controller.stream,
              (data) {},
              onError: (error) {
                errors.add(error.toString());
                completer.complete();
              },
            );
          },
        ),
      );

      controller.addError('test error');
      await completer.future;

      expect(errors.single, equals('test error'));
    });
  });
}
