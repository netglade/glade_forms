import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

class ValueNullError<T> extends GladeValidatorResult<T> {
  ValueNullError({
    required super.value,
    required super.key,
    OnValidate<T>? devError,
    super.errorServerity,
  }) : super(devError: devError ?? (_) => "Value can't be null");
}
