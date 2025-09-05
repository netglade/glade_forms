import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Represents a validation error when a value is null.
class ValueNullError<T> extends GladeValidatorResult<T> {
  ValueNullError({
    required super.value,
    required super.key,
    OnValidate<T>? devMessage,
    super.errorServerity,
  }) : super(devMessage: devMessage ?? (_) => "Value can't be null");
}
