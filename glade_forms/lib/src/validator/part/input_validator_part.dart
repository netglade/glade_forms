import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

abstract class InputValidatorPart<T> {
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  final InputDependencies dependencies;

  const InputValidatorPart({required this.dependencies, this.key});

  GladeValidatorError<T>? validate(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  });
}
