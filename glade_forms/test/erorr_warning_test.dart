import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  test('Warning populates proper result value', () {
    // arrange
    final input = GladeIntInput(
      validator: (v) =>
          (v
                ..isBetween(min: 25, max: 50, severity: .warning, key: 'between')
                ..isMin(min: 10, key: 'min')
                ..isMax(max: 100, key: 'max'))
              .build(),
      value: 15,
    );

    // act
    final result = input.validate();

    // assert
    expect(result.errors, isEmpty, reason: 'Errors should be empty');
    expect(result.warnings, isNotEmpty, reason: 'Warnings should not be empty');
    expect(result.isValid, isTrue, reason: 'Input should be valid');
    expect(result.isValidWithoutWarnings, isFalse, reason: 'Input should not be valid without warnings');

    expect(result.warnings, hasLength(1), reason: 'Input contains only one warning');
    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.warnings.first.key, equals('between'), reason: 'Warning has key between');
  });

  test('Warning does not stop validation by default', () {
    // arrange
    final input = GladeIntInput(
      validator: (v) =>
          (v
                ..isBetween(min: 25, max: 50, severity: .warning, key: 'between')
                ..isMin(min: 20, key: 'min') // * triggers
                ..isMax(max: 100, key: 'max'))
              .build(),
      value: 15,
    );

    // act
    final result = input.validate();

    // assert
    expect(result.errors, isNotEmpty, reason: 'Errors should not be empty');
    expect(result.warnings, isNotEmpty, reason: 'Warnings should not be empty');
    expect(result.isValid, isFalse, reason: 'Input should  not be valid');
    expect(result.isValidWithoutWarnings, isFalse, reason: 'Input should not be valid without warnings');

    expect(result.errors, hasLength(1), reason: 'Input contains only one error');
    expect(result.warnings, hasLength(1), reason: 'Input contains only one warning');

    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.errors.first.key, equals('min'), reason: 'Error has key min');
    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.warnings.first.key, equals('between'), reason: 'Warning has key between');
  });

  test('Warning does not stop validation even when stopOnFirstError is false', () {
    // arrange
    final input = GladeIntInput(
      validator: (v) =>
          (v
                ..isBetween(min: 25, max: 50, severity: .warning, key: 'between')
                ..isMin(min: 20, key: 'min') // * triggers
                ..isMax(max: 10, key: 'max')) // * also triggers, although in reality does not make sense
              .build(stopOnFirstError: false),
      value: 15,
    );

    // act
    final result = input.validate();

    // assert
    expect(result.errors, isNotEmpty, reason: 'Errors should not be empty');
    expect(result.warnings, isNotEmpty, reason: 'Warnings should not be empty');
    expect(result.isValid, isFalse, reason: 'Input should  not be valid');
    expect(result.isValidWithoutWarnings, isFalse, reason: 'Input should not be valid without warnings');

    expect(result.errors, hasLength(2), reason: 'Input contains two errors');
    expect(result.warnings, hasLength(1), reason: 'Input contains only one warning');

    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.errors.first.key, equals('min'), reason: 'Error has key min');
    // ignore: avoid-unsafe-collection-methods, safe to call
    expect(result.errors[1].key, equals('max'), reason: 'Error has key max');
    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.warnings.first.key, equals('between'), reason: 'Warning has key between');
  });

  test('Warning stops validation when stopOnFirstErrorOrWarning is true', () {
    // arrange
    final input = GladeIntInput(
      validator: (v) =>
          (v
                ..isBetween(min: 25, max: 50, severity: .warning, key: 'between')
                ..isMin(min: 20, key: 'min') // * triggers
                ..isMax(max: 10, key: 'max')) // * also triggers, although in reality does not make sense
              .build(stopOnFirstError: false, stopOnFirstErrorOrWarning: true),
      value: 15,
    );

    // act
    final result = input.validate();

    // assert
    expect(result.errors, isEmpty, reason: 'Errors should be empty');
    expect(result.warnings, isNotEmpty, reason: 'Warnings should not be empty');
    expect(result.isValid, isTrue, reason: 'Input should  not be valid');
    expect(result.isValidWithoutWarnings, isFalse, reason: 'Input should not be valid without warnings');

    expect(result.errors, hasLength(0), reason: 'Input does not contains two errors');
    expect(result.warnings, hasLength(1), reason: 'Input contains only one warning');
    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.warnings.first.key, equals('between'), reason: 'Warning has key between');
  });

  test('By default multiple warnigns are collected and do not stop validation', () {
    // arrange
    final input = GladeIntInput(
      validator: (v) =>
          (v
                ..isBetween(min: 25, max: 50, severity: .warning, key: 'between')
                ..isMin(min: 10, key: 'min')
                ..isBetween(min: 23, max: 24, severity: .warning, key: 'between2')
                ..isMax(max: 18, key: 'max')) // * triggers, although in reality does not make sense
              .build(),
      value: 20,
    );

    // act
    final result = input.validate();

    // assert
    expect(result.errors, isNotEmpty, reason: 'Errors should not be empty');
    expect(result.warnings, isNotEmpty, reason: 'Warnings should not be empty');
    expect(result.isValid, isFalse, reason: 'Input should  not be valid');
    expect(result.isValidWithoutWarnings, isFalse, reason: 'Input should not be valid without warnings');

    expect(result.errors, hasLength(1), reason: 'Input contains error');
    expect(result.warnings, hasLength(2), reason: 'Input contains only one warning');

    // ignore: avoid-unsafe-collection-methods, safe to call
    expect(result.errors.first.key, equals('max'), reason: 'Error has key max');
    // ignore: avoid-unsafe-collection-methods, safe to call.
    expect(result.warnings.first.key, equals('between'), reason: 'Warning has key between');
    // ignore: avoid-unsafe-collection-methods, safe to call
    expect(result.warnings[1].key, equals('between2'), reason: 'Warning has key between2');
  });
}
