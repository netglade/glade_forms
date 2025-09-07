import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/glade_input_validation.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';

/// When validation failed but we already have propert [T] value.
typedef OnValidate<T> = String Function(T value);

abstract class GladeValidatorResult<T> extends GladeInputValidation<T> with EquatableMixin {
  /// Error message when translation is not used. Useful for development.
  final OnValidate<T> onValidateMessage;

  /// Value which triggered validation and returned this error.
  final T value;

  final ValidationSeverity _errorServerity;

  @override
  ValidationSeverity get severity => _errorServerity;

  @override
  String get result => onValidateMessage(value);

  /// Developer friendly validation message.
  String get devValidationMessage => onValidateMessage(value);

  @override
  List<Object?> get props =>
      [value, onValidateMessage, key, result, isConversionError, isNullError, severity, _errorServerity];

  GladeValidatorResult({
    required this.value,
    required super.key,
    OnValidate<T>? devMessage,
    ValidationSeverity errorServerity = ValidationSeverity.error,
  })  : onValidateMessage = devMessage ??
            ((v) =>
                'Value "${v ?? 'NULL'}" does not satisfy validation. [This is default validation meessage. Use `onValidateMessage` to customize validation errors]'),
        _errorServerity = errorServerity;

  @override
  String toString() {
    return onValidateMessage(value);
  }
}
