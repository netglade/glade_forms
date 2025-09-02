import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

class ValueError<T> extends GladeValidatorResult<T> {
  ValueError({
    required super.value,
    required super.devError,
    required super.key,
    super.errorServerity,
  });
}
