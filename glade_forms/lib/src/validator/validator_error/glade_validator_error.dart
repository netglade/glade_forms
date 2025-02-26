import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/glade_input_error.dart';

/// When validation failed but we already have propert [T] value.
typedef OnValidateError<T> = String Function(T value);

abstract class GladeValidatorError<T> extends GladeInputError<T> with EquatableMixin {
  /// Error message when translation is not used. Useful for development.
  // ignore: prefer-correct-callback-field-name, ok name
  final OnValidateError<T> devError;

  /// Value which triggered validation and returned this error.
  final T value;

  @override
  // ignore: no-object-declaration, error can be anything (but typically it is string)
  Object get error => devError(value);

  String get devErrorMessage => devError(value);

  @override
  List<Object?> get props => [value, devError, key, error, isConversionError, isNullError];

  GladeValidatorError({
    required this.value,
    required super.key,
    OnValidateError<T>? devError,
  }) : devError = devError ??
            ((v) =>
                'Value "${v ?? 'NULL'}" does not satisfy validation. [This is default validation meessage. Use `devError` to customize validation errors]');

  @override
  String toString() {
    return devError(value);
  }
}
