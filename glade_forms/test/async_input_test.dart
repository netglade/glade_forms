// ignore_for_file: cascade_invocations, avoid-async-call-in-sync-function, prefer-async-await

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fake_async/fake_async.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Server {
  static const Set<String> taken = {'taken'};

  final List<Completer<bool>> pending = [];

  int calls = 0;

  bool manual;

  _Server({this.manual = false});

  Future<bool> isAvailable(String value) {
    calls++;

    if (manual) {
      final completer = Completer<bool>();
      pending.add(completer);

      return completer.future;
    }

    return Future.value(!taken.contains(value));
  }
}

GladeStringInput _usernameInput(_Server server, {Duration debounce = const Duration(milliseconds: 300)}) => .new(
  inputKey: 'username',
  value: '',
  useTextEditingController: false,
  isRequired: false,
  validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken', devMessage: (_) => 'Taken')).build(
    asyncDebounce: debounce,
  ),
);

void main() {
  setUp(GladeForms.initialize);

  test('input without async parts reports hasAsyncValidation false and notRun', () async {
    // arrange
    final input = GladeStringInput(value: 'a', useTextEditingController: false);

    // act
    final result = await input.validateAsync();

    // assert
    expect(input.hasAsyncValidation, isFalse);
    expect(input.isValidating, isFalse);
    expect(result.asyncState, equals(AsyncValidationState.notRun));
  });

  test('getters do not trigger async validation', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server);

      // act
      final _ = input.isValid;
      final _ = input.validatorResult;
      final _ = input.validationErrors;
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();

      // assert
      expect(server.calls, isZero);
      expect(input.isValidating, isFalse);
    });
  });

  test('validate() triggers async validation for current value', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server);
      input.updateValue('taken');
      // value change already scheduled; let the debounce elapse
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(server.calls, equals(1));

      // act: cache exists, validate() must not re-run
      final result = input.validate();

      // assert
      expect(server.calls, equals(1), reason: 'cached result is reused');
      expect(result.asyncState, equals(AsyncValidationState.done));
      expect(result.errors.singleOrNull?.key, equals('taken'));
    });
  });

  test('value change schedules async and merges rapid changes into one request', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server);

      // act
      input.updateValue('t');
      async.elapse(const Duration(milliseconds: 100));
      input.updateValue('ta');
      async.elapse(const Duration(milliseconds: 100));
      input.updateValue('taken');

      expect(input.isValidating, isTrue);
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.debouncing));

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(1));
      expect(input.isValidating, isFalse);
      expect(input.isValid, isFalse);
      expect(input.validationErrors.singleOrNull?.key, equals('taken'));
      expect(input.errorFormatted(), equals('Taken'));
    });
  });

  test('unbound input applies strict mode while pending', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server);

      // act
      input.updateValue('free');

      // assert
      expect(input.validatorResult.isValid, isTrue, reason: 'known results have no error');
      expect(input.isValid, isFalse, reason: 'strict: pending is invalid');
      expect(input.isValidAndWithoutWarnings, isFalse);

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      expect(input.isValid, isTrue);
    });
  });

  test('sync error skips async and does not enter pending', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = GladeStringInput(
        value: 'x',
        useTextEditingController: false,
        validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken')).build(),
      );

      // act
      input.updateValue('');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(server.calls, isZero);
      expect(input.isValidating, isFalse);
      expect(input.isValid, isFalse);
      expect(input.validationErrors.singleOrNull?.key, equals(GladeValidationsKeys.stringEmpty));
    });
  });

  test('response for outdated value is discarded, also when changing back', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server(manual: true);
      final input = _usernameInput(server, debounce: .zero);

      // act
      input.updateValue('first');
      async.flushMicrotasks();
      input.updateValue('second');
      async.flushMicrotasks();
      input.updateValue('first');
      async.flushMicrotasks();

      expect(server.calls, equals(3));

      server.pending.firstOrNull?.complete(false);
      server.pending.elementAtOrNull(1)?.complete(false);
      async.flushMicrotasks();

      // assert: still pending, nothing cached
      expect(input.isValidating, isTrue);
      expect(input.validationErrors, isEmpty);

      server.pending.lastOrNull?.complete(true);
      async.flushMicrotasks();

      expect(input.isValidating, isFalse);
      expect(input.isValid, isTrue);
      expect(input.validatorResult.asyncValidatedValue, equals('first'));
    });
  });

  test('same value does not retrigger', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server, debounce: .zero);

      // act
      input.updateValue('free');
      async.flushMicrotasks();
      input.updateValue('free');
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(1));
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.done));
    });
  });

  test('validateAsync bypasses debounce and returns full result', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server);
      ValidatorResult<String>? result;

      // act
      input.updateValue('taken');
      unawaited(input.validateAsync().then((r) => result = r));
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(1));
      expect(result?.errors.singleOrNull?.key, equals('taken'));
      expect(result?.asyncValidatedValue, equals('taken'));
    });
  });

  test('validateAsync uses cache, force re-runs', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server, debounce: .zero);

      // act
      input.updateValue('free');
      async.flushMicrotasks();
      unawaited(input.validateAsync());
      async.flushMicrotasks();

      expect(server.calls, equals(1));

      unawaited(input.validateAsync(force: true));
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(2));
    });
  });

  test('textFormFieldInputValidator triggers and reads cache, null while pending', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = _usernameInput(server);

      // act
      input.updateValue('taken');
      final whilePending = input.textFormFieldInputValidator('taken');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      // ignore: avoid-duplicate-initializers, the same call is repeated on purpose once the debounce elapsed
      final afterDone = input.textFormFieldInputValidator('taken');

      // assert
      expect(whilePending, isNull);
      expect(afterDone, equals('Taken'));
      expect(server.calls, equals(1));
    });
  });

  test('textFormFieldInputValidator on pure input with initial value triggers async', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = GladeStringInput(
        initialValue: 'taken',
        useTextEditingController: false,
        validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken', devMessage: (_) => 'Taken')).build(),
      );

      // act
      final first = input.textFormFieldInputValidator('taken');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(first, isNull);
      expect(server.calls, equals(1));
      // ignore: use-existing-variable, the call is repeated on purpose once async validation finished
      expect(input.textFormFieldInputValidator('taken'), equals('Taken'));
    });
  });

  test('conversion error disables triggers', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final input = GladeIntInput(
        value: 1,
        validator: (v) =>
            // ignore: function-always-returns-null, the async validator never reports an error
            (v..customAsync((value, key) async {
                  calls++;

                  return null;
                }))
                .build(asyncDebounce: .zero),
      );

      // act
      input.updateValueWithString('not-a-number');
      final _ = input.validate();
      async.flushMicrotasks();

      // assert
      expect(input.hasConversionError, isTrue);
      expect(calls, isZero);
      expect(input.isValidating, isFalse);
    });
  });

  test('ChangesInfo carries pending state', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      ChangesInfo<String>? info;
      final input = GladeStringInput(
        value: '',
        useTextEditingController: false,
        onChange: (i) => info = i,
        validator: (v) => (v..satisfyAsync(server.isAvailable)).build(),
      );

      // act
      input.updateValue('free');

      // assert
      expect(info?.validatorResult?.asyncState, equals(AsyncValidationState.debouncing));
    });
  });

  test('resetToInitialValue and dispose invalidate', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server(manual: true);
      final input = _usernameInput(server, debounce: .zero);

      // act
      input.updateValue('free');
      async.flushMicrotasks();
      input.resetToInitialValue();

      // assert
      expect(input.isValidating, isFalse);
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.notRun));

      server.pending.firstOrNull?.complete(true);
      async.flushMicrotasks();
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.notRun), reason: 'stale response ignored');

      input.updateValue('other');
      async.flushMicrotasks();
      input.dispose();
      server.pending.lastOrNull?.complete(true);
      async.flushMicrotasks();

      expect(input.isValidating, isFalse, reason: 'disposed input does not validate');
    });
  });

  test('async failure uses defaultAsyncValidationFailedMessage', () {
    FakeAsync().run((async) {
      // arrange
      final input = GladeStringInput(
        value: 'a',
        useTextEditingController: false,
        defaultValidationTranslations: const DefaultValidationTranslations(
          defaultAsyncValidationFailedMessage: 'Server unavailable',
        ),
        validator: (v) => (v..customAsync((value, key) async => throw Exception('boom'))).build(asyncDebounce: .zero),
      );

      // act
      input.updateValue('b');
      async.flushMicrotasks();

      // assert
      expect(input.validationErrors.singleOrNull?.isAsyncValidationFailedError, isTrue);
      expect(input.errorFormatted(), equals('Server unavailable'));
    });
  });
  test('dependency change is reflected by the sync half even though async results are cached', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final minLength = GladeIntInput(value: 1, inputKey: 'min-length');
      final username = GladeStringInput(
        inputKey: 'username',
        value: '',
        useTextEditingController: false,
        isRequired: false,
        dependencies: () => [minLength],
        validator: (v) =>
            (v
                  ..satisfy((value) => value.length >= minLength.value, key: 'too-short')
                  ..satisfyAsync(server.isAvailable, key: 'taken', devMessage: (_) => 'Taken'))
                .build(asyncDebounce: .zero, stopOnFirstError: false),
      );

      // act
      username.updateValue('free');
      async.flushMicrotasks();

      expect(username.isValid, isTrue);
      expect(server.calls, equals(1));

      minLength.updateValue(10);

      // assert
      expect(username.validationErrors.map((e) => e.key), equals(['too-short']));
      expect(server.calls, equals(1), reason: 'the value did not change, so no new request');

      minLength.updateValue(1);

      expect(username.validationErrors, isEmpty);
      expect(username.validatorResult.asyncState, equals(AsyncValidationState.done));
    });
  });

  test('isValidating is broadcast when validation starts from a form field validator', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final model = _ModelWithAsyncInput(server);
      var notifications = 0;
      void onModelChanged() => notifications++;
      model.addListener(onModelChanged);

      // act
      final message = model.username.textFormFieldInputValidator('initial');

      // assert
      expect(message, isNull);
      expect(model.isValidating, isTrue);
      expect(notifications, equals(0), reason: 'triggers run inside build, notification must be deferred');

      async.flushMicrotasks();

      expect(notifications, equals(1), reason: 'listeners learn that validation started');

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      expect(model.isValidating, isFalse);
      expect(notifications, greaterThanOrEqualTo(2), reason: 'and that it finished');

      model.dispose();
    });
  });

  test('debouncing is distinguishable from running', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server(manual: true);
      final input = _usernameInput(server);

      // act
      input.updateValue('free');

      // assert
      expect(input.isValidating, isTrue);
      expect(input.isAsyncValidationRunning, isFalse);

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      expect(input.isValidating, isTrue, reason: 'still validating once the request is in flight');
      expect(input.isAsyncValidationRunning, isTrue);

      server.pending.singleOrNull?.complete(true);
      async.flushMicrotasks();

      expect(input.isValidating, isFalse, reason: 'validation finished once the request completed');
      expect(input.isAsyncValidationRunning, isFalse, reason: 'no request is in flight after completion');
    });
  });

  test('failed request is displayed but retried by validateAsync', () {
    FakeAsync().run((async) {
      // arrange
      var shouldFail = true;
      var calls = 0;
      final input = GladeStringInput(
        value: 'a',
        useTextEditingController: false,
        validator: (v) =>
            (v..customAsync((value, key) async {
                  calls++;

                  if (shouldFail) throw Exception('network down');

                  return null;
                }))
                .build(asyncDebounce: .zero),
      );

      // act
      input.updateValue('b');
      async.flushMicrotasks();

      // assert
      expect(input.validationErrors.singleOrNull?.isAsyncValidationFailedError, isTrue);

      final _ = input.validate();
      async.flushMicrotasks();

      expect(calls, equals(1), reason: 'passive triggers must not retry a failing server');

      shouldFail = false;
      expect(shouldFail, isFalse, reason: 'the retried request must observe the server recovering');
      unawaited(input.validateAsync());
      async.flushMicrotasks();

      expect(calls, equals(2));
      expect(input.validationErrors, isEmpty);
    });
  });
}

class _ModelWithAsyncInput extends GladeModel {
  final _Server server;

  late GladeStringInput username;

  @override
  List<GladeInput<Object?>> get inputs => [username];

  _ModelWithAsyncInput(this.server);

  @override
  void initialize() {
    username = GladeStringInput(
      inputKey: 'username',
      initialValue: 'initial',
      useTextEditingController: false,
      validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken', devMessage: (_) => 'Taken')).build(),
    );

    super.initialize();
  }
}
