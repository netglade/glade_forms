import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/glade_input_validation.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';

/// Before validation when converer from string to prpoer type failed.
typedef OnConvertError = String Function(String? rawInput, {Object? key});

class ConvertError<T> extends GladeInputValidation<T> with EquatableMixin implements Exception {
  final OnConvertError onConvertErrorMessage;

  final String? input;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  final Object _convertError;

  @override
  List<Object?> get props => [input, onConvertErrorMessage, result, key, _convertError];

  String get targetType => T.runtimeType.toString();

  String get devMessage => onConvertErrorMessage(input, key: key);

  @override
  // ignore: no-object-declaration, error can be any object.
  Object get result => _convertError;

  @override
  ValidationSeverity get severity => .error;

  ConvertError({
    required Object error,
    required this.input,
    super.key,
    OnConvertError? formatError,
  }) : _convertError = error,
       onConvertErrorMessage = formatError ?? ((rawValue, {key}) => 'Conversion error: $error');

  @override
  String toString() => onConvertErrorMessage(input, key: key);
}
