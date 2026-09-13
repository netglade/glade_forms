import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/validator_result/async_validation_state.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Complete result of validation process.
///
/// Contains synchronous results and, when [asyncState] is [AsyncValidationState.done],
/// also asynchronous results produced for [asyncValidatedValue].
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

  /// State of asynchronous validation.
  final AsyncValidationState asyncState;

  /// Value for which async results in [all] were produced. Set only when [asyncState] is `done`.
  final T? asyncValidatedValue;

  /// Returns `true` if there are no errors among known results. Does not consider [asyncState].
  bool get isValid => errors.isEmpty;

  /// Returns `true` if there are no errors or warnings among known results. Does not consider [asyncState].
  bool get isValidWithoutWarnings => all.isEmpty;

  /// Returns `true` if there are errors.
  bool get isNotValid => errors.isNotEmpty;

  /// Async validation is scheduled or running for the current value.
  bool get isValidating => asyncState == .pending;

  @override
  List<Object?> get props => [associatedInput, all, errors, warnings, asyncState, asyncValidatedValue];

  const ValidatorResult({
    required this.all,
    required this.errors,
    required this.warnings,
    required this.associatedInput,
    this.asyncState = .notRun,
    this.asyncValidatedValue,
  });

  bool isValidWithSeverity(ValidationSeverity severity) {
    return switch (severity) {
      .error => isValid,
      .warning => isValidWithoutWarnings,
    };
  }

  ValidatorResult<T> copyWith({
    List<GladeValidatorResult<T>>? all,
    List<GladeValidatorResult<T>>? errors,
    List<GladeValidatorResult<T>>? warnings,
    GladeInput<T>? associatedInput,
    AsyncValidationState? asyncState,
    T? asyncValidatedValue,
  }) => .new(
    all: all ?? this.all,
    errors: errors ?? this.errors,
    warnings: warnings ?? this.warnings,
    associatedInput: associatedInput ?? this.associatedInput,
    asyncState: asyncState ?? this.asyncState,
    asyncValidatedValue: asyncValidatedValue ?? this.asyncValidatedValue,
  );
}
