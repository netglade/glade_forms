import 'package:glade_forms/src/src.dart';

class CustomValidationPart<T> extends InputValidatorPart<T> {
  final ValidateFunction<T> customValidator;

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
