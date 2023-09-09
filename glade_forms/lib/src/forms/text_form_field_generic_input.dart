import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/forms/text_form_field_input_validator_mixin.dart';
import 'package:glade_forms/src/validator/validator.dart';

bool _typesEqual<T1, T2>() => T1 == T2;

/// Same as generic input but with mixed-in [TextFormFieldInputValidatorMixin].
class TextFormFieldGenericInput<T> extends GenericInput<T?> with TextFormFieldInputValidatorMixin<T?> {
  final StringToTypeConverter<T> _stringToTypeConverter;

  @override
  StringToTypeConverter<T?> get converter => _stringToTypeConverter;

  factory TextFormFieldGenericInput.create(
    GenericValidatorInstance<T> Function(GenericValidator<T> validator) validatorFactory, {
    T? defaultValue,
    bool pure = true,
    StringToTypeConverter<T>? converter,
    TranslateError<T?>? translateError,
    String? inputKey,
  }) {
    final instance = validatorFactory(GenericValidator<T>());

    return pure
        ? TextFormFieldGenericInput.pure(
            validatorInstance: instance,
            value: defaultValue,
            stringToTypeConverter: converter,
            translateError: translateError,
            inputKey: inputKey,
          )
        : TextFormFieldGenericInput.dirty(
            validatorInstance: instance,
            value: defaultValue,
            stringToTypeConverter: converter,
            translateError: translateError,
            inputKey: inputKey,
          );
  }

  TextFormFieldGenericInput.dirty({
    super.value,
    super.validatorInstance,
    StringToTypeConverter<T>? stringToTypeConverter,
    super.translateError,
    super.inputKey,
  })  : assert(
          _typesEqual<T, String>() || _typesEqual<T, String?>() || stringToTypeConverter != null,
          'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
        ),
        _stringToTypeConverter = stringToTypeConverter ?? StringToTypeConverter<T>(converter: (x, _) => x as T),
        super.dirty();

  TextFormFieldGenericInput.pure({
    super.value,
    super.validatorInstance,
    StringToTypeConverter<T>? stringToTypeConverter,
    super.translateError,
    super.inputKey,
  })  : assert(
          _typesEqual<T, String>() || _typesEqual<T, String?>() || stringToTypeConverter != null,
          'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
        ),
        _stringToTypeConverter = stringToTypeConverter ?? StringToTypeConverter(converter: (x, _) => x as T),
        super.pure();

  @override
  TextFormFieldGenericInput<T> asDirty(T? value) => TextFormFieldGenericInput.dirty(
        validatorInstance: validatorInstance,
        value: value,
        stringToTypeConverter: _stringToTypeConverter,
        translateError: translateError,
        inputKey: inputKey,
      );

  @override
  TextFormFieldGenericInput<T> asPure(T? value) => TextFormFieldGenericInput.pure(
        validatorInstance: validatorInstance,
        value: value,
        stringToTypeConverter: _stringToTypeConverter,
        translateError: translateError,
        inputKey: inputKey,
      );
}
