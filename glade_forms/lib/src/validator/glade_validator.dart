import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';
import 'package:glade_forms/src/validator/part/custom_async_validation_part.dart';
import 'package:glade_forms/src/validator/part/custom_validation_part.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/part/satisfy_async_predicate_part.dart';
import 'package:glade_forms/src/validator/part/satisfy_predicate_part.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';
import 'package:glade_forms/src/validator/validator_result/validator_error.dart';

typedef ValidateFunction<T> = GladeValidatorResult<T>? Function(T value);
typedef ValidateFunctionWithKey<T> = GladeValidatorResult<T>? Function(T value, Object? key);
typedef ValidatorFactory<T> = ValidatorInstance<T> Function(GladeValidator<T> v);
typedef AsyncValidateFunctionWithKey<T> = Future<GladeValidatorResult<T>?> Function(T value, Object? key);

class GladeValidator<T> {
  List<InputValidatorPart<T>> parts = [];

  /// Asynchronous validation parts. They run after [parts], sequentially in declaration order.
  List<AsyncInputValidatorPart<T>> asyncParts = [];

  ValidatorInstance<T> build({
    /// Returns validation result on first error or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstError = true,

    /// Returns validation result on first error (or warning) or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstErrorOrWarning = false,

    /// Delay between the last validation request and the start of async validation.
    ///
    /// Use [Duration.zero] to start immediately.
    Duration asyncDebounce = const Duration(milliseconds: 300),
  }) => .new(
    parts: parts,
    asyncParts: asyncParts,
    stopOnFirstError: stopOnFirstError,
    stopOnFirstErrorOrWarning: stopOnFirstErrorOrWarning,
    asyncDebounce: asyncDebounce,
  );

  /// Clears all validation parts, synchronous and asynchronous.
  void clear() {
    parts = [];
    asyncParts = [];
  }

  /// Checks value with custom asynchronous validation function.
  ///
  /// Runs after synchronous parts. With [runOnlyWhenSyncValid] (default) it is skipped when synchronous
  /// validation produced an error. Exceptions are passed to [onError]; without it `AsyncValidationFailedError`
  /// is reported.
  void customAsync(
    AsyncValidateFunctionWithKey<T> onValidate, {
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    ValidationSeverity severity = .error,
    bool runOnlyWhenSyncValid = true,
    OnAsyncValidationError<T>? onError,
  }) => asyncParts.add(
    CustomAsyncValidationPart(
      customValidator: (v) => onValidate(v, key),
      key: key,
      shouldValidate: shouldValidate,
      severity: severity,
      runOnlyWhenSyncValid: runOnlyWhenSyncValid,
      onError: onError,
    ),
  );

  /// Checks value through custom asynchronous validator [part].
  void customAsyncPart(AsyncInputValidatorPart<T> part) => asyncParts.add(part);

  /// Value must satisfy given asynchronous [predicate]. Returns [ValueSatisfyPredicateError].
  ///
  /// See [customAsync] for [runOnlyWhenSyncValid] and [onError] semantics.
  void satisfyAsync(
    AsyncSatisfyPredicate<T> predicate, {
    OnValidate<T>? devMessage,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    Object? metaData,
    ValidationSeverity severity = .error,
    bool runOnlyWhenSyncValid = true,
    OnAsyncValidationError<T>? onError,
  }) => asyncParts.add(
    SatisfyAsyncPredicatePart(
      predicate: predicate,
      devMessage: devMessage ?? (value) => 'Value ${value ?? 'NULL'} does not satisfy given async predicate.',
      key: key,
      shouldValidate: shouldValidate,
      metaData: metaData,
      severity: severity,
      runOnlyWhenSyncValid: runOnlyWhenSyncValid,
      onError: onError,
    ),
  );

  /// Checks value with custom validation function.
  void custom(
    ValidateFunctionWithKey<T> onValidate, {
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    ValidationSeverity severity = .error,
  }) {
    parts.add(
      CustomValidationPart(
        customValidator: (v) => onValidate(v, key),
        key: key,
        shouldValidate: shouldValidate,
        serverity: severity,
      ),
    );
  }

  /// Checks value through custom validator [part].
  void customPart(InputValidatorPart<T> part) => parts.add(part);

  /// Checks that value is not null. Returns [ValueNullError] error.
  void notNull({
    OnValidate<T>? devMessage,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    ValidationSeverity severity = .error,
  }) => _customInternal(
    (value) => value == null
        ? ValueNullError<T>(
            value: value,
            devMessage: devMessage,
            key: key ?? GladeValidationsKeys.valueIsNull,
            errorServerity: severity,
          )
        : null,
    shouldValidate: shouldValidate,
    severity: severity,
  );

  /// Value must satisfy given [predicate]. Returns [ValueSatisfyPredicateError].
  void satisfy(
    SatisfyPredicate<T> predicate, {
    OnValidate<T>? devMessage,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    Object? metaData,
    ValidationSeverity severity = .error,
  }) => parts.add(
    SatisfyPredicatePart(
      predicate: predicate,
      devMessage: devMessage ?? (value) => 'Value ${value ?? 'NULL'} does not satisfy given predicate.',
      key: key,
      shouldValidate: shouldValidate,
      metaData: metaData,
      serverity: severity,
    ),
  );

  /// Checks value with custom validation function.
  void _customInternal(
    ValidateFunction<T> onValidate, {
    required ValidationSeverity severity,
    // ignore: avoid-never-passed-parameters, keep for consistency
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
  }) => parts.add(
    CustomValidationPart(
      customValidator: onValidate,
      key: key,
      shouldValidate: shouldValidate,
      serverity: severity,
    ),
  );
}
