import 'package:glade_forms/src/src.dart';

class IntValidator extends GladeValidator<int> {
  IntValidator();

  /// Compares given value with [min] and [max] values.
  void isBetween({
    required int min,
    required int max,
    OnValidateError<int>? devError,
    Object? key,
    ShouldValidateCallback<int>? shouldValidate,
  }) =>
      satisfy(
        (value) => value >= min && value <= max,
        devError: devError ?? (value) => 'Value ${value ?? 'NULL'} in not in between $min and $max.',
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
