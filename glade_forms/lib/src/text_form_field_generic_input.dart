import 'package:glade_forms/src/generic_input.dart';
import 'package:glade_forms/src/string_to_type_converter.dart';
import 'package:glade_forms/src/text_form_field_input_validator.dart';
import 'package:glade_forms/src/validator/validator.dart';

bool _typesEqual<T1, T2>() => T1 == T2;

/// Same as generic input but with mixed-in [TextFormFieldInputValidator].
class TextFormFieldGenericInput<T> extends GenericInput<T> with TextFormFieldInputValidator<T?, ValidatorErrors<T>> {
  final StringToTypeConverter<T> _stringToTypeConverter;

  @override
  StringToTypeConverter<T?> get converter => _stringToTypeConverter;

  factory TextFormFieldGenericInput.create(
    GenericValidatorInstance<T> Function(GenericValidator<T> validator) validatorFactory, {
    T? defaultValue,
    bool pure = true,
    StringToTypeConverter<T>? converter,
    TranslateError<T>? translateError,
    String? inputName,
  }) {
    final instance = validatorFactory(GenericValidator<T>());

    return pure
        ? TextFormFieldGenericInput.pure(
            validator: instance,
            value: defaultValue,
            stringToTypeConverter: converter,
            translateError: translateError,
            inputName: inputName,
          )
        : TextFormFieldGenericInput.dirty(
            validator: instance,
            value: defaultValue,
            stringToTypeConverter: converter,
            translateError: translateError,
            inputName: inputName,
          );
  }

  TextFormFieldGenericInput.dirty({
    super.value,
    super.validator,
    StringToTypeConverter<T>? stringToTypeConverter,
    super.translateError,
    super.inputName,
  })  : assert(
          _typesEqual<T, String>() || _typesEqual<T, String?>() || stringToTypeConverter != null,
          'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
        ),
        _stringToTypeConverter = stringToTypeConverter ?? StringToTypeConverter<T>(converter: (x, _) => x as T),
        super.dirty();

  TextFormFieldGenericInput.pure({
    super.value,
    super.validator,
    StringToTypeConverter<T>? stringToTypeConverter,
    super.translateError,
    super.inputName,
  })  : assert(
          _typesEqual<T, String>() || _typesEqual<T, String?>() || stringToTypeConverter != null,
          'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
        ),
        _stringToTypeConverter = stringToTypeConverter ?? StringToTypeConverter(converter: (x, _) => x as T),
        super.pure();

  @override
  TextFormFieldGenericInput<T> asDirty(T? value) => TextFormFieldGenericInput.dirty(
        validator: validatorInstance,
        value: value,
        stringToTypeConverter: _stringToTypeConverter,
        translateError: translateError,
        inputName: inputName,
      );

  @override
  TextFormFieldGenericInput<T> asPure(T? value) => TextFormFieldGenericInput.pure(
        validator: validatorInstance,
        value: value,
        stringToTypeConverter: _stringToTypeConverter,
        translateError: translateError,
        inputName: inputName,
      );
}
