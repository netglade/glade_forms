import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

class CustomPart<T> extends InputValidatorPart<T> {
  final GenericValidatorError<T>? Function(T? value, {Object? extra})
      customValidator;

  const CustomPart({required this.customValidator, super.localeKey});

  @override
  GenericValidatorError<T>? validate(T? value, {required Object? extra}) =>
      customValidator(value, extra: extra);
}
