// ignore_for_file: avoid-positional-record-field-access, avoid_redundant_argument_values, avoid-passing-default-values, avoid_redundant_argument_values

import 'package:glade_forms/src/validator/specialized/date_time_validator.dart';
import 'package:test/test.dart';

void main() {
  group('inBetween', () {
    for (final testCase in [
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 16, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 24),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 25, 18, 20, 24),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 23),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 25),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 2),
        isValid: false,
      ),
    ].indexed) {
      test(
        '(${testCase.$1}): ${testCase.$2.test} should be valid between ${testCase.$2.start} - ${testCase.$2.end} when testing inclusive and with included time',
        () {
          final validator = (DateTimeValidator()
                // ignore: avoid_redundant_argument_values,  be explcit in tests.
                ..isBetween(start: testCase.$2.start, end: testCase.$2.end, includeTime: true, inclusiveInterval: true))
              .build();

          final result = validator.validate(testCase.$2.test);

          expect(result.isValid, equals(testCase.$2.isValid));
          expect(result.isInvalid, equals(!testCase.$2.isValid));
        },
      );
    }

    for (final testCase in [
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 16, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 24),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 25, 18, 20, 24),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 23),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 25),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 2),
        isValid: false,
      ),
    ].indexed) {
      test(
        '(${testCase.$1}): ${testCase.$2.test} should be valid between ${testCase.$2.start} - ${testCase.$2.end} when testing inclusive and but without included time',
        () {
          final validator = (DateTimeValidator()
                // ignore: avoid_redundant_argument_values, be explcit in tests.,
                ..isBetween(
                  start: testCase.$2.start,
                  end: testCase.$2.end,
                  includeTime: false,
                ))
              .build();

          final result = validator.validate(testCase.$2.test);

          expect(result.isValid, equals(testCase.$2.isValid));
          expect(result.isInvalid, equals(!testCase.$2.isValid));
        },
      );
    }

    for (final testCase in [
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 16, 20),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 24),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 25, 18, 20, 24),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 23),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 25),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 2),
        isValid: false,
      ),
    ].indexed) {
      test(
        '(${testCase.$1}): ${testCase.$2.test} should be valid between ${testCase.$2.start} - ${testCase.$2.end} when testing without inclusive and without included time',
        () {
          final validator = (DateTimeValidator()
                // ignore: avoid_redundant_argument_values,  be explcit in tests.,
                ..isBetween(
                  start: testCase.$2.start,
                  end: testCase.$2.end,
                  includeTime: false,
                  inclusiveInterval: false,
                ))
              .build();

          final result = validator.validate(testCase.$2.test);

          expect(result.isValid, equals(testCase.$2.isValid));
          expect(result.isInvalid, equals(!testCase.$2.isValid));
        },
      );
    }

    for (final testCase in [
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 16, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 24),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 25, 18, 20, 24),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 23),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 1, 31, 18, 20, 25),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        end: DateTime(2025, 1, 31, 18, 20, 24),
        test: DateTime(2025, 2),
        isValid: false,
      ),
    ].indexed) {
      test(
        '(${testCase.$1}): ${testCase.$2.test} should be valid between ${testCase.$2.start} - ${testCase.$2.end} when testing without inclusive but with included time',
        () {
          final validator = (DateTimeValidator()
                ..isBetween(
                  start: testCase.$2.start,
                  end: testCase.$2.end,
                  inclusiveInterval: false,
                  // ignore: avoid_redundant_argument_values, be explicti
                  includeTime: true,
                ))
              .build();

          final result = validator.validate(testCase.$2.test);

          expect(result.isValid, equals(testCase.$2.isValid));
          expect(result.isInvalid, equals(!testCase.$2.isValid));
        },
      );
    }
  });
}
