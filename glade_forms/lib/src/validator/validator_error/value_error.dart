import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class ValueError<T> extends GladeValidatorError<T> {
  ValueError({
    required super.value,
    required super.devError,
    super.extra,
    super.key,
  });
}
