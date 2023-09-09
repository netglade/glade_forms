import 'package:glade_forms/src/validator/validator_error/generic_validator_error.dart';

class ValueIncorrectFormatError<T> extends GenericValidatorError<T> {
  ValueIncorrectFormatError({
    required super.value,
    OnError<T>? devError,
    super.extra,
    super.localeKey,
  }) : super(devError: devError ?? (value, __) => 'Given value "$value" does not have valid format');
}
