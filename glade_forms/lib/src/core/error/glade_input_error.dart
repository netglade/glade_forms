import 'package:glade_forms/src/core/error/convert_error.dart';
import 'package:glade_forms/src/core/error/error_serverity.dart';
import 'package:glade_forms/src/core/error/glade_error_keys.dart';
import 'package:glade_forms/src/validator/validator.dart';

abstract class GladeInputError<T> {
  /// Can be used to identify concrete error when translating.
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  Object? get error;

  ErrorServerity get severity;

  bool get isConversionError => this is ConvertError<T>;
  bool get isNullError => this is ValueNullError<T>;

  bool get hasStringEmptyOrNullErrorKey => key == GladeErrorKeys.stringEmpty;
  bool get hasNullValueOrEmptyValueKey => key == GladeErrorKeys.valueIsNull || key == GladeErrorKeys.valueIsEmpty;

  const GladeInputError({this.key});
}

// ignore: prefer-single-declaration-per-file, keep here.
extension GladeInputErrorListExtension<T> on List<GladeInputError<T>> {
  /// Returns `true` if any of errors is conversion error.
  bool get hasConversionError => any((error) => error.isConversionError);

  /// Returns `true` if any of errors is null error.
  bool get hasNullError => any((error) => error.isNullError);

  /// Returns `true` if any of errors has key `GladeErrorKeys.stringEmpty`.
  bool get hasStringEmptyOrNullErrorKey => any((error) => error.hasStringEmptyOrNullErrorKey);

  /// Returns `true` if any of errors has key `GladeErrorKeys.valueIsNull` or `GladeErrorKeys.valueIsEmpty`.
  bool get hasNullValueOrEmptyValueKey => any((error) => error.hasNullValueOrEmptyValueKey);

  /// Returns `true` if any of errors has key `key`.
  bool hasErrorKey(Object key) => any((error) => error.key == key);

  /// Returns `true` if all errors has key `key` and there are no other errors.
  bool hasOnlySpecificErrorKey(Object key) => every((error) => error.key == key);
}
