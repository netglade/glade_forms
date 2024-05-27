import 'package:glade_forms/src/validator/glade_validator.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class CustomValidationPart<T> extends InputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final ValidateFunction<T> customValidator;

  const CustomValidationPart({required this.customValidator, super.key, super.shouldValidate});

  @override
  GladeValidatorError<T>? validate(T value) => customValidator(value);

  @override
  Future<GladeValidatorError<T>?> validateAsync(T value) {
    return Future.value(validate(value));
  }
}

class CustomValidationPartAsync<T> extends InputValidatorPart<T> {
  final ValidateFunctionAsync<T> customValidator;

  const CustomValidationPartAsync({
    required this.customValidator,
    super.key,
  });

  @override
  GladeValidatorError<T> validate(T value) =>
      throw UnsupportedError('Use [validateAsync] in CustomValidationPartAsync');

  @override
  Future<GladeValidatorError<T>?> validateAsync(T value) => customValidator(value);
}
