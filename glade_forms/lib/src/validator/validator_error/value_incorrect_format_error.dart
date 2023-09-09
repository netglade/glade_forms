import 'package:glade_forms/src/validator/validator_error/generic_validator_error.dart';

class ValueIncorrectFormatError<T> extends GenericValidatorError<T> {
  ValueIncorrectFormatError({
    required super.value,
    OnError<T>? devError,
    super.extra,
    super.key,
  }) : super(devError: devError ?? (value, __) => 'Given value "${value ?? 'NULL'}" does not have valid format');
}
