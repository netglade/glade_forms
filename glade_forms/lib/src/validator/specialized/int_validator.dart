// ignore_for_file: prefer-single-declaration-per-file

import 'package:glade_forms/src/src.dart';

typedef IntValidatorFactory = ValidatorInstance<int> Function(IntValidator validator);
typedef IntValidatorFactoryNullable = ValidatorInstance<int?> Function(IntValidatorNullable validator);

/// Validator for [int] values.
class IntValidator extends GladeValidator<int> {
  /// Compares given value with [min] and [max] values.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeErrorKeys.intCompareError].
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
            (value) => 'Value $value  (inclusiveInterval: $inclusiveInterval) is not in between $min and $max.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [min] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeErrorKeys.intCompareMinError].
  void isMin({
    required int min,
    bool isInclusive = true,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => isInclusive ? value >= min : value > min,
        devError: devError ?? (value) => 'Value $value is less than $min.',
        key: key ?? GladeErrorKeys.intCompareMinError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [max] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeErrorKeys.intCompareMaxError].
  void isMax({
    required int max,
    bool isInclusive = true,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => isInclusive ? value <= max : value < max,
        devError: devError ?? (value) => 'Value $value is bigger than $max.',
        key: key ?? GladeErrorKeys.intCompareMaxError,
        shouldValidate: shouldValidate,
      );

  /// Checks if the given value is positive.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeErrorKeys.intCompareIsPositiveError].
  void isPositive({
    bool includeZero = true,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      isMin(
        min: 0,
        isInclusive: includeZero,
        devError: devError,
        key: key ?? GladeErrorKeys.intCompareIsPositiveError,
        shouldValidate: shouldValidate,
      );

  /// Checks if the given value is negative.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeErrorKeys.intCompareIsNegativeError].
  void isNegative({
    bool includeZero = true,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      isMax(
        max: 0,
        isInclusive: includeZero,
        devError: devError,
        key: key ?? GladeErrorKeys.intCompareIsNegativeError,
        shouldValidate: shouldValidate,
      );
}

/// Nullable version of [IntValidator].
class IntValidatorNullable extends GladeValidator<int?> {
  /// Compares given value with [min] and [max] values.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeErrorKeys.intCompareError].
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
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeErrorKeys.intCompareMinError].
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
        key: key ?? GladeErrorKeys.intCompareMinError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [max] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeErrorKeys.intCompareMaxError].
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
        key: key ?? GladeErrorKeys.intCompareMaxError,
        shouldValidate: shouldValidate,
      );

  /// Checks if the given value is positive.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeErrorKeys.intCompareIsPositiveError].
  void isPositive({
    bool includeZero = true,
    OnValidateError<int?>? devError,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
  }) =>
      isMin(
        min: 0,
        isInclusive: includeZero,
        devError: devError,
        key: key ?? GladeErrorKeys.intCompareIsPositiveError,
        shouldValidate: shouldValidate,
      );

  /// Checks if the given value is negative.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeErrorKeys.intCompareIsNegativeError].
  void isNegative({
    bool includeZero = true,
    OnValidateError<int?>? devError,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
  }) =>
      isMax(
        max: 0,
        isInclusive: includeZero,
        devError: devError,
        key: key ?? GladeErrorKeys.intCompareIsNegativeError,
        shouldValidate: shouldValidate,
      );
}
