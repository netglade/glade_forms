import 'package:glade_forms/src/src.dart';

class IntValidator extends GladeValidator<int> {
  IntValidator();

  /// Compares given value with [a] and [b] values.
  void isBetween({
    required int a,
    required int b,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => a < b ? value >= a && value <= b : value >= b && value <= a,
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} in not in between $a and $b.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [min] value.
  void isMin({
    required int min,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => value >= min,
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} is less than $min.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );

  /// Compares given value with [max] value.
  void isMax({
    required int max,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => value <= max,
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} is bigger than $max.',
        key: key ?? GladeErrorKeys.intCompareError,
        shouldValidate: shouldValidate,
      );
}
