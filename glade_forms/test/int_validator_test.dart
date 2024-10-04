// ignore_for_file: avoid-unsafe-collection-methods

import 'package:glade_forms/src/validator/int_validator.dart';
import 'package:test/test.dart';

void main() {
  group('inBetween', () {
    test('success', () {
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      final result = validator.validate(6);

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
    });

    test('success inclusive max', () {
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      final result = validator.validate(10);

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
    });

    test('success inclusive min', () {
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      final result = validator.validate(5);

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
    });

    test('fails non-inclusive max', () {
      final validator = (IntValidator()..isBetween(min: 5, max: 10, inclusiveInterval: false)).build();

      final result = validator.validate(10);

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
    });

    test('fails non-inclusive min', () {
      final validator = (IntValidator()..isBetween(min: 5, max: 10, inclusiveInterval: false)).build();

      final result = validator.validate(5);

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
    });

    test('fails', () {
      final validator = (IntValidator()..isBetween(min: 5, max: 10)).build();

      final result = validator.validate(1);

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
    });
  });

  group('isMax', () {
    test('success', () {
      final validator = (IntValidator()..isMax(max: 10)).build();

      final result = validator.validate(5);

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
    });

    test('fails', () {
      final validator = (IntValidator()..isMax(max: 10)).build();

      final result = validator.validate(25);

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
    });
  });

  group('isMin', () {
    test('success', () {
      final validator = (IntValidator()..isMin(min: 1)).build();

      final result = validator.validate(5);

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
    });

    test('fails', () {
      final validator = (IntValidator()..isMin(min: 10)).build();

      final result = validator.validate(5);

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
    });
  });
}
