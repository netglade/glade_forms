import 'package:glade_forms/src/generic_input.dart';
import 'package:glade_forms/src/validator/validator.dart';

class GenericValidatorInstance<T> {
  /// Stops validation on first error.
  final bool stopOnFirstError;

  late GenericInput<T> _input;
  final List<InputValidatorPart<T>> _parts;

  GenericValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
  }) : _parts = parts;

  // ignore: use_setters_to_change_properties, this is ok
  void bindInput(GenericInput<T> input) => _input = input;

  /// Performs validation on given [value].
  ValidatorErrors<T> validate(T? value, {Object? extra}) {
    final errors = <GenericValidatorError<T>>[];

    for (final part in _parts) {
      final error = part.validate(value, extra: extra);

      if (error != null) {
        errors.add(error);

        if (stopOnFirstError) return ValidatorErrors<T>(errors: errors, associatedInput: _input);
      }
    }

    return ValidatorErrors<T>(errors: errors, associatedInput: _input);
  }
}
