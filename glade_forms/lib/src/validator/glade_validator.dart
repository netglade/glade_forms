import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/custom_validation_part.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/part/satisfy_predicate_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';

typedef ValidateFunction<T> = GladeValidatorError<T>? Function(T value);
typedef ValidateFunctionWithKey<T> = GladeValidatorError<T>? Function(T value, Object? key);
typedef ValidateFunctionAsync<T> = Future<GladeValidatorError<T>?> Function(T value);

class GladeValidator<T> {
  List<InputValidatorPart<T>> parts = [];

  ValidatorInstance<T> build({
    /// Returns validation result on first error or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstError = true,
  }) =>
      ValidatorInstance(parts: parts, stopOnFirstError: stopOnFirstError);

  void clear() => parts = [];

  /// Checks value with custom validation function.
  void custom(ValidateFunctionWithKey<T> onValidate, {Object? key, ShouldValidateCallback<T>? shouldValidate}) {
    parts.add(
      CustomValidationPart(
        customValidator: (v) => onValidate(v, key),
        key: key,
        shouldValidate: shouldValidate,
      ),
    );
  }

  /// Checks value with custom validation function.
  void customAsync(ValidateFunctionAsync<T> onValidate, {Object? key}) =>
      parts.add(CustomValidationPartAsync(customValidator: onValidate, key: key));

  /// Checks value through custom validator [part].
  void customPart(InputValidatorPart<T> part) => parts.add(part);

  /// Checks that value is not null. Returns [ValueNullError] error.
  void notNull({OnValidateError<T>? devError, Object? key, ShouldValidateCallback<T>? shouldValidate}) =>
      _customInternal(
        (value) => value == null
            ? ValueNullError<T>(
                value: value,
                devError: devError,
                key: key ?? GladeErrorKeys.valueIsNull,
              )
            : null,
        shouldValidate: shouldValidate,
      );

  /// Value must satisfy given [predicate]. Returns [ValueSatisfyPredicateError].
  void satisfy(
    SatisfyPredicate<T> predicate, {
    OnValidateError<T>? devError,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
  }) =>
      parts.add(
        SatisfyPredicatePart(
          predicate: predicate,
          devError: devError ?? (value) => 'Value ${value ?? 'NULL'} does not satisfy given predicate.',
          key: key,
          shouldValidate: shouldValidate,
        ),
      );

  /// Checks value with custom validation function.
  void _customInternal(ValidateFunction<T> onValidate, {Object? key, ShouldValidateCallback<T>? shouldValidate}) =>
      parts.add(CustomValidationPart(customValidator: onValidate, key: key, shouldValidate: shouldValidate));
  /// Value must satisfy given [predicate]. Returns [ValueSatisfyPredicateError].
  void satisfyAsync(
    SatisfyPredicateAsync<T> predicate, {
    OnValidateError<T>? devError,
    Object? key,
  }) =>
      parts.add(
        SatisfyPredicatePartAsync(
          predicate: predicate,
          devError: devError ?? (value) => 'Value ${value ?? 'NULL'} does not satisfy given predicate.',
          key: key,
        ),
      );
}
