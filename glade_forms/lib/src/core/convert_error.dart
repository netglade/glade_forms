import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/glade_input_error.dart';

/// Before validation when converer from string to prpoer type failed.
typedef OnConvertError = String Function(String? rawInput, {Object? extra, Object? key});

class ConvertError<T> extends GladeInputError<T> with EquatableMixin implements Exception {
  final OnConvertError devError;

  final String? input;

  // /// Can be used to identify concrete error when translating.
  // @override
  // // ignore: no-object-declaration, key can be any object.
  // final Object? key;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  final Object? _convertError;

  @override
  List<Object?> get props => [input, devError, error, key, _convertError, isConversionError];

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
        devError = formatError ??
            ((rawValue, {extra, key}) => 'Value "${rawValue ?? 'NULL'}" does not have valid format. Error: $error');

  @override
  String toString() => devError(input, key: key);
}
