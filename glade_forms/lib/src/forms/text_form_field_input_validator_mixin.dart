import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:meta/meta.dart';

/// Provides short-hand validator function for TextFormField's [validator] function
///
/// That is function prototype `String? Function(String?)` - if there is any error it should return non-null string value.
///
/// This mixin could be mixed-in into GenericInput's with its validator for easy validation.
/// If [T] is not a String instance given class should override [converter] to provide concrete type converter ino concrete type.
mixin TextFormFieldInputValidatorMixin<T> on GladeInputBase<T> {
  @protected
  StringToTypeConverter<T> get converter => StringToTypeConverter<T>(converter: (x, _) => x as T);

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message. Translated message is returned through [translate].
  String? formFieldInputValidator(String? value, {String delimiter = '.'}) {
    try {
      final convertedValue = converter.convert(value);
      final convertedError = validator(convertedValue);

      return convertedError != null ? translate(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (formatError) {
      return formatError.error != null
          ? translate(delimiter: delimiter, customError: formatError.error)
          : formatError.devError(value, error);
    }
  }
}
