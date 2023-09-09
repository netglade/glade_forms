import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

// ignore: avoid-dynamic, ok for now
typedef OnErrorCallback<T> = ConvertError<T> Function(String? rawValue, dynamic error);

typedef Converter<T> = T Function(
  String? rawInput,
  T Function({
    // ignore: avoid-dynamic, ok for now
    required dynamic error,
    required String? rawValue,
    OnError<String>? onError,
  }) convert,
);

class StringToTypeConverter<T> {
  final Converter<T> converter;
  final OnErrorCallback<T> onError;

  StringToTypeConverter({
    required this.converter,
    OnErrorCallback<T>? onError,
  }) : onError = onError ?? ((rawValue, error) => ConvertError<T>(rawValue: rawValue, error: error));

  T convert(String? input) {
    try {
      return converter(input, _cantConvert);
    } on ConvertError<T> {
      // If _cantConvert were used -> we already thrown an Error.
      rethrow;
      // ignore: avoid_catches_without_on_clauses, has to be generic to it catches everything
    } catch (e) {
      // ignore: avoid-throw-in-catch-block, this method should throw custom exception
      throw onError(input, e);
    }
  }

  T _cantConvert({
    required String? rawValue,
    // ignore: avoid-dynamic, ok for now
    required dynamic error,
    OnError<String>? onError,
  }) =>
      throw ConvertError<T>(rawValue: rawValue, onError: onError, error: error);
}
