import 'package:glade_forms/src/core/error/convert_error.dart';
import 'package:glade_forms/src/core/error/glade_error_keys.dart';
import 'package:glade_forms/src/validator/validator.dart';

abstract class GladeInputError<T> {
  /// Can be used to identify concrete error when translating.
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  Object? get error;

  bool get isConversionError => this is ConvertError<T>;
  bool get isNullError => this is ValueNullError<T>;

  bool get hasStringEmptyOrNullErrorKey => key == GladeErrorKeys.stringEmpty;
  bool get hasNullValueOrEmptyValueKey => key == GladeErrorKeys.valueIsNull || key == GladeErrorKeys.valueIsEmpty;

  const GladeInputError({this.key});
}

// ignore: prefer-single-declaration-per-file, keep here.
extension GladeInputErrorListExtension<T> on List<GladeInputError<T>> {
  bool get hasConversionError => any((error) => error.isConversionError);

  bool get hasNullError => any((error) => error.isNullError);

  bool get hasStringEmptyOrNullErrorKey => any((error) => error.hasStringEmptyOrNullErrorKey);

  bool get hasNullValueOrEmptyValueKey => any((error) => error.hasNullValueOrEmptyValueKey);

  bool hasErrorKey(Object key) => any((error) => error.key == key);

  bool hasOnlySpecificErrorKey(Object key) => every((error) => error.key == key);
}
