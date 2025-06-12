import 'package:glade_forms/src/core/error/convert_error.dart';
import 'package:glade_forms/src/core/error/glade_error_keys.dart';

typedef OnErrorCallback<T> = ConvertError<T> Function(String? rawValue, Object error);

typedef ConverterToType<T> =
    T Function(
      String? rawInput,
      T Function(
        Object error, {
        required String? rawValue,
        Object? key,
        OnConvertError? onError,
      })
      cantConvert,
    );

typedef TypeConverterToString<T> = String? Function(T rawInput);

/// Used to convert string input into `T` value.
class StringToTypeConverter<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final ConverterToType<T> converter;
  final OnErrorCallback<T> onError;

  // ignore: prefer-correct-callback-field-name, ok name
  final TypeConverterToString<T> _converterBack;

  StringToTypeConverter({
    /// Converts string value to [T] type.
    required this.converter,

    /// Converts [T] back to string.
    TypeConverterToString<T>? converterBack,
    //OnErrorCallback<T>? onError,
  }) : _converterBack = converterBack ?? ((rawInput) => rawInput?.toString() ?? ''),
       onError = ((rawValue, error) => ConvertError<T>(input: rawValue, error: error));

  /// Converts string input into `T` value.
  T convert(String? input) {
    try {
      return converter(input, _cantConvert);
    } on ConvertError<T> {
      // If _cantConvert were used -> we already thrown an Error.
      rethrow;
    } catch (e) {
      // ignore: avoid-throw-in-catch-block, this method should throw custom exception
      throw onError(input, e);
    }
  }

  /// Converts [T] back to string.
  String convertBack(T input) => _converterBack(input) ?? input.toString();

  T _cantConvert(
    Object error, {
    required String? rawValue,
    Object? key,
    OnConvertError? onError,
  }) => throw ConvertError<T>(
    input: rawValue,
    formatError: onError,
    error: error,
    key: key ?? GladeErrorKeys.conversionError,
  );
}
