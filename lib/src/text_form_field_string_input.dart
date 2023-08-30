import 'package:glade_forms/src/generic_input.dart';
import 'package:glade_forms/src/string_to_type_converter.dart';
import 'package:glade_forms/src/text_form_field_input_validator.dart';
import 'package:glade_forms/src/validator/generic_validator_instance.dart';
import 'package:glade_forms/src/validator/string_validator.dart';
import 'package:glade_forms/src/validator/validator_errors.dart';

/// Same as string input but with mixed-in [TextFormFieldInputValidator].
class TextFormFieldStringInput extends GenericInput<String>
    with TextFormFieldInputValidator<String?, ValidatorErrors<String>> {
  final StringToTypeConverter<String> _stringToTypeConverter;

  @override
  StringToTypeConverter<String?> get converter => _stringToTypeConverter;

  factory TextFormFieldStringInput.create(
    GenericValidatorInstance<String> Function(StringValidator validator) validatorFactory, {
    String? defaultValue,
    bool pure = true,
    TranslateError<String>? translateError,
    String? inputName,
  }) {
    final instance = validatorFactory(StringValidator());

    return pure
        ? TextFormFieldStringInput.pure(
            validator: instance,
            value: defaultValue,
            translateError: translateError,
            inputName: inputName,
          )
        : TextFormFieldStringInput.dirty(
            validator: instance,
            value: defaultValue,
            translateError: translateError,
            inputName: inputName,
          );
  }

  TextFormFieldStringInput.dirty({
    super.value,
    super.validator,
    super.translateError,
    super.inputName,
    super.comparator,
  })  : _stringToTypeConverter = StringToTypeConverter(converter: (x, _) => x ?? ''),
        super.dirty();

  TextFormFieldStringInput.pure({
    super.value,
    super.validator,
    super.translateError,
    super.inputName,
    super.comparator,
  })  : _stringToTypeConverter = StringToTypeConverter(converter: (x, _) => x ?? ''),
        super.pure();

  @override
  TextFormFieldStringInput asDirty(String? value) => TextFormFieldStringInput.dirty(
        validator: validatorInstance,
        value: value,
        translateError: translateError,
        inputName: inputName,
      );

  @override
  TextFormFieldStringInput asPure(String? value) => TextFormFieldStringInput.pure(
        validator: validatorInstance,
        value: value,
        translateError: translateError,
        inputName: inputName,
      );
}
