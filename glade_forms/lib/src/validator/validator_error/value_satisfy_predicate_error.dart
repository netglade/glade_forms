import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class ValueSatisfyPredicateError<T> extends GladeValidatorError<T> {
  ValueSatisfyPredicateError({
    required super.value,
    required super.devError,
    super.key,
  });
}
