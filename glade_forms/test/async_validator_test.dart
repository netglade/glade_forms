// ignore_for_file: avoid-unsafe-collection-methods, function-always-returns-null

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

typedef ConfigureValidator = void Function(GladeValidator<String> validator);

void main() {
  setUp(GladeForms.initialize);

  ValidatorInstance<String> build(ConfigureValidator configure, {bool stopOnFirstError = true}) {
    final validator = GladeValidator<String>();
    configure(validator);

    return validator.build(stopOnFirstError: stopOnFirstError);
  }

  test('sync valid, async valid returns done result without errors', () async {
    // arrange
    final instance = build((v) => v..satisfyAsync((value) async => true, key: 'a'));

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.isValid, isTrue);
    expect(result.asyncState, equals(AsyncValidationState.done));
    expect(result.asyncValidatedValue, equals('x'));
  });

  test('async error is reported with part key and value', () async {
    // arrange
    final instance = build((v) => v..satisfyAsync((value) async => false, key: 'taken', devMessage: (_) => 'Taken'));

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.isNotValid, isTrue);
    expect(result.errors.single.key, equals('taken'));
    expect(result.errors.single.value, equals('x'));
    expect(result.errors.single.devValidationMessage, equals('Taken'));
  });

  test('async parts run sequentially in declaration order', () async {
    // arrange
    final order = <String>[];
    final instance = build(
      (v) => v
        ..customAsync((value, key) async {
          order.add('first');

          return null;
        })
        ..customAsync((value, key) async {
          order.add('second');

          return null;
        }),
    );

    // act
    await instance.validateAsync('x');

    // assert
    expect(order, equals(['first', 'second']));
  });

  test('sync error with stopOnFirstError skips sync-dependent async parts', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..customAsync((value, key) async {
          called = true;

          return null;
        }),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(called, isFalse);
    expect(result.errors.single.key, equals('sync'));
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isFalse);
  });

  test('runOnlyWhenSyncValid false runs the part even when stopOnFirstError stopped the sync half', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..customAsync(
          (value, key) async {
            called = true;

            return null;
          },
          runOnlyWhenSyncValid: false,
        ),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(called, isTrue, reason: 'the per-part opt-out wins over stopOnFirstError');
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isTrue);
    expect(result.errors.single.key, equals('sync'), reason: 'the async part itself reported nothing');
  });

  test('runOnlyWhenSyncValid false reports its error when the sync half did not stop', () async {
    // arrange
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..satisfyAsync((value) async => false, key: 'async', runOnlyWhenSyncValid: false),
      stopOnFirstError: false,
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.map((e) => e.key), equals(['sync', 'async']));
  });

  test('runOnlyWhenSyncValid true skips part when sync failed and stopOnFirstError is false', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..customAsync((value, key) async {
          called = true;

          return null;
        }),
      stopOnFirstError: false,
    );

    // act
    await instance.validateAsync('x');

    // assert
    expect(called, isFalse);
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isFalse);
  });

  test('runOnlyWhenSyncValid false runs part when sync failed and stopOnFirstError is false', () async {
    // arrange
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..satisfyAsync((value) async => false, key: 'async', runOnlyWhenSyncValid: false),
      stopOnFirstError: false,
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.map((e) => e.key), equals(['sync', 'async']));
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isTrue);
  });

  test('stopOnFirstError stops after first async error', () async {
    // arrange
    var secondCalled = false;
    final instance = build(
      (v) => v
        ..satisfyAsync((value) async => false, key: 'first')
        ..customAsync((value, key) async {
          secondCalled = true;

          return null;
        }),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.single.key, equals('first'));
    expect(secondCalled, isFalse);
  });

  test('warning does not stop and lands in warnings', () async {
    // arrange
    final instance = build(
      (v) => v
        ..satisfyAsync((value) async => false, key: 'warn', severity: .warning)
        ..satisfyAsync((value) async => false, key: 'err'),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.warnings.single.key, equals('warn'));
    expect(result.errors.single.key, equals('err'));
    expect(result.all, hasLength(2));
  });

  test('shouldValidate false skips async part', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..customAsync(
          (value, key) async {
            called = true;

            return null;
          },
          shouldValidate: (value) => value.isNotEmpty,
        ),
    );

    // act
    await instance.validateAsync('');

    // assert
    expect(called, isFalse);
  });

  test('exception without onError produces AsyncValidationFailedError', () async {
    // arrange
    final instance = build((v) => v..customAsync((value, key) async => throw Exception('boom'), key: 'k'));

    // act
    final result = await instance.validateAsync('x');

    // assert
    final error = result.errors.single;
    expect(error, isA<AsyncValidationFailedError<String>>());
    expect(error.key, equals(GladeValidationsKeys.asyncValidationFailed));
    expect((error as AsyncValidationFailedError<String>).partKey, equals('k'));
    expect(error.devValidationMessage, contains('boom'));
  });

  test('exception with onError uses its result', () async {
    // arrange
    final instance = build(
      (v) => v
        ..customAsync(
          (value, key) async => throw Exception('boom'),
          key: 'k',
          onError: (value, error, stackTrace, key) => ValueError(value: value, devMessage: (_) => 'custom', key: key),
        ),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.single.key, equals('k'));
    expect(result.errors.single.devValidationMessage, equals('custom'));
  });

  test('onError returning null treats value as valid', () async {
    // arrange
    final instance = build(
      (v) => v..customAsync((value, key) async => throw Exception('boom'), onError: (_, _, _, _) => null),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.isValid, isTrue);
  });

  test('instance without async parts returns done result equal to sync', () async {
    // arrange
    final instance = build((v) => v..satisfy((value) => value.isNotEmpty, key: 'sync'));

    // act
    final result = await instance.validateAsync('');

    // assert
    expect(result.errors.single.key, equals('sync'));
    expect(result.asyncState, equals(AsyncValidationState.done));
    expect(instance.shouldRunAsyncParts(instance.validate('')), isFalse);
  });
  test('failure severity is always error even when the part is a warning', () async {
    // arrange
    final instance = build(
      (v) => v..customAsync((value, key) async => throw Exception('boom'), key: 'k', severity: .warning),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.single, isA<AsyncValidationFailedError<String>>());
    expect(result.warnings, isEmpty);
  });

  test('throwing shouldValidate is reported as failure instead of escaping', () async {
    // arrange
    final instance = build(
      (v) => v
        ..satisfyAsync(
          (value) async => true,
          key: 'k',
          shouldValidate: (value) => throw StateError('dependency missing'),
        ),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.single, isA<AsyncValidationFailedError<String>>());
  });

  test('runAsyncParts reports hasFailure only when a part threw', () async {
    // arrange
    final failing = build((v) => v..customAsync((value, key) async => throw Exception('boom')));
    final invalid = build((v) => v..satisfyAsync((value) async => false, key: 'async'));

    // act
    final failingOutcome = await failing.runAsyncParts('x', failing.validate('x'));
    final invalidOutcome = await invalid.runAsyncParts('x', invalid.validate('x'));

    // assert
    expect(failingOutcome.hasFailure, isTrue);
    expect(invalidOutcome.hasFailure, isFalse);
    expect(invalidOutcome.results.single.key, equals('async'));
  });

  test('combineWithAsyncResults uses the sync half it is given, so stale sync errors never persist', () async {
    // arrange
    var syncIsValid = true;
    final instance = build(
      (v) => v
        ..satisfy((value) => syncIsValid, key: 'sync')
        ..satisfyAsync((value) async => false, key: 'async'),
    );
    final asyncResults = (await instance.runAsyncParts('x', instance.validate('x'))).results;

    // act
    syncIsValid = false;
    expect(syncIsValid, isFalse, reason: 'the sync half must read the failing value');
    final whileSyncFails = instance.combineWithAsyncResults(
      instance.validate('x'),
      asyncResults,
      asyncValidatedValue: 'x',
    );

    syncIsValid = true;
    expect(syncIsValid, isTrue, reason: 'the sync half must read the passing value');
    // ignore: avoid-duplicate-initializers, deliberately re-evaluates validate('x') after flipping syncIsValid back
    final whenSyncPasses = instance.combineWithAsyncResults(
      instance.validate('x'),
      asyncResults,
      asyncValidatedValue: 'x',
    );

    // assert
    expect(whileSyncFails.errors.map((e) => e.key), equals(['sync', 'async']));
    expect(whenSyncPasses.errors.map((e) => e.key), equals(['async']));
  });
}
