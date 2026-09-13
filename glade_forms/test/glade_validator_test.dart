// ignore_for_file: avoid-unsafe-collection-methods

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  group('notNull', () {
    test('success', () {
      // arrange
      final validator = (GladeValidator<int?>()..notNull()).build();

      // act
      final result = validator.validate(1);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('fails', () {
      // arrange
      final validator = (GladeValidator<int?>()..notNull(key: 'not-null')).build();

      // act
      final result = validator.validate(null);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
      expect(result.errors, isNotEmpty);
      expect(
        result.errors.first,
        isA<ValueNullError<int?>>().having((p0) => p0.key, 'Has proper key', equals('not-null')),
      );
    });
  });

  group('satisfy', () {
    test('success', () {
      // arrange
      final validator = (GladeValidator<int>()..satisfy((v) => v > 5)).build();

      // act
      final result = validator.validate(6);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('fails', () {
      // arrange
      final validator = (GladeValidator<int>()..satisfy((v) => v > 5, key: 'custom-key')).build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
      expect(result.errors, isNotEmpty);
      expect(
        result.errors.first,
        isA<ValueSatisfyPredicateError<int>>().having((x) => x.key, 'Has proper key', equals('custom-key')),
      );
    });
  });

  group('custom', () {
    test('success', () {
      // arrange
      final validator =
          (GladeValidator<int>()..custom(
                (v, key) => v > 5
                    ? null
                    : ValueError(value: v, devMessage: (value) => 'Value has to be greater than 5', key: key),
                key: 'custom-key',
              ))
              .build();

      // act
      final result = validator.validate(6);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('fails', () {
      // arrange
      final validator =
          (GladeValidator<int>()..custom(
                (v, key) => v > 5
                    ? null
                    : ValueError(value: v, devMessage: (value) => 'Value has to be greater than 5', key: key),
                key: 'custom-key',
              ))
              .build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
      expect(result.errors, isNotEmpty);
      expect(
        result.errors.first,
        isA<ValueError<int>>().having((x) => x.key, 'Has proper key', equals('custom-key')),
      );
    });
  });
  group('async parts declaration', () {
    test('customAsync and satisfyAsync are collected into asyncParts', () {
      // arrange
      final validator = GladeValidator<String>()
        ..notNull()
        ..customAsync((value, key) async => null, key: 'custom')
        ..satisfyAsync((value) async => true, key: 'satisfy', devMessage: (_) => 'nope');

      // act
      final instance = validator.build();

      // assert
      expect(validator.parts, hasLength(1));
      expect(validator.asyncParts, hasLength(2));
      expect(instance.hasAsyncParts, isTrue);
      expect(instance.hasDeclaredValidator('custom'), isTrue);
      expect(instance.hasDeclaredValidator('satisfy'), isTrue);
      expect(instance.tryFindAsyncValidatorPart('satisfy'), isA<SatisfyAsyncPredicatePart<String>>());
      expect(instance.tryFindAsyncValidatorPart('missing'), isNull);
      expect(() => instance.findAsyncValidatorPart('missing'), throwsArgumentError);
    });

    test('build stores debounce, default is 300ms', () {
      // arrange
      const defaultDebounce = Duration(milliseconds: 300);

      // act
      final defaultInstance = GladeValidator<int>().build();
      final customInstance = GladeValidator<int>().build(asyncDebounce: .zero);

      // assert
      expect(defaultInstance.asyncDebounce, equals(defaultDebounce));
      expect(customInstance.asyncDebounce, equals(Duration.zero));
      expect(defaultInstance.hasAsyncParts, isFalse);
    });

    test('clear removes async parts as well', () {
      // arrange
      final validator = GladeValidator<int>()
        ..notNull()
        ..customAsync((value, key) async => null);

      // act
      // ignore: cascade_invocations, keeps arrange and act sections separated
      validator.clear();

      // assert
      expect(validator.parts, isEmpty);
      expect(validator.asyncParts, isEmpty);
    });

    test('async part options are stored', () {
      // arrange
      GladeValidatorResult<int>? onError(int _, Object _, StackTrace _, Object? _) => null;
      final validator = GladeValidator<int>()
        ..customAsync(
          (value, key) async => null,
          key: 'k',
          severity: .warning,
          runOnlyWhenSyncValid: false,
          onError: onError,
        );

      // act
      final part = validator.asyncParts.single;

      // assert
      expect(part.key, equals('k'));
      expect(part.serverity, equals(ValidationSeverity.warning));
      expect(part.runOnlyWhenSyncValid, isFalse);
      expect(part.onError, same(onError));
    });
  });
}
