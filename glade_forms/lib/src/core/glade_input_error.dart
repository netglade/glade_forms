import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_error/validator_keys.dart';

abstract class GladeInputError<T> {
  /// Can be used to identify concrete error when translating.
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: no-object-declaration, error can be anything (but typically it is string)
  Object? get error;

  bool get isConversionError => this is ConvertError<T>;
  bool get isNullError => this is ValueNullError<T>;

  bool get hasStringEmptyOrNullErrorKey => key == GladeErrorKeys.stringEmpty;

  const GladeInputError({this.key});
}
