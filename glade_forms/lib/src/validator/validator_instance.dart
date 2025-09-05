import 'package:collection/collection.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

class ValidatorInstance<T> {
  /// Stops validation on first error.
  ///
  /// Continues on warning.
  final bool stopOnFirstError;

  /// Stop validation on first error or warning.
  final bool stopOnFirstErrorOrWarning;

  GladeInput<T>? _input;

  final List<InputValidatorPart<T>> _parts;

  ValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
    required this.stopOnFirstErrorOrWarning,
  }) : _parts = parts;

  // ignore: use_setters_to_change_properties, this is ok
  void bindInput(GladeInput<T> input) => _input = input;

  /// Performs validation on given [value].
  ValidatorResult<T> validate(T value) {
    final errors = <GladeValidatorResult<T>>[];
    final warnings = <GladeValidatorResult<T>>[];
    final combined = <GladeValidatorResult<T>>[];

    for (final part in _parts) {
      final shouldValidate = part.shouldValidate?.call(value) ?? true;

      if (!shouldValidate) continue;

      final result = part.validate(value);

      if (result != null) {
        final isError = result.severity == ValidationSeverity.error;

        combined.add(result);

        if (isError) {
          errors.add(result);
        } else {
          warnings.add(result);
        }

        if (stopOnFirstError && isError) {
          return ValidatorResult(all: combined, errors: errors, warnings: warnings, associatedInput: _input);
        }

        if (stopOnFirstErrorOrWarning) {
          return ValidatorResult(all: combined, errors: errors, warnings: warnings, associatedInput: _input);
        }
      }
    }

    return ValidatorResult(all: combined, errors: errors, warnings: warnings, associatedInput: _input);
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
