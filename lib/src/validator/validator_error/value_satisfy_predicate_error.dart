import 'package:glade_forms/src/validator/validator_error/generic_validator_error.dart';

class ValueSatisfyPredicateError<T> extends GenericValidatorError<T> {
  const ValueSatisfyPredicateError({
    required super.value,
    required super.devError,
    super.extra,
    super.localeKey,
  });
}
