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
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid between $start - $end when testing inclusive and with included time',
        () {
          final validator = (DateTimeValidator()
                // ignore: avoid_redundant_argument_values, be explicit in tests.
                ..isBetween(start: start, end: end, includeTime: true, inclusiveInterval: true))
              .build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
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
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid between $start - $end when testing inclusive and but without included time',
        () {
          final validator = (DateTimeValidator()
                ..isBetween(
                  start: start,
                  end: end,
                  // ignore: avoid_redundant_argument_values, be explcit in tests.,
                  includeTime: false,
                ))
              .build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
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
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid between $start - $end when testing without inclusive and without included time',
        () {
          final validator = (DateTimeValidator()
                // ignore: avoid_redundant_argument_values, be explicit in tests.
                ..isBetween(
                  start: start,
                  end: end,
                  includeTime: false,
                  inclusiveInterval: false,
                ))
              .build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
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
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid between $start - $end when testing without inclusive but with included time',
        () {
          final validator = (DateTimeValidator()
                ..isBetween(
                  start: start,
                  end: end,
                  inclusiveInterval: false,
                  // ignore: avoid_redundant_argument_values, be explicit
                  includeTime: true,
                ))
              .build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }
  });

  group('isAfter', () {
    for (final testCase in [
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 21),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 3, 15, 15, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2024, 12, 31, 23, 59, 59),
        isValid: false,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid after $start when testing inclusive and with included time',
        () {
          final validator = (DateTimeValidator()..isAfter(start: start)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }

    for (final testCase in [
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 21),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: false,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 3, 15, 15, 20),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2024, 12, 31, 23, 59, 59),
        isValid: false,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid after $start when testing exclusive and with included time',
        () {
          final validator = (DateTimeValidator()..isAfter(start: start, inclusiveInterval: false)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }

    for (final testCase in [
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2025, 1, 3),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2025, 1, 2),
        isValid: true,
      ),
      (start: DateTime(2025, 1, 2), test: DateTime(2025), isValid: false),
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2026, 1, 2),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2024, 12, 31),
        isValid: false,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid after $start when testing inclusive and without included time',
        () {
          final validator = (DateTimeValidator()..isAfter(start: start, includeTime: false)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }

    for (final testCase in [
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2025, 1, 3),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2025, 1, 2),
        isValid: false,
      ),
      (start: DateTime(2025, 1, 2), test: DateTime(2025), isValid: false),
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2026, 1, 2),
        isValid: true,
      ),
      (
        start: DateTime(2025, 1, 2),
        test: DateTime(2024, 12, 31),
        isValid: false,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final start = data.start;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid after $start when testing exclusive and without included time',
        () {
          final validator =
              (DateTimeValidator()..isAfter(start: start, includeTime: false, inclusiveInterval: false)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }
  });

  group('isBefore', () {
    for (final testCase in [
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: true,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: true,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 21),
        isValid: false,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 1, 15, 15, 20),
        isValid: true,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 3, 15, 15, 20),
        isValid: false,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid before $end when testing inclusive and with included time',
        () {
          final validator = (DateTimeValidator()..isBefore(end: end)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }

    for (final testCase in [
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 19),
        isValid: true,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 20),
        isValid: false,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 2, 15, 15, 21),
        isValid: false,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 1, 15, 15, 20),
        isValid: true,
      ),
      (
        end: DateTime(2025, 1, 2, 15, 15, 20),
        test: DateTime(2025, 1, 3, 15, 15, 20),
        isValid: false,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid before $end when testing exclusive and with included time',
        () {
          final validator = (DateTimeValidator()..isBefore(end: end, inclusiveInterval: false)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }

    for (final testCase in [
      (end: DateTime(2025, 1, 2), test: DateTime(2025), isValid: true),
      (end: DateTime(2025, 1, 2), test: DateTime(2025, 1, 2), isValid: true),
      (end: DateTime(2025, 1, 2), test: DateTime(2025), isValid: true),
      (
        end: DateTime(2025, 1, 2),
        test: DateTime(2026, 1, 2),
        isValid: false,
      ),
      (
        end: DateTime(2025, 1, 2),
        test: DateTime(2024, 12, 31),
        isValid: true,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid before $end when testing inclusive and without included time',
        () {
          final validator = (DateTimeValidator()..isBefore(end: end, includeTime: false)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }

    for (final testCase in [
      (end: DateTime(2025, 1, 2), test: DateTime(2025), isValid: true),
      (
        end: DateTime(2025, 1, 2),
        test: DateTime(2025, 1, 2),
        isValid: false,
      ),
      (end: DateTime(2025, 1, 2), test: DateTime(2025), isValid: true),
      (
        end: DateTime(2025, 1, 2),
        test: DateTime(2026, 1, 2),
        isValid: false,
      ),
      (
        end: DateTime(2025, 1, 2),
        test: DateTime(2024, 12, 31),
        isValid: true,
      ),
    ].indexed) {
      final index = testCase.$1;
      final data = testCase.$2;
      final end = data.end;
      final testDate = data.test;
      final isValid = data.isValid;

      test(
        '($index): $testDate should be valid before $end when testing exclusive and without included time',
        () {
          final validator =
              (DateTimeValidator()..isBefore(end: end, includeTime: false, inclusiveInterval: false)).build();

          final result = validator.validate(testDate);

          expect(result.isValid, equals(isValid));
          expect(result.isInvalid, equals(!isValid));
        },
      );
    }
  });
}
