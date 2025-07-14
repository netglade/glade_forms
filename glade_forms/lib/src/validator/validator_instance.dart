import 'package:collection/collection.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

class ValidatorInstance<T> {
  /// Stops validation on first error.
  final bool stopOnFirstError;

  GladeInput<T>? _input;

  final List<InputValidatorPart<T>> _parts;

  ValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
  }) : _parts = parts;

  // ignore: use_setters_to_change_properties, this is ok
  void bindInput(GladeInput<T> input) => _input = input;

  /// Performs validation on given [value].
  ValidatorResult<T> validate(T value) {
    final errors = <GladeValidatorError<T>>[];

    for (final part in _parts) {
      final shouldValidate = part.shouldValidate?.call(value) ?? true;

      if (!shouldValidate) continue;

      final error = part.validate(value);

      if (error != null) {
        errors.add(error);

        if (stopOnFirstError) return ValidatorResult(errors: errors, associatedInput: _input);
      }
    }

    return ValidatorResult(errors: errors, associatedInput: _input);
  }

  InputValidatorPart<T>? tryFindValidatorPart(Object key) {
    return _parts.firstWhereOrNull((part) => part.key == key);
  }

  InputValidatorPart<T> findValidatorPart(Object key) {
    return _parts.firstWhere(
      (part) => part.key == key,
      orElse: () => throw ArgumentError('No validator part found for key: $key'),
    );
  }

  bool hasDeclaredValidator(Object key) {
    return _parts.any((part) => part.key == key);
  }
}
