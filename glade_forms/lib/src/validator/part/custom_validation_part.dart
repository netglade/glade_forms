import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

class CustomValidationPart<T> extends InputValidatorPart<T> {
  final GenericValidatorError<T>? Function(T? value, {Object? extra}) customValidator;

  const CustomValidationPart({required this.customValidator, super.key});

  @override
  GenericValidatorError<T>? validate(T? value, {required Object? extra}) => customValidator(value, extra: extra);
}
