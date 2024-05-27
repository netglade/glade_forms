import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

typedef CustomValidatorType<T> = GladeValidatorError<T>? Function(T value);

class CustomValidationPart<T> extends InputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final CustomValidatorType<T> customValidator;

  const CustomValidationPart({required this.customValidator, super.key, super.shouldValidate});

  @override
  GladeValidatorError<T>? validate(T value) => customValidator(value);
}
