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
  /// Default [key] is [ GladeValidationsKeys.intCompareError].
  void isBetween({
    required int min,
    required int max,
    OnValidate<int>? devMessage,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
    bool inclusiveInterval = true,
    ValidationSeverity severity = .error,
  }) => satisfy(
    (value) => inclusiveInterval ? value >= min && value <= max : value > min && value < max,
    devMessage:
        devMessage ??
        (value) => 'Value $value  (inclusiveInterval: $inclusiveInterval) is not in between $min and $max.',
    key: key ?? GladeValidationsKeys.intCompareError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Compares given value with [min] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeValidationsKeys.intCompareMinError].
  void isMin({
    required int min,
    bool isInclusive = true,
    OnValidate<int>? devMessage,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => satisfy(
    (value) => isInclusive ? value >= min : value > min,
    devMessage: devMessage ?? (value) => 'Value $value is less than $min.',
    key: key ?? GladeValidationsKeys.intCompareMinError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Compares given value with [max] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeValidationsKeys.intCompareMaxError].
  void isMax({
    required int max,
    bool isInclusive = true,
    OnValidate<int>? devMessage,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => satisfy(
    (value) => isInclusive ? value <= max : value < max,
    devMessage: devMessage ?? (value) => 'Value $value is bigger than $max.',
    key: key ?? GladeValidationsKeys.intCompareMaxError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Checks if the given value is positive.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeValidationsKeys.intCompareIsPositiveError].
  void isPositive({
    bool includeZero = true,
    OnValidate<int>? devMessage,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => isMin(
    min: 0,
    isInclusive: includeZero,
    devMessage: devMessage,
    key: key ?? GladeValidationsKeys.intCompareIsPositiveError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Checks if the given value is negative.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeValidationsKeys.intCompareIsNegativeError].
  void isNegative({
    bool includeZero = true,
    OnValidate<int>? devMessage,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => isMax(
    max: 0,
    isInclusive: includeZero,
    devMessage: devMessage,
    key: key ?? GladeValidationsKeys.intCompareIsNegativeError,
    shouldValidate: shouldValidate,
    severity: severity,
  );
}

/// Nullable version of [IntValidator].
class IntValidatorNullable extends GladeValidator<int?> {
  /// Compares given value with [min] and [max] values.
  ///
  /// With [inclusiveInterval] set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeValidationsKeys.intCompareError].
  void isBetween({
    required int min,
    required int max,
    OnValidate<int?>? devMessage,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
    bool inclusiveInterval = true,
    ValidationSeverity severity = .error,
  }) => satisfy(
    (value) {
      if (value == null) return false;

      return inclusiveInterval ? value >= min && value <= max : value > min && value < max;
    },
    devMessage:
        devMessage ??
        (value) => 'Value ${value ?? 'NULL'} (inclusiveInterval: $inclusiveInterval) is not in between $min and $max.',
    key: key ?? GladeValidationsKeys.intCompareError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Compares given value with [min] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeValidationsKeys.intCompareMinError].
  void isMin({
    required int min,
    bool isInclusive = true,
    OnValidate<int?>? devMessage,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => satisfy(
    (value) {
      if (value == null) return false;

      return isInclusive ? value >= min : value > min;
    },
    devMessage: devMessage ?? (value) => 'Value ${value ?? 'NULL'} is less than $min.',
    key: key ?? GladeValidationsKeys.intCompareMinError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Compares given value with [max] value.
  ///
  /// If [isInclusive] is set to true(default), the comparison is inclusive.
  ///
  /// Default [key] is [ GladeValidationsKeys.intCompareMaxError].
  void isMax({
    required int max,
    bool isInclusive = true,
    OnValidate<int?>? devMessage,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => satisfy(
    (value) {
      if (value == null) return false;

      return isInclusive ? value <= max : value < max;
    },
    devMessage: devMessage ?? (value) => 'Value ${value ?? 'NULL'} is bigger than $max.',
    key: key ?? GladeValidationsKeys.intCompareMaxError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Checks if the given value is positive.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeValidationsKeys.intCompareIsPositiveError].
  void isPositive({
    bool includeZero = true,
    OnValidate<int?>? devMessage,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => isMin(
    min: 0,
    isInclusive: includeZero,
    devMessage: devMessage,
    key: key ?? GladeValidationsKeys.intCompareIsPositiveError,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Checks if the given value is negative.
  ///
  /// If [includeZero] is set to true(default), the value can be zero.
  ///
  /// Default [key] is [GladeValidationsKeys.intCompareIsNegativeError].
  void isNegative({
    bool includeZero = true,
    OnValidate<int?>? devMessage,
    Object? key,
    ShouldValidateCallback<int?>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => isMax(
    max: 0,
    isInclusive: includeZero,
    devMessage: devMessage,
    key: key ?? GladeValidationsKeys.intCompareIsNegativeError,
    shouldValidate: shouldValidate,
    severity: severity,
  );
}
