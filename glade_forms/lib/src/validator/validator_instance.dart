import 'package:collection/collection.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:glade_forms/src/validator/validator_result/async_validation_outcome.dart';
import 'package:glade_forms/src/validator/validator_result/validator_error.dart';
import 'package:meta/meta.dart';

class ValidatorInstance<T> {
  /// Stops validation on first error.
  ///
  /// Continues on warning.
  final bool stopOnFirstError;

  /// Stop validation on first error or warning.
  final bool stopOnFirstErrorOrWarning;

  /// Delay between the last validation request and the start of async validation.
  final Duration asyncDebounce;

  GladeInput<T>? _input;

  final List<InputValidatorPart<T>> _parts;

  final List<AsyncInputValidatorPart<T>> _asyncParts;

  /// Whether any asynchronous part is declared.
  bool get hasAsyncParts => _asyncParts.isNotEmpty;

  ValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
    required this.stopOnFirstErrorOrWarning,
    List<AsyncInputValidatorPart<T>> asyncParts = const [],
    this.asyncDebounce = const Duration(milliseconds: 300),
  }) : _parts = parts,
       _asyncParts = asyncParts;

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
        final isError = result.severity == .error;

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

  /// Performs synchronous validation followed by asynchronous parts.
  ///
  /// Async parts run sequentially in declaration order. A part is skipped when its `shouldValidate`
  /// returns `false`, or when it has `runOnlyWhenSyncValid` and synchronous validation produced an error
  /// (or already stopped through [stopOnFirstError] / [stopOnFirstErrorOrWarning]).
  /// A part declared with `runOnlyWhenSyncValid: false` runs even then - the per-part opt-out wins over the stop flags.
  ///
  /// Exceptions thrown by a part (or by its `shouldValidate`) are passed to its `onError`;
  /// without it [AsyncValidationFailedError] is reported.
  Future<ValidatorResult<T>> validateAsync(T value) async {
    final syncResult = validate(value);
    final outcome = await runAsyncParts(value, syncResult);

    return combineWithAsyncResults(syncResult, outcome.results, asyncValidatedValue: value);
  }

  /// Runs asynchronous parts against [value] given an already computed [syncResult].
  ///
  /// Returns only the asynchronous results so that the synchronous half can be recomputed later.
  @internal
  Future<AsyncValidationOutcome<T>> runAsyncParts(T value, ValidatorResult<T> syncResult) async {
    final results = <GladeValidatorResult<T>>[];
    final syncStopped = _syncStopped(syncResult);
    var hasFailure = false;

    for (final part in _asyncParts) {
      if (part.runOnlyWhenSyncValid && (syncStopped || syncResult.isNotValid)) continue;

      final partOutcome = await _runAsyncPart(part, value);

      if (partOutcome.hasFailure) hasFailure = true;

      final result = partOutcome.results.firstOrNull;

      if (result == null) continue;

      results.add(result);

      if (stopOnFirstError && result.severity == .error) break;
      if (stopOnFirstErrorOrWarning) break;
    }

    return AsyncValidationOutcome(results: results, hasFailure: hasFailure);
  }

  /// Merges [syncResult] with already computed [asyncResults].
  ///
  /// The synchronous half is always the one passed in, so a recomputed [syncResult] never keeps stale errors.
  /// Asynchronous results are appended as they are - [runAsyncParts] already applied [stopOnFirstError] and
  /// [stopOnFirstErrorOrWarning] among them, and a part which opted out through `runOnlyWhenSyncValid: false`
  /// reports its result even when the synchronous half produced an error.
  @internal
  ValidatorResult<T> combineWithAsyncResults(
    ValidatorResult<T> syncResult,
    List<GladeValidatorResult<T>> asyncResults, {
    required T asyncValidatedValue,
  }) {
    final combined = [...syncResult.all];
    final errors = [...syncResult.errors];
    final warnings = [...syncResult.warnings];

    for (final result in asyncResults) {
      combined.add(result);

      if (result.severity == .error) {
        errors.add(result);
      } else {
        warnings.add(result);
      }
    }

    return ValidatorResult(
      all: combined,
      errors: errors,
      warnings: warnings,
      associatedInput: _input,
      asyncState: .done,
      asyncValidatedValue: asyncValidatedValue,
    );
  }

  /// Whether [validateAsync] would run at least one asynchronous part given [syncResult].
  bool shouldRunAsyncParts(ValidatorResult<T> syncResult) {
    if (!hasAsyncParts) return false;

    final runsSyncDependentParts = !_syncStopped(syncResult) && syncResult.isValid;

    return _asyncParts.any((part) => runsSyncDependentParts || !part.runOnlyWhenSyncValid);
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

  /// Finds asynchronous part with given [key] or returns `null`.
  AsyncInputValidatorPart<T>? tryFindAsyncValidatorPart(Object key) {
    return _asyncParts.firstWhereOrNull((part) => part.key == key);
  }

  /// Finds asynchronous part with given [key]. Throws [ArgumentError] when there is no such part.
  AsyncInputValidatorPart<T> findAsyncValidatorPart(Object key) {
    return _asyncParts.firstWhere(
      (part) => part.key == key,
      orElse: () => throw ArgumentError('No async validator part found for key: $key'),
    );
  }

  /// Whether a synchronous or asynchronous part with [key] is declared.
  bool hasDeclaredValidator(Object key) {
    return _parts.any((part) => part.key == key) || _asyncParts.any((part) => part.key == key);
  }

  bool _syncStopped(ValidatorResult<T> syncResult) =>
      (stopOnFirstError && syncResult.isNotValid) || (stopOnFirstErrorOrWarning && syncResult.all.isNotEmpty);

  Future<AsyncValidationOutcome<T>> _runAsyncPart(AsyncInputValidatorPart<T> part, T value) async {
    try {
      final shouldValidate = part.shouldValidate?.call(value) ?? true;

      if (!shouldValidate) return const AsyncValidationOutcome(results: [], hasFailure: false);

      final result = await part.validate(value);

      return AsyncValidationOutcome(results: [?result], hasFailure: false);
      // ignore: avoid_catches_without_on_clauses, any exception must be turned into a validation result
    } catch (e, stackTrace) {
      final onError = part.onError;
      final result = onError != null
          ? onError(value, e, stackTrace, part.key)
          // Severity of an infrastructure failure never follows the part's own severity - see docs.
          : AsyncValidationFailedError<T>(value: value, error: e, stackTrace: stackTrace, partKey: part.key);

      return AsyncValidationOutcome(results: [?result], hasFailure: true);
    }
  }
}
