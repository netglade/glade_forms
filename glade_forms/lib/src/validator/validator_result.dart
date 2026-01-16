import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Complete result of validation process.
class ValidatorResult<T> with EquatableMixin {
  /// Input associated with this validation result.
  final GladeInput<T>? associatedInput;

  /// All results including errors and warnings.
  ///
  /// Order is preserved by the order of validators in the input.
  final List<GladeValidatorResult<T>> all;

  /// All warnings.
  final List<GladeValidatorResult<T>> warnings;

  /// All errors.
  final List<GladeValidatorResult<T>> errors;

  /// Returns `true` if there are no errors.
  bool get isValid => errors.isEmpty;

  /// Returns `true` if there are no errors or warnings.
  bool get isValidWithoutWarnings => all.isEmpty;

  /// Returns `true` if there are errors.
  bool get isNotValid => errors.isNotEmpty;

  @override
  List<Object?> get props => [associatedInput, all, errors, warnings];

  const ValidatorResult({
    required this.all,
    required this.errors,
    required this.warnings,
    required this.associatedInput,
  });

  bool isValidWithSeverity(ValidationSeverity severity) {
    return switch (severity) {
      .error => isValid,
      .warning => isValidWithoutWarnings,
    };
  }
}
