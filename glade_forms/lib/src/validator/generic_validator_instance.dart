import 'package:glade_forms/glade_forms.dart';

class GenericValidatorInstance<T> {
  /// Stops validation on first error.
  final bool stopOnFirstError;

  late GladeInput<T> _input;
  final List<InputValidatorPart<T>> _parts;

  GenericValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
  }) : _parts = parts;

  // ignore: use_setters_to_change_properties, this is ok
  void bindInput(GladeInput<T> input) => _input = input;

  /// Performs validation on given [value].
  ValidatorErrors<T> validate(T value, {Object? extra}) {
    final errors = <GenericValidatorError<T>>[];

    for (final part in _parts) {
      final error = part.validate(value, extra: extra, dependencies: _input.dependencies());

      if (error != null) {
        errors.add(error);

        if (stopOnFirstError) return ValidatorErrors<T>(errors: errors, associatedInput: _input);
      }
    }

    return ValidatorErrors<T>(errors: errors, associatedInput: _input);
  }
}
