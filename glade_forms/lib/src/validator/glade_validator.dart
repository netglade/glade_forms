import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/core/error/error_serverity.dart';
import 'package:glade_forms/src/validator/part/custom_validation_part.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/part/satisfy_predicate_part.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';
import 'package:glade_forms/src/validator/validator_result/validator_error.dart';

typedef ValidateFunction<T> = GladeValidatorResult<T>? Function(T value);
typedef ValidateFunctionWithKey<T> = GladeValidatorResult<T>? Function(T value, Object? key);
typedef ValidatorFactory<T> = ValidatorInstance<T> Function(GladeValidator<T> v);

class GladeValidator<T> {
  List<InputValidatorPart<T>> parts = [];

  ValidatorInstance<T> build({
    /// Returns validation result on first error or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstError = true,

    /// Returns validation result on first error (or warning) or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstErrorOrWarning = false,
  }) =>
      ValidatorInstance(
        parts: parts,
        stopOnFirstError: stopOnFirstError,
        stopOnFirstErrorOrWarning: stopOnFirstErrorOrWarning,
      );

  /// Clears all validation parts.
  void clear() => parts = [];

  /// Checks value with custom validation function.
  void custom(
    ValidateFunctionWithKey<T> onValidate, {
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) {
    parts.add(
      CustomValidationPart(
        customValidator: (v) => onValidate(v, key),
        key: key,
        shouldValidate: shouldValidate,
        serverity: severity,
      ),
    );
  }

  /// Checks value through custom validator [part].
  void customPart(InputValidatorPart<T> part) => parts.add(part);

  /// Checks that value is not null. Returns [ValueNullError] error.
  void notNull({
    OnValidate<T>? devError,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      _customInternal(
        (value) => value == null
            ? ValueNullError<T>(
                value: value,
                devError: devError,
                key: key ?? GladeErrorKeys.valueIsNull,
                errorServerity: severity,
              )
            : null,
        shouldValidate: shouldValidate,
        severity: severity,
      );

  /// Value must satisfy given [predicate]. Returns [ValueSatisfyPredicateError].
  void satisfy(
    SatisfyPredicate<T> predicate, {
    OnValidate<T>? devError,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    Object? metaData,
    ErrorServerity severity = ErrorServerity.error,
  }) =>
      parts.add(
        SatisfyPredicatePart(
          predicate: predicate,
          devError: devError ?? (value) => 'Value ${value ?? 'NULL'} does not satisfy given predicate.',
          key: key,
          shouldValidate: shouldValidate,
          metaData: metaData,
          serverity: severity,
        ),
      );

  /// Checks value with custom validation function.
  void _customInternal(
    ValidateFunction<T> onValidate, {
    required ErrorServerity severity,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
  }) =>
      parts.add(
        CustomValidationPart(
          customValidator: onValidate,
          key: key,
          shouldValidate: shouldValidate,
          serverity: severity,
        ),
      );
}
