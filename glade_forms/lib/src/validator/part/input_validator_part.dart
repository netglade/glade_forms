import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

typedef ShouldValidateCallback<T> = bool Function(T value);

abstract class InputValidatorPart<T> {
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: prefer-correct-callback-field-name, name is ok.
  final ShouldValidateCallback<T>? shouldValidate;

  const InputValidatorPart({this.key, this.shouldValidate});

  GladeValidatorError<T>? validate(T value);
}
