// ignore_for_file: prefer-single-declaration-per-file

import 'package:glade_forms/src/src.dart';

typedef IntValidatorFactory = ValidatorInstance<int> Function(IntValidator validator);
typedef IntValidatorFactoryNullable = ValidatorInstance<int> Function(IntValidatorNullable validator);

class IntValidator extends GladeValidator<int> {
  /// Compares given value with [min] and [max] values. With [inclusiveInterval] set to true(default), the comparison is inclusive.
  void isBetween({
    required int min,
    required int max,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
    bool inclusiveInterval = true,
  }) =>
      satisfy(
        (value) => inclusiveInterval ? value >= min && value <= max : value > min && value < max,
        devError: devError ??
            (value) =>
                'Value ${value ?? 'NULL'} (inclusiveInterval: $inclusiveInterval) is not in between $min and $max.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [min] value.
  void isMin({
    required int min,
    bool isInclusive = true,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => isInclusive ? value >= min : value > min,
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} is less than $min.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [max] value.
  void isMax({
    required int max,
    bool isInclusive = true,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => isInclusive ? value <= max : value < max,
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} is bigger than $max.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );
}

class IntValidatorNullable extends GladeValidator<int?> {
  /// Compares given value with [min] and [max] values. With [inclusiveInterval] set to true(default), the comparison is inclusive.
  void isBetween({
    required int min,
    required int max,
    OnValidateError<int?>? devError,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
    bool inclusiveInterval = true,
  }) =>
      satisfy(
        (value) {
          if (value == null) return false;

          return inclusiveInterval ? value >= min && value <= max : value > min && value < max;
        },
        devError: devError ??
            (value) =>
                'Value ${value ?? 'NULL'} (inclusiveInterval: $inclusiveInterval) is not in between $min and $max.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [min] value.
  void isMin({
    required int min,
    bool isInclusive = true,
    OnValidateError<int?>? devError,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
  }) =>
      satisfy(
        (value) {
          if (value == null) return false;

          return isInclusive ? value >= min : value > min;
        },
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} is less than $min.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [max] value.
  void isMax({
    required int max,
    bool isInclusive = true,
    OnValidateError<int?>? devError,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
  }) =>
      satisfy(
        (value) {
          if (value == null) return false;

          return isInclusive ? value <= max : value < max;
        },
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} is bigger than $max.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );
}