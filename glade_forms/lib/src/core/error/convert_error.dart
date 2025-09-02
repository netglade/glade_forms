import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/error_serverity.dart';
import 'package:glade_forms/src/core/error/glade_input_error.dart';

/// Before validation when converer from string to prpoer type failed.
typedef OnConvertError = String Function(String? rawInput, {Object? key});

class ConvertError<T> extends GladeInputError<T> with EquatableMixin implements Exception {
  final OnConvertError onConvertErrorMessage;

  final String? input;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  final Object _convertError;

  @override
  List<Object?> get props => [input, onConvertErrorMessage, error, key, _convertError];

  String get targetType => T.runtimeType.toString();

  String get devErrorMessage => onConvertErrorMessage(input, key: key);

  @override
  // ignore: no-object-declaration, error can be any object.
  Object get error => _convertError;

  @override
  ErrorServerity get severity => ErrorServerity.error;

  ConvertError({
    required Object error,
    required this.input,
    super.key,
    OnConvertError? formatError,
  })  : _convertError = error,
        onConvertErrorMessage = formatError ?? ((rawValue, {key}) => 'Conversion error: $error');

  @override
  String toString() => onConvertErrorMessage(input, key: key);
}
