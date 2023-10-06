import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/glade_error_keys.dart';

typedef OnErrorCallback<T> = ConvertError<T> Function(String? rawValue, Object error);

typedef ConverterToType<T> = T Function(
  String? rawInput,
  T Function(
    Object error, {
    required String? rawValue,
    Object? key,
    OnConvertError? onError,
  }) cantConvert,
);

typedef TypeConverterToString<T> = String? Function(T rawInput);

/// Used to convert string input into `T` value.
class StringToTypeConverter<T> {
  final ConverterToType<T> converter;
  final OnErrorCallback<T> onError;

  final TypeConverterToString<T> _converterBack;

  StringToTypeConverter({
    /// Converts string value to [T] type.
    required this.converter,

    /// Converts [T] back to string.
    TypeConverterToString<T>? converterBack,
    //OnErrorCallback<T>? onError,
  })  : _converterBack = converterBack ?? ((rawInput) => rawInput.toString()),
        onError = ((rawValue, error) => ConvertError<T>(input: rawValue, error: error));

  T convert(String? input) {
    try {
      return converter(input, _cantConvert);
    } on ConvertError<T> {
      // If _cantConvert were used -> we already thrown an Error.
      rethrow;
    }
    // ignore: avoid_catches_without_on_clauses, has to be generic to catch everything
    catch (e) {
      // ignore: avoid-throw-in-catch-block, this method should throw custom exception
      throw onError(input, e);
    }
  }

  String? convertBack(T input) => _converterBack(input);

  T _cantConvert(
    Object error, {
    required String? rawValue,
    Object? key,
    OnConvertError? onError,
  }) =>
      throw ConvertError<T>(
        input: rawValue,
        formatError: onError,
        error: error,
        key: key ?? GladeErrorKeys.conversionError,
      );
}
