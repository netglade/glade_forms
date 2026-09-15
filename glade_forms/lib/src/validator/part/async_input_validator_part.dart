import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Called when an async validator throws.
///
/// Return a result to report it as validation outcome, or `null` to treat the value as valid.
typedef OnAsyncValidationError<T> =
    GladeValidatorResult<T>? Function(T value, Object error, StackTrace stackTrace, Object? key);

/// Asynchronous counterpart of [InputValidatorPart].
///
/// Async parts run after synchronous parts, sequentially in declaration order.
///
/// Unlike [InputValidatorPart.serverity] this class spells the field `severity`.
abstract class AsyncInputValidatorPart<T> with EquatableMixin {
  /// Identification of this part.
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  /// When provided and it returns `false`, this part is skipped.
  // ignore: prefer-correct-callback-field-name, name is ok.
  final ShouldValidateCallback<T>? shouldValidate;

  /// Severity of produced result.
  final ValidationSeverity severity;

  /// When `true` (default) the part runs only if synchronous validation produced no error.
  final bool runOnlyWhenSyncValid;

  /// Custom handling of exceptions thrown by [validate]. When `null`, `AsyncValidationFailedError` is produced.
  final OnAsyncValidationError<T>? onError;

  @override
  // ignore: list-all-equatable-fields, on purpose
  List<Object?> get props => [key, severity, runOnlyWhenSyncValid];

  const AsyncInputValidatorPart({
    this.key,
    this.shouldValidate,
    this.severity = ValidationSeverity.error,
    this.runOnlyWhenSyncValid = true,
    this.onError,
  });

  /// Asynchronously validates [value]. Returns `null` when the value is valid.
  Future<GladeValidatorResult<T>?> validate(T value);
}
