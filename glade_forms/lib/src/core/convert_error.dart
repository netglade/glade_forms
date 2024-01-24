import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/glade_input_error.dart';

/// Before validation when converer from string to prpoer type failed.
typedef OnConvertError = String Function(String? rawInput, {Object? extra, Object? key});

class ConvertError<T> extends GladeInputError<T> with EquatableMixin implements Exception {
  // ignore: prefer-correct-callback-field-name, more suitable name
  final OnConvertError devError;

  final String? input;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  final Object? _convertError;

  @override
  List<Object?> get props =>
      [input, devError, error, key, _convertError, isConversionError, isNullError, hasStringEmptyOrNullErrorKey];

  String get targetType => T.runtimeType.toString();

  String get devErrorMessage => devError(input, extra: error, key: key);

  @override
  // ignore: no-object-declaration, error can be any object.
  Object? get error => _convertError;

  ConvertError({
    required Object error,
    required this.input,
    super.key,
    OnConvertError? formatError,
  })  : _convertError = error,
        devError = formatError ?? ((rawValue, {extra, key}) => 'Conversion error: $error');

  @override
  String toString() => devError(input, key: key);
}
