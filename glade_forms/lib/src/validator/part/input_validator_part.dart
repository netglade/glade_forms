import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

abstract class InputValidatorPart<T> {
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  const InputValidatorPart({this.key});

  GladeValidatorError<T>? validate(T value);

  Future<GladeValidatorError<T>?> validateAsync(T value);
}
