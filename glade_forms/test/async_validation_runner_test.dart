// ignore_for_file: cascade_invocations, avoid-async-call-in-sync-function, prefer-async-await

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fake_async/fake_async.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms/src/core/input/async_validation_runner.dart';
import 'package:test/test.dart';

typedef AsyncPredicate = Future<bool> Function(String value);

void main() {
  setUp(GladeForms.initialize);

  ValidatorInstance<String> instanceWith(
    AsyncPredicate predicate, {
    Duration debounce = const Duration(milliseconds: 300),
  }) => (GladeValidator<String>()..satisfyAsync(predicate, key: 'server', devMessage: (_) => 'Taken')).build(
    asyncDebounce: debounce,
  );

  // ignore: no-empty-block, the completion callback is irrelevant for these tests
  void noop() {}

  test('schedule waits for debounce, then runs and caches', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      var completed = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) async {
          calls++;

          return value != 'taken';
        }),
        onCompleted: () => completed++,
      );

      // act
      runner.schedule('taken');

      // assert
      expect(runner.isValidating, isTrue);
      expect(calls, isZero);

      async.elapse(const Duration(milliseconds: 299));
      expect(calls, equals(0), reason: 'debounce did not elapse yet');

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(calls, equals(1));
      expect(runner.isValidating, isFalse);
      expect(runner.cachedResult?.isNotValid, isTrue);
      expect(runner.cachedResult?.asyncValidatedValue, equals('taken'));
      expect(completed, equals(1));
    });
  });

  test('schedule is no-op while pending or cached', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) async {
          calls++;

          return true;
        }),
        onCompleted: noop,
      );

      // act
      runner.schedule('a');
      runner.schedule('a');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      runner.schedule('a');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
    });
  });

  test('Duration.zero debounce runs immediately', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith(
          (value) async {
            calls++;

            return true;
          },
          debounce: .zero,
        ),
        onCompleted: noop,
      );

      // act
      runner.schedule('a');
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
      expect(runner.cachedResult, isNotNull);
    });
  });

  test('onValueChanged cancels debounce and drops cache', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) async {
          calls++;

          return true;
        }),
        onCompleted: noop,
      );

      // act
      runner.schedule('a');
      async.elapse(const Duration(milliseconds: 200));
      runner.onValueChanged();
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(calls, equals(0));
      expect(runner.isValidating, isFalse);
      expect(runner.cachedResult, isNull);
    });
  });

  test('stale response is discarded and does not call onCompleted', () {
    FakeAsync().run((async) {
      // arrange
      final completers = <Completer<bool>>[];
      var completed = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith(
          (value) {
            final completer = Completer<bool>();
            completers.add(completer);

            return completer.future;
          },
          debounce: .zero,
        ),
        onCompleted: () => completed++,
      );

      // act
      runner.schedule('first');
      async.flushMicrotasks();
      runner.onValueChanged();
      runner.schedule('second');
      async.flushMicrotasks();

      completers.firstOrNull?.complete(false);
      async.flushMicrotasks();

      // assert: first response ignored
      expect(runner.cachedResult, isNull);
      expect(runner.isValidating, isTrue);
      expect(completed, equals(0));

      completers.lastOrNull?.complete(true);
      async.flushMicrotasks();

      expect(runner.cachedResult?.isValid, isTrue);
      expect(runner.cachedResult?.asyncValidatedValue, equals('second'));
      expect(completed, equals(1));
    });
  });

  test('runNow bypasses debounce and shares in-flight request', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final completer = Completer<bool>();
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) {
          calls++;

          return completer.future;
        }),
        onCompleted: noop,
      );
      ValidatorResult<String>? first;
      ValidatorResult<String>? second;

      // act
      runner.schedule('a');
      unawaited(runner.runNow('a').then((r) => first = r));
      unawaited(runner.runNow('a').then((r) => second = r));
      async.flushMicrotasks();

      expect(calls, equals(1));

      completer.complete(true);
      async.flushMicrotasks();

      // assert
      expect(first, isNotNull);
      expect(identical(first, second), isTrue);
      expect(runner.isValidating, isFalse);
    });
  });

  test('runNow returns cache when present without new request', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith(
          (value) async {
            calls++;

            return true;
          },
          debounce: .zero,
        ),
        onCompleted: noop,
      );
      ValidatorResult<String>? result;

      // act
      runner.schedule('a');
      async.flushMicrotasks();
      unawaited(runner.runNow('a').then((r) => result = r));
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
      expect(identical(result, runner.cachedResult), isTrue);
    });
  });

  test('awaiting caller of an invalidated run still receives the stale result', () {
    FakeAsync().run((async) {
      // arrange
      final completer = Completer<bool>();
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) => completer.future, debounce: .zero),
        onCompleted: noop,
      );
      ValidatorResult<String>? result;

      // act
      unawaited(runner.runNow('old').then((r) => result = r));
      async.flushMicrotasks();
      runner.invalidate();
      completer.complete(false);
      async.flushMicrotasks();

      // assert
      expect(result?.asyncValidatedValue, equals('old'));
      expect(runner.cachedResult, isNull);
    });
  });
}
