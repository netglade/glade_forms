import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class ValueNullError<T> extends GladeValidatorError<T> {
  ValueNullError({
    required super.value,
    required super.key,
    OnValidateError<T>? devError,
  }) : super(devError: devError ?? (_) => "Value can't be null");
}
