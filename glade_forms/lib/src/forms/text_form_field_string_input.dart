import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/forms/text_form_field_input_validator_mixin.dart';
import 'package:glade_forms/src/validator/generic_validator_instance.dart';
import 'package:glade_forms/src/validator/string_validator.dart';

/// Same as string input but with mixed-in [TextFormFieldInputValidatorMixin].
class TextFormFieldStringInput extends GenericInput<String?> with TextFormFieldInputValidatorMixin<String?> {
  final StringToTypeConverter<String> _stringToTypeConverter;

  @override
  StringToTypeConverter<String?> get converter => _stringToTypeConverter;

  factory TextFormFieldStringInput.create(
    GenericValidatorInstance<String> Function(StringValidator validator) validatorFactory, {
    String? defaultValue,
    bool pure = true,
    TranslateError<String?>? translateError,
    String? inputName,
  }) {
    final instance = validatorFactory(StringValidator());

    return pure
        ? TextFormFieldStringInput.pure(
            validatorInstance: instance,
            value: defaultValue,
            translateError: translateError,
            inputName: inputName,
          )
        : TextFormFieldStringInput.dirty(
            validatorInstance: instance,
            value: defaultValue,
            translateError: translateError,
            inputName: inputName,
          );
  }

  TextFormFieldStringInput.dirty({
    super.value,
    super.validatorInstance,
    super.translateError,
    super.inputName,
    super.valueComparator,
  })  : _stringToTypeConverter = StringToTypeConverter(converter: (x, _) => x ?? ''),
        super.dirty();

  TextFormFieldStringInput.pure({
    super.value,
    super.validatorInstance,
    super.translateError,
    super.inputName,
    super.valueComparator,
  })  : _stringToTypeConverter = StringToTypeConverter(converter: (x, _) => x ?? ''),
        super.pure();

  @override
  TextFormFieldStringInput asDirty(String? value) => TextFormFieldStringInput.dirty(
        value: value,
        validatorInstance: validatorInstance,
        translateError: translateError,
        inputName: inputName,
        valueComparator: valueComparator,
      );

  @override
  TextFormFieldStringInput asPure(String? value) => TextFormFieldStringInput.pure(
        value: value,
        validatorInstance: validatorInstance,
        translateError: translateError,
        inputName: inputName,
        valueComparator: valueComparator,
      );
}
