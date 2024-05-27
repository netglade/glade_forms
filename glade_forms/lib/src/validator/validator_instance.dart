import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

import '../core/glade_input_base.dart';

class ValidatorInstance<T> {
  /// Stops validation on first error.
  final bool stopOnFirstError;

  GladeInputBase<T>? _input;
  final List<InputValidatorPart<T>> _parts;

  ValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
  }) : _parts = parts;

  // ignore: use_setters_to_change_properties, this is ok
  void bindInput(GladeInputBase<T> input) => _input = input;

  /// Performs validation on given [value].
  ValidatorResult<T> validate(T value) {
    final errors = <GladeValidatorError<T>>[];

    for (final part in _parts) {
      final error = part.validate(value);

      if (error != null) {
        errors.add(error);

        if (stopOnFirstError) return ValidatorResult(errors: errors, associatedInput: _input);
      }
    }

    return ValidatorResult(errors: errors, associatedInput: _input);
  }
}
