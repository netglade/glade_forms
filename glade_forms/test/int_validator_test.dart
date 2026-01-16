// ignore_for_file: avoid-unsafe-collection-methods

import 'package:glade_forms/src/validator/specialized/int_validator.dart';
import 'package:test/test.dart';

void main() {
  group('inBetween', () {
    test('success', () {
      // arrange
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      // act
      final result = validator.validate(6);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('success inclusive max', () {
      // arrange
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      // act
      final result = validator.validate(10);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('success inclusive min', () {
      // arrange
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('fails non-inclusive max', () {
      // arrange
      final validator = (IntValidator()..isBetween(min: 5, max: 10, inclusiveInterval: false)).build();

      // act
      final result = validator.validate(10);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
    });

    test('fails non-inclusive min', () {
      // arrange
      final validator = (IntValidator()..isBetween(min: 5, max: 10, inclusiveInterval: false)).build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
    });

    test('fails', () {
      // arrange
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      // act
      final result = validator.validate(1);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
    });
  });

  group('isMax', () {
    test('success', () {
      // arrange
      final validator = (IntValidator()..isMax(max: 10)).build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('fails', () {
      // arrange
      final validator = (IntValidator()..isMax(max: 10)).build();

      // act
      final result = validator.validate(25);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
    });
  });

  group('isMin', () {
    test('success', () {
      // arrange
      final validator = (IntValidator()..isMin(min: 1)).build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
    });

    test('fails', () {
      // arrange
      final validator = (IntValidator()..isMin(min: 10)).build();

      // act
      final result = validator.validate(5);

      // assert
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
    });
  });
}
