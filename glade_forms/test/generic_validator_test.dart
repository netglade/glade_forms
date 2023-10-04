// ignore_for_file: avoid-non-ascii-symbols

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  test('Empty validator', () {
    final validator = GenericValidator<String>().build()..bindInput(GladeInput.pure(''));

    expect(validator.validate('').isValid, isTrue);
    expect(validator.validate('abc').isValid, isTrue);
    expect(validator.validate('-451').isValid, isTrue);
    expect(validator.validate('ffoo  --- ~~#!%2Bar').isValid, isTrue);
  });

  test('Validator returns isValid for valid value', () {
    final validator = (GenericValidator<String?>()..notNull()).build()..bindInput(GladeInput.pure(''));

    const input = 'hello';

    final result = validator.validate(input);

    expect(result.isValid, isTrue);
  });

  test("Value can't be null", () {
    final validator = (GenericValidator<String?>()..notNull()).build()..bindInput(GladeInput.pure(''));
    final result = validator.validate(null);

    expect(result.isValid, isFalse);
    expect(result.errors.length, equals(1));
    expect(result.errors.firstOrNull, isA<ValueNullError<String?>>());
  });

  group('Satisfy predicate', () {
    test('Should succeed', () {
      final validator = (GenericValidator<int>()
            ..satisfy(
              (x, _, __) => x > 10,
              devError: (_, __) => 'Value must be greater than 10',
            ))
          .build()
        ..bindInput(GladeInput.pure(0));

      expect(validator.validate(20).isValid, isTrue);
    });

    test('Value not valid', () {
      const onErrorMessage = 'Value must be greater than 10';
      final validator = (GenericValidator<int>()..satisfy((x, _, __) => x > 10, devError: (_, __) => onErrorMessage))
          .build()
        ..bindInput(GladeInput.pure(0));

      final result = validator.validate(5);
      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(1));
      expect(
        result.errors.firstOrNull,
        isA<ValueSatisfyPredicateError<int>>().having(
          (x) => x.devError(null, null),
          'Error message',
          onErrorMessage,
        ),
      );
    });
  });

  group('Combined', () {
    test('notNull() and satisfy() - succeeds', () {
      final validator = (GenericValidator<String>()
            ..notNull()
            ..satisfy(
              (x, _, __) => x.length >= 5,
              devError: (_, __) => 'Length must be at least 5',
            ))
          .build()
        ..bindInput(GladeInput.pure(''));

      expect(validator.validate('Length input').isValid, isTrue);
    });

    test('notNull() and satisfy() - value is null', () {
      final validator = (GenericValidator<String?>()
            ..notNull()
            ..satisfy(
              (x, _, __) => x!.length >= 5,
              devError: (_, __) => 'Length must be at least 5',
            ))
          .build()
        ..bindInput(GladeInput.pure(''));

      final result = validator.validate(null);

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(1));
      expect(result.errors.firstOrNull, isA<ValueNullError<String?>>());
    });

    test('notNull() and satisfy() - value does not meet predicate', () {
      const onErrorMessage = 'Length must be at least 5';
      final validator = (GenericValidator<String?>()
            ..notNull()
            ..satisfy(
              (x, _, __) => x!.length >= 5,
              devError: (_, __) => onErrorMessage,
            ))
          .build()
        ..bindInput(GladeInput.pure(''));

      final result = validator.validate('a');

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(1));
      expect(
        result.errors.firstOrNull,
        // TODO(tests): does this even test anything correctly?
        isA<ValueSatisfyPredicateError<String?>>().having(
          (x) => x.devError(null, null),
          'Error message',
          onErrorMessage,
        ),
      );
    });

    test('Run all parts: notNull() and satisfy() - value is null', () {
      const onErrorMessage = 'Length must be at least 5';
      final validator = (GenericValidator<String?>()
            ..notNull()
            ..satisfy(
              (x, _, __) => (x?.length ?? 0) >= 5,
              devError: (_, __) => onErrorMessage,
            ))
          .build(stopOnFirstError: false)
        ..bindInput(GladeInput.pure(null));

      final result = validator.validate(null);

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(2));
      expect(result.errors.firstOrNull, isA<ValueNullError<String?>>());
      expect(
        result.errors.elementAtOrNull(1),
        // TODO(tests): does this even test anything correctly?
        isA<ValueSatisfyPredicateError<String?>>().having(
          (x) => x.devError(null, null),
          'Error message',
          onErrorMessage,
        ),
      );
    });
  });

  group('IsEmail', () {
    test('Succeeds', () {
      final validator = (StringValidator()..isEmail()).build()..bindInput(GladeInput.pure(''));

      final inputs = [
        'abc@gmail.com',
        'user@custom-domain.xz',
        'user12312dA@seznam.cz',
        'a-dsada3123@outlook.com',
        'penelope@email.org',
      ];

      for (final input in inputs) {
        expect(validator.validate(input).isValid, isTrue, reason: input);
      }
    });

    test('Value not valid', () {
      final validator = (StringValidator()..isEmail()).build()..bindInput(GladeInput.pure(''));

      final inputs = [
        'abc-gmail.com',
        'user__custom-domain.xz',
        '@seznam.cz',
        'a-dsada3123@',
        'penelope.email.org',
        'gargame.@@email.org',
        'joker@~~~@A~~.com-valid@seznam.com',
      ];

      for (final input in inputs) {
        expect(validator.validate(input).isValid, isFalse, reason: input);
      }
    });
  });

  group('Is URL', () {
    test('Succeeds - http(s) optional', () {
      final validator = (StringValidator()..isUrl()).build()..bindInput(GladeInput.pure(''));

      // Expected Url - Check with HTTP(S).
      final inputs = [
        'abc.domain.com',
        'abc.domain.com',
        'www.flutter.com',
        'http://flutter.com',
        'https://flutter.com',
        'https://sub.next.dot.com',
        'https://sub.next.dot.com',
        'http://dot.com',
      ];

      for (final input in inputs) {
        expect(validator.validate(input).isValid, isTrue, reason: input);
      }
    });

    test('Succeeds - http(s) mandatory', () {
      final validator = (StringValidator()..isUrl(requireHttpScheme: true)).build()..bindInput(GladeInput.pure(''));

      // Expected Url - Check with HTTP(S).
      final inputs = [
        'http://flutter.com',
        'https://flutter.com',
        'https://sub.next.dot.com',
        'https://sub.next.dot.com',
        'http://dot.com',
      ];

      for (final input in inputs) {
        expect(validator.validate(input).isValid, isTrue, reason: input);
      }
    });

    test('Value is not url', () {
      final validator = (StringValidator()..isUrl(requireHttpScheme: true)).build()..bindInput(GladeInput.pure(''));

      // Expected Url - Check with HTTP(S).
      final inputs = [
        'htttp://flutter.com',
        'htstps://flutter.com',
        'https:/sub.next.dot.com.com',
        '//sub.next.dot.com',
        'file://dot.com',
        'dasdsa',
        '',
        'x__`-`1-assad`',
        'asdas@email.com',
      ];

      for (final input in inputs) {
        expect(validator.validate(input).isValid, isFalse, reason: input);
      }
    });
  });

  group('OnTranslate', () {
    test('InputValidator returns valid translated error', () {
      const onErrorMessage = 'Value must be greater than 10';

      final input = GladeInput<int>.create(
        validator: (v) => (v
              ..satisfy(
                (x, _, __) => x > 10,
                devError: (_, __) => onErrorMessage,
                key: 'e1',
              ))
            .build(),
        value: 0,
        //translateError: (err, key, defMessage, {depedencies}) => key == 'e1' ? 'Hodnota není větší jak 10!' : defMessage,
        translateError: (error, key, devMessage, {required dependencies}) =>
            key == 'e1' ? 'Hodnota není větší jak 10!' : devMessage,
      );

      final result = input.asDirty(5);

      expect(result.translate(), equals('Hodnota není větší jak 10!'));
    });

    test('InputValidator returns default message', () {
      const onErrorMessage = 'Value must be greater than 10';

      final input = GladeInput<int>.create(
        validator: (v) => (v
              ..satisfy(
                (x, _, __) => x > 10,
                devError: (_, __) => onErrorMessage,
                key: 'e1',
              ))
            .build(),
        value: 0,
        translateError: (error, key, devMessage, {required dependencies}) =>
            key == 'e2' ? 'Hodnota není větší jak 10!' : devMessage,
      );

      final result = input.asDirty(5);

      expect(result.translate(), equals(onErrorMessage));
    });
  });
}