import 'package:glade_forms/src/validator/generic_validator_instance.dart';
import 'package:glade_forms/src/validator/part/custom_validation_part.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/part/satisfy_predicate_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

typedef ValidateFunction<T> = GenericValidatorError<T>? Function(
  T? value, {
  Object? extra,
});

class GenericValidator<T> {
  List<InputValidatorPart<T>> parts = [];

  GenericValidatorInstance<T> build({
    /// Return validation result on first error or continue validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstError = true,
  }) =>
      GenericValidatorInstance<T>(parts: parts, stopOnFirstError: stopOnFirstError);

  void clear() => parts = [];

  /// Checks value with custom validation function.
  void custom(ValidateFunction<T> onValidate, {Object? key}) =>
      parts.add(CustomValidationPart(customValidator: onValidate, key: key));

  /// Checks value through custom validator [part].
  void customPart(InputValidatorPart<T> part) => parts.add(part);

  /// Checks that value is not null. Returns [ValueNullError] error.
  void notNull({OnError<T>? devError, Object? key}) => custom(
        (value, {extra}) => value == null
            ? ValueNullError<T>(
                value: value,
                devError: devError,
                extra: extra,
                key: key,
              )
            : null,
      );

  /// Value must satisfy given [predicate]. Returns [ValueSatisfyPredicateError].
  void satisfy(
    SatisfyPredicate<T> predicate, {
    required OnError<T> devError,
    Object? extra,
    Object? key,
  }) =>
      parts.add(
        SatisfyPredicatePart(
          predicate: predicate,
          devError: devError,
          extra: extra,
          key: key,
        ),
      );
}
