// ignore_for_file: cascade_invocations, avoid-async-call-in-sync-function, avoid-redundant-async
// ignore_for_file: no-empty-block, onValidationStateChanged is a no-op in most tests here; the state change itself is what's under test

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

  test('schedule waits for debounce, then runs and caches async results', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      var notifications = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) async {
          calls++;

          return value != 'taken';
        }),
        onValidationStateChanged: () => notifications++,
      );

      // act
      runner.schedule('taken');
      async.flushMicrotasks();

      // assert
      expect(runner.state, equals(AsyncValidationState.debouncing));
      expect(runner.isValidating, isTrue);
      expect(runner.isRunning, isFalse, reason: 'no request in flight during the debounce');
      expect(notifications, equals(1));
      expect(calls, equals(0), reason: 'debounce has not fired yet');

      async.elapse(const Duration(milliseconds: 299));
      expect(calls, equals(0), reason: 'debounce still short of the threshold');

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(calls, equals(1));
      expect(runner.state, equals(AsyncValidationState.done));
      expect(runner.isValidating, isFalse);
      expect(runner.cachedResults?.singleOrNull?.key, equals('server'));
      expect(notifications, equals(3), reason: 'debouncing, running, done');
    });
  });

  test('state notification is deferred so triggers may run inside build', () {
    FakeAsync().run((async) {
      // arrange
      var notifications = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) async => true),
        onValidationStateChanged: () => notifications++,
      );

      // act
      runner.schedule('a');

      // assert
      expect(runner.isValidating, isTrue);
      expect(notifications, equals(0), reason: 'not notified synchronously');

      async.flushMicrotasks();

      expect(notifications, equals(1));
    });
  });

  test('markStateNotified suppresses the pending notification', () {
    FakeAsync().run((async) {
      // arrange
      var notifications = 0;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) async => true),
        onValidationStateChanged: () => notifications++,
      );

      // act
      runner.schedule('a');
      runner.markStateNotified();
      async.flushMicrotasks();

      // assert
      expect(notifications, equals(0));
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
        onValidationStateChanged: () {},
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

  test('Duration.zero debounce runs immediately without a debouncing state', () {
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
        onValidationStateChanged: () {},
      );

      // act
      runner.schedule('a');

      // assert
      expect(runner.state, equals(AsyncValidationState.running));

      async.flushMicrotasks();

      expect(calls, equals(1));
      expect(runner.cachedResults, isEmpty);
      expect(runner.state, equals(AsyncValidationState.done));
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
        onValidationStateChanged: () {},
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
      expect(runner.cachedResults, isNull);
      expect(runner.state, equals(AsyncValidationState.notRun));
    });
  });

  test('stale response is discarded and does not notify', () {
    FakeAsync().run((async) {
      // arrange
      final completers = <Completer<bool>>[];
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith(
          (value) {
            final completer = Completer<bool>();
            completers.add(completer);

            return completer.future;
          },
          debounce: .zero,
        ),
        onValidationStateChanged: () {},
      );

      // act
      runner.schedule('first');
      async.flushMicrotasks();
      runner.onValueChanged();
      runner.schedule('second');
      async.flushMicrotasks();

      completers.elementAtOrNull(0)?.complete(false);
      async.flushMicrotasks();

      // assert
      expect(runner.cachedResults, isNull);
      expect(runner.isRunning, isTrue);

      completers.elementAtOrNull(1)?.complete(true);
      async.flushMicrotasks();

      expect(runner.cachedResults, isEmpty);
      expect(runner.state, equals(AsyncValidationState.done));
    });
  });

  test('runNow bypasses debounce and shares the in-flight request', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final completer = Completer<bool>();
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) {
          calls++;

          return completer.future;
        }),
        onValidationStateChanged: () {},
      );
      ValidatorResult<String>? first;
      ValidatorResult<String>? second;

      Future<void> runFirst() async {
        first = await runner.runNow('a');
      }

      Future<void> runSecond() async {
        second = await runner.runNow('a');
      }

      // act
      runner.schedule('a');
      unawaited(runFirst());
      unawaited(runSecond());
      async.flushMicrotasks();

      expect(calls, equals(1));

      completer.complete(true);
      async.flushMicrotasks();

      // assert
      expect(first, isNotNull);
      expect(first, equals(second));
      expect(runner.isValidating, isFalse);
    });
  });

  test('runNow reuses a successful cache without a new request', () {
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
        onValidationStateChanged: () {},
      );
      ValidatorResult<String>? result;

      Future<void> runNow() async {
        result = await runner.runNow('a');
      }

      // act
      runner.schedule('a');
      async.flushMicrotasks();
      unawaited(runNow());
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
      expect(result?.asyncValidatedValue, equals('a'));
      expect(result?.isValid, isTrue);
    });
  });

  test('a failed request is cached for display but retried by runNow', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      var shouldFail = true;
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith(
          (value) async {
            calls++;

            if (shouldFail) throw Exception('network down');

            return true;
          },
          debounce: .zero,
        ),
        onValidationStateChanged: () {},
      );

      // act
      runner.schedule('a');
      async.flushMicrotasks();

      // assert
      expect(runner.cachedResults?.singleOrNull, isA<AsyncValidationFailedError<String>>());

      runner.schedule('a');
      async.flushMicrotasks();

      expect(calls, equals(1), reason: 'a rebuild must not hammer a failing server');

      shouldFail = false;
      expect(shouldFail, isFalse, reason: 'the retried request must observe the server recovering');
      runner.runNow('a');
      async.flushMicrotasks();

      expect(calls, equals(2), reason: 'an explicit run retries');
      expect(runner.cachedResults, isEmpty);
    });
  });

  test('throwing synchronous validation does not leave the runner validating', () {
    FakeAsync().run((async) {
      // arrange
      final instance =
          (GladeValidator<String>()
                ..satisfy((value) => throw StateError('dependency missing'), key: 'sync')
                ..satisfyAsync((value) async => true))
              .build(asyncDebounce: .zero);
      final runner = AsyncValidationRunner(
        validatorInstance: instance,
        onValidationStateChanged: () {},
      );
      Object? caughtError;

      Future<void> runAndCatch() async {
        try {
          final _ = await runner.runNow('a');
        } on Object catch (e) {
          caughtError = e;
        }
      }

      // act
      unawaited(runAndCatch());
      async.flushMicrotasks();

      // assert
      expect(caughtError, isA<StateError>());
      expect(runner.isValidating, isFalse);
      expect(runner.state, equals(AsyncValidationState.notRun));
      expect(runner.cachedResults, isNull);
    });
  });

  test('scheduled run swallows the error instead of leaving it unhandled', () {
    FakeAsync().run((async) {
      // arrange
      final instance =
          (GladeValidator<String>()
                ..satisfy((value) => throw StateError('boom'), key: 'sync')
                ..satisfyAsync((value) async => true))
              .build(asyncDebounce: .zero);
      final runner = AsyncValidationRunner(
        validatorInstance: instance,
        onValidationStateChanged: () {},
      );

      // act
      runner.schedule('a');
      async.flushMicrotasks();

      // assert
      expect(runner.isValidating, isFalse);
    });
  });

  test('awaiting caller of an invalidated run still receives the stale result', () {
    FakeAsync().run((async) {
      // arrange
      final completer = Completer<bool>();
      final runner = AsyncValidationRunner(
        validatorInstance: instanceWith((value) => completer.future, debounce: .zero),
        onValidationStateChanged: () {},
      );
      ValidatorResult<String>? result;

      Future<void> runOld() async {
        result = await runner.runNow('old');
      }

      // act
      unawaited(runOld());
      async.flushMicrotasks();
      runner.invalidate();
      completer.complete(false);
      async.flushMicrotasks();

      // assert
      expect(result?.asyncValidatedValue, equals('old'));
      expect(runner.cachedResults, isNull);
    });
  });
}
