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

  test('sync error with stopOnFirstError skips all async parts', () async {
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
    expect(called, isFalse);
    expect(result.errors.single.key, equals('sync'));
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isFalse);
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
}
