import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/error_serverity.dart';
import 'package:glade_forms/src/core/error/glade_input_error.dart';

/// When validation failed but we already have propert [T] value.
typedef OnValidate<T> = String Function(T value);

abstract class GladeValidatorResult<T> extends GladeInputError<T> with EquatableMixin {
  /// Error message when translation is not used. Useful for development.
  final OnValidate<T> onValidateMessage;

  /// Value which triggered validation and returned this error.
  final T value;

  final ErrorServerity _errorServerity;

  @override
  ErrorServerity get severity => _errorServerity;

  @override
  String get error => onValidateMessage(value);

  String get devErrorMessage => onValidateMessage(value);

  @override
  List<Object?> get props =>
      [value, onValidateMessage, key, error, isConversionError, isNullError, severity, _errorServerity];

  GladeValidatorResult({
    required this.value,
    required super.key,
    OnValidate<T>? devError,
    ErrorServerity errorServerity = ErrorServerity.error,
  })  : onValidateMessage = devError ??
            ((v) =>
                'Value "${v ?? 'NULL'}" does not satisfy validation. [This is default validation meessage. Use `onValidateMessage` to customize validation errors]'),
        _errorServerity = errorServerity;

  @override
  String toString() {
    return onValidateMessage(value);
  }
}
