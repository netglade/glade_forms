import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

typedef CustomValidatorType<T> = GladeValidatorError<T>? Function(
    T value, {
    required InputDependencies dependencies,
    Object? extra,
  });

class CustomValidationPart<T> extends InputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final CustomValidatorType<T> customValidator;

  const CustomValidationPart({
    required this.customValidator,
    required super.dependencies,
    super.key,
  });

  @override
  GladeValidatorError<T>? validate(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) =>
      customValidator(value, extra: extra, dependencies: dependencies);
}
