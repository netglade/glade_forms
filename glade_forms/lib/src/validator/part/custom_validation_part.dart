import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

typedef CustomValidatorType<T> = GladeValidatorResult<T>? Function(T value);

class CustomValidationPart<T> extends InputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final CustomValidatorType<T> customValidator;

  const CustomValidationPart({
    required this.customValidator,
    super.key,
    super.shouldValidate,
    super.serverity,
  });

  @override
  GladeValidatorResult<T>? validate(T value) => customValidator(value);
}
