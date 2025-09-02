import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

class ValueSatisfyPredicateError<T> extends GladeValidatorResult<T> {
  ValueSatisfyPredicateError({
    required super.value,
    required super.devError,
    required super.key,
    super.errorServerity,
  });
}
