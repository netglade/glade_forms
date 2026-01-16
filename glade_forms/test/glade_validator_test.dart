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
}
