import 'package:glade_forms/src/core/error/convert_error.dart';
import 'package:glade_forms/src/core/error/glade_validations_keys.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';
import 'package:glade_forms/src/validator/validator.dart';

abstract class GladeInputValidation<T> {
  /// Can be used to identify concrete error when translating.
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: no-object-declaration, result can be anything (but typically it is string)
  Object? get result;

  ValidationSeverity get severity;

  bool get isConversionError => this is ConvertError<T>;
  bool get isNullError => this is ValueNullError<T>;

  bool get hasStringEmptyOrNullErrorKey => key == GladeValidationsKeys.stringEmpty;
  bool get hasNullValueOrEmptyValueKey =>
      key == GladeValidationsKeys.valueIsNull || key == GladeValidationsKeys.valueIsEmpty;

  const GladeInputValidation({this.key});
}

// ignore: prefer-single-declaration-per-file, keep here.
extension GladeInputErrorListExtension<T> on List<GladeInputValidation<T>> {
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
