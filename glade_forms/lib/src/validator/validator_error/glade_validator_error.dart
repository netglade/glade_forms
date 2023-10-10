import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/glade_input_error.dart';
import 'package:glade_forms/src/validator/validator_error/value_null_error.dart';

/// When validation failed but we already have propert [T] value.
typedef OnValidateError<T> = String Function(T? value, Object? extra);

abstract class GladeValidatorError<T> extends GladeInputError<T> with EquatableMixin {
  /// Error message when translation is not used. Useful for development.
  final OnValidateError<T> devError;

  // ignore: no-object-declaration, extra can be any object
  final Object? extra;

  /// Value which triggered validation and returned this error.
  final T? value;

  @override
  // ignore: no-object-declaration, error can be anything (but typically it is string)
  Object get error => devError(value, extra);

  String get devErrorMessage => devError(value, extra);

  @override
  List<Object?> get props =>
      [value, devError, extra, key, error, isConversionError, isNullError, hasStringEmptyOrNullErrorKey];

  GladeValidatorError({
    required this.value,
    OnValidateError<T>? devError,
    this.extra,
    super.key,
  }) : devError = devError ??
            ((value, _) =>
                'Value "${value ?? 'NULL'}" does not satisfy validation. [This is default validation meessage. Consider to set `devErro` to cutomize validation errors]');

  factory GladeValidatorError.cantBeNull(T? value, {Object? extra, Object? key}) =>
      ValueNullError<T>(value: value, key: key, extra: extra);

  @override
  String toString() {
    return devError(value, extra);
  }
}
