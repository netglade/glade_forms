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

  @override
  Future<GladeValidatorError<T>?> validateAsync(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) {
    return Future.value(validate(value, extra: extra, dependencies: dependencies));
  }
}

class CustomValidationPartAsync<T> extends InputValidatorPart<T> {
  final ValidateFunctionAsync<T> customValidator;

  const CustomValidationPartAsync({
    required this.customValidator,
    required super.dependencies,
    super.key,
  });

  @override
  GladeValidatorError<T> validate(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) =>
      throw UnsupportedError('Use [validateAsync] in CustomValidationPartAsync');

  @override
  Future<GladeValidatorError<T>?> validateAsync(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) {
    return customValidator(value, extra: extra, dependencies: dependencies);
  }
}
