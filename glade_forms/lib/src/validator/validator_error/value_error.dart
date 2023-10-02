import 'package:glade_forms/src/validator/validator_error/generic_validator_error.dart';

class ValueError<T> extends GenericValidatorError<T> {
  ValueError({
    required super.value,
    required super.devError,
    super.extra,
    super.key,
  });
}
