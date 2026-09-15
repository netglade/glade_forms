import 'package:glade_forms/src/core/error/glade_validations_keys.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Produced when an async validator throws and no custom `onError` handler was provided.
///
/// Key is always [GladeValidationsKeys.asyncValidationFailed]; the failing part's own key is in [partKey].
class AsyncValidationFailedError<T> extends GladeValidatorResult<T> {
  /// Exception thrown by the async validator.
  // ignore: no-object-declaration, error can be any object
  final Object error;

  final StackTrace stackTrace;

  /// Key of the async validator part which failed.
  // ignore: no-object-declaration, key can be any object
  final Object? partKey;

  AsyncValidationFailedError({
    required super.value,
    required this.error,
    required this.stackTrace,
    this.partKey,
    OnValidate<T>? devMessage,
    super.errorServerity,
  }) : super(
         key: GladeValidationsKeys.asyncValidationFailed,
         devMessage: devMessage ?? ((_) => 'Async validation failed: $error'),
       );
}
