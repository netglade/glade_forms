import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Represents a validation error for a specific value.
class ValueError<T> extends GladeValidatorResult<T> {
  ValueError({
    required super.value,
    required super.devMessage,
    required super.key,
    super.errorServerity,
  });
}
