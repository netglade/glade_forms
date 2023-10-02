import 'package:glade_forms/src/validator/validator_error/generic_validator_error.dart';

class ValueNullError<T> extends GenericValidatorError<T> {
  ValueNullError({
    required super.value,
    OnValidateError<T>? devError,
    super.extra,
    super.key,
  }) : super(devError: devError ?? (_, __) => "Value can't be null");
}
