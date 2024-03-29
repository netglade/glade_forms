import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class ValueNullError<T> extends GladeValidatorError<T> {
  ValueNullError({
    required super.value,
    OnValidateError<T>? devError,
    super.key,
  }) : super(devError: devError ?? (_) => "Value can't be null");
}
