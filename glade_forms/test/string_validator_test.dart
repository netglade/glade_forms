// ignore_for_file: avoid-positional-record-field-access, avoid-unsafe-collection-methods

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  group('notEmpty', () {
    test('When value is empty, notEmpty fails', () {
      final validator = (StringValidator()..notEmpty()).build();

      final result = validator.validate('');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringEmpty));
    });

    test('When value is not empty or null, notEmpty pass', () {
      final validator = (StringValidator()..notEmpty()).build();

      final result = validator.validate('test x');

      expect(result.isValid, isTrue);
    });
  });

  group('isEmail', () {
    test('When value is empty, isEmail() fails', () {
      final validator = (StringValidator()..isEmail()).build();

      final result = validator.validate('');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringNotEmail));
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
        final validator = (StringValidator()..isEmail()).build();

        final result = validator.validate(testCase.$1);

        expect(result.isValid, equals(testCase.$2));
      });
    }
  });

  group('isUrl', () {
    test('When value is empty, isUrl() fails', () {
      final validator = (StringValidator()..isUrl()).build();

      final result = validator.validate('');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringNotUrl));
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
        final validator = (StringValidator()..isUrl(requiresScheme: testCase.$2)).build();

        final result = validator.validate(testCase.$1);

        expect(result.isValid, equals(testCase.$3));
      });
    }
  });

  group('exactLength()', () {
    test('exactLength() pass', () {
      final validator = (StringValidator()..exactLength(length: 4)).build();

      final result = validator.validate('abcd');

      expect(result.isValid, isTrue);
    });

    test('exactLength(), empty value fails', () {
      final validator = (StringValidator()..exactLength(length: 4)).build();

      final result = validator.validate('');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringExactLength));
    });

    test('exactLength() fails', () {
      final validator = (StringValidator()..exactLength(length: 4)).build();

      final result = validator.validate('asdasd');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringExactLength));
    });
  });

  group('maxLength()', () {
    test('maxLength() pass', () {
      final validator = (StringValidator()..maxLength(length: 4)).build();

      final result = validator.validate('134');

      expect(result.isValid, isTrue);
    });

    test('maxLength(), empty value pass', () {
      final validator = (StringValidator()..maxLength(length: 4)).build();

      final result = validator.validate('');

      expect(result.isValid, isTrue);
    });

    test('maxLength() fails', () {
      final validator = (StringValidator()..maxLength(length: 4)).build();

      final result = validator.validate('asdasd');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringMaxLength));
    });
  });

  group('minLength()', () {
    test('minLength() pass', () {
      final validator = (StringValidator()..minLength(length: 4)).build();

      final result = validator.validate('abcd');

      expect(result.isValid, isTrue);
    });

    test('minLength(), empty value fails', () {
      final validator = (StringValidator()..minLength(length: 4)).build();

      final result = validator.validate('');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringMinLength));
    });

    test('minLength() fails', () {
      final validator = (StringValidator()..minLength(length: 4)).build();

      final result = validator.validate('a');

      expect(result.isValid, isFalse);
      expect(result.errors.firstOrNull?.key, equals(GladeErrorKeys.stringMinLength));
    });
  });

  group('conditional validation', () {
    test('no validator is skipped', () {
      final validator = (StringValidator()
            ..minLength(length: 2)
            ..maxLength(length: 6))
          .build();

      final result = validator.validate('a');

      expect(result.isValid, isFalse);
      expect(
        result.errors.first,
        isA<ValueSatisfyPredicateError<String>>()
            .having((x) => x.key, 'Has proper key', equals(GladeErrorKeys.stringMinLength)),
      );
    });

    test('Min length is skipped', () {
      final validator = (StringValidator()
            ..minLength(length: 2, shouldValidate: (_) => false)
            ..maxLength(length: 6))
          .build();

      final result = validator.validate('This string is too long');

      expect(result.isValid, isFalse);
      expect(
        result.errors.first,
        isA<ValueSatisfyPredicateError<String>>()
            .having((x) => x.key, 'Has proper key', equals(GladeErrorKeys.stringMaxLength)),
      );
    });

    test('Max length is skipped', () {
      final validator = (StringValidator()
            ..minLength(length: 2)
            ..maxLength(length: 6, shouldValidate: (_) => false))
          .build();

      final result = validator.validate('This string is too long, but it will pass');

      expect(result.isValid, isTrue);
    });
  });
}
