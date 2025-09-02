import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

class ValidatorResult<T> extends Equatable {
  final GladeInput<T>? associatedInput;
  final List<GladeValidatorResult<T>> all;
  final List<GladeValidatorResult<T>> warnings;
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

  bool isValidWithSeverity(ErrorServerity severity) {
    return switch (severity) {
      ErrorServerity.error => isValid,
      ErrorServerity.warning => isValidWithoutWarnings,
    };
  }
}
