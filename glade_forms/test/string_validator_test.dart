// ignore_for_file: avoid-positional-record-field-access, avoid-unsafe-collection-methods

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  group('notEmpty', () {
    test('When value is empty, notEmpty fails', () {
      // arrange
      final validator = (StringValidator()..notEmpty()).build();

      // act
      final result = validator.validate('');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringEmpty));
    });

    test('When value is not empty or null, notEmpty pass', () {
      // arrange
      final validator = (StringValidator()..notEmpty()).build();

      // act
      final result = validator.validate('test x');

      // assert
      expect(result.isValid, isTrue);
    });
  });

  group('isEmail', () {
    test('When value is empty, isEmail() fails', () {
      // arrange
      final validator = (StringValidator()..isEmail()).build();

      // act
      final result = validator.validate('');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringNotEmail));
    });

    for (final testCase in [
      ('test.user@gmail.com', true),
      ('test124@x.com', true),
      ('a.213.cz@gmail.com', true),
      ('test.user@gmail', false),
      ('@x.com', false),
      ('a.213.czgmail.com', false),
    ]) {
      test('When email is ${testCase.$1}, isEmail() ${testCase.$2 ? 'pass' : 'fails'}', () {
        // arrange
        final validator = (StringValidator()..isEmail()).build();

        // act
        final result = validator.validate(testCase.$1);

        // assert
        expect(result.isValid, equals(testCase.$2));
      });
    }
  });

  group('isUrl', () {
    test('When value is empty, isUrl() fails', () {
      // arrange
      final validator = (StringValidator()..isUrl()).build();

      // act
      final result = validator.validate('');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringNotUrl));
    });

    // URL, requires HTTP, expected result
    for (final testCase in [
      ('https://x.test.com', true, true),
      ('http://test.com/test', true, true),
      ('file://sdsasa.asdas.com', false, false),
      ('file://sdsasa.asdas.com', true, false),
      ('test.com/asdsa?qqe=sa44%20sda', false, true),
      ('www.domain.com/asdsa?qqe=sa44%20sda', false, true),
      ('@x.sada/https://file:sadad', true, false),
      ('sadscom:/192.168.1.1', false, false),
      ('noturl', false, false),
      ('noturl', false, false),
    ]) {
      test('When URL is ${testCase.$1}, isUrl(http: ${testCase.$2}) ${testCase.$3 ? 'pass' : 'fails'}', () {
        // arrange
        final validator = (StringValidator()..isUrl(requiresScheme: testCase.$2)).build();

        // act
        final result = validator.validate(testCase.$1);

        // assert
        expect(result.isValid, equals(testCase.$3));
      });
    }
  });

  group('exactLength()', () {
    test('exactLength() pass', () {
      // arrange
      final validator = (StringValidator()..exactLength(length: 4)).build();

      // act
      final result = validator.validate('abcd');

      // assert
      expect(result.isValid, isTrue);
    });

    test('exactLength(), empty value fails', () {
      // arrange
      final validator = (StringValidator()..exactLength(length: 4)).build();

      // act
      final result = validator.validate('');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringExactLength));
    });

    test('exactLength() fails', () {
      // arrange
      final validator = (StringValidator()..exactLength(length: 4)).build();

      // act
      final result = validator.validate('asdasd');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringExactLength));
    });
  });

  group('maxLength()', () {
    test('maxLength() pass', () {
      // arrange
      final validator = (StringValidator()..maxLength(length: 4)).build();

      // act
      final result = validator.validate('134');

      // assert
      expect(result.isValid, isTrue);
    });

    test('maxLength(), empty value pass', () {
      // arrange
      final validator = (StringValidator()..maxLength(length: 4)).build();

      // act
      final result = validator.validate('');

      // assert
      expect(result.isValid, isTrue);
    });

    test('maxLength() fails', () {
      // arrange
      final validator = (StringValidator()..maxLength(length: 4)).build();

      // act
      final result = validator.validate('asdasd');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringMaxLength));
    });
  });

  group('minLength()', () {
    test('minLength() pass', () {
      // arrange
      final validator = (StringValidator()..minLength(length: 4)).build();

      // act
      final result = validator.validate('abcd');

      // assert
      expect(result.isValid, isTrue);
    });

    test('minLength(), empty value fails', () {
      // arrange
      final validator = (StringValidator()..minLength(length: 4)).build();

      // act
      final result = validator.validate('');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringMinLength));
    });

    test('minLength() fails', () {
      // arrange
      final validator = (StringValidator()..minLength(length: 4)).build();

      // act
      final result = validator.validate('a');

      // assert
      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeValidationsKeys.stringMinLength));
    });
  });

  group('conditional validation', () {
    test('no validator is skipped', () {
      // arrange
      final validator =
          (StringValidator()
                ..minLength(length: 2)
                ..maxLength(length: 6))
              .build();

      // act
      final result = validator.validate('a');

      // assert
      expect(result.isValid, isFalse);
      expect(
        result.errors.first,
        isA<ValueSatisfyPredicateError<String>>().having(
          (x) => x.key,
          'Has proper key',
          equals(GladeValidationsKeys.stringMinLength),
        ),
      );
    });

    test('Min length is skipped', () {
      // arrange
      final validator =
          (StringValidator()
                ..minLength(length: 2, shouldValidate: (_) => false)
                ..maxLength(length: 6))
              .build();

      // act
      final result = validator.validate('This string is too long');

      // assert
      expect(result.isValid, isFalse);
      expect(
        result.errors.first,
        isA<ValueSatisfyPredicateError<String>>().having(
          (x) => x.key,
          'Has proper key',
          equals(GladeValidationsKeys.stringMaxLength),
        ),
      );
    });

    test('Max length is skipped', () {
      // arrange
      final validator =
          (StringValidator()
                ..minLength(length: 2)
                ..maxLength(length: 6, shouldValidate: (_) => false))
              .build();

      // act
      final result = validator.validate('This string is too long, but it will pass');

      // assert
      expect(result.isValid, isTrue);
    });
  });
}
