import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/validator/validator_error/value_null_error.dart';

typedef OnError<T> = String Function(T? value, Object? extra);

abstract class GenericValidatorError<T> extends Equatable {
  /// Error message when translation is not used. Useful for development.
  final OnError<T> devError;

  // ignore: no-object-declaration, extra can be any object
  final Object? extra;

  /// Can be used to identify concrete error when translating.
  // ignore: no-object-declaration, locate key can be any object
  final Object? key;

  /// Value which triggered validation and returned this error.
  final T? value;

  String get onErrorMessage => devError(value, extra);

  @override
  List<Object?> get props => [value, devError, extra, key];

  const GenericValidatorError({
    required this.value,
    required this.devError,
    this.extra,
    this.key,
  });

  factory GenericValidatorError.cantBeNull(T? value, {Object? extra, Object? key}) =>
      ValueNullError<T>(value: value, key: key, extra: extra);

  @override
  String toString() {
    return devError(value, extra);
  }
}
