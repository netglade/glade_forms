import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

class CustomValidationPart<T> extends InputValidatorPart<T> {
  final GenericValidatorError<T>? Function(
    T? value, {
    required InputDependencies dependencies,
    Object? extra,
  }) customValidator;

  const CustomValidationPart({
    required this.customValidator,
    required super.dependencies,
    super.key,
  });

  @override
  GenericValidatorError<T>? validate(
    T? value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) =>
      customValidator(value, extra: extra, dependencies: dependencies);
}
