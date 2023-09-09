import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/forms/text_form_field_input_validator_mixin.dart';
import 'package:glade_forms/src/validator/generic_validator_instance.dart';
import 'package:glade_forms/src/validator/string_validator.dart';

class StringInput extends GenericInput<String> with TextFormFieldInputValidatorMixin<String> {
  factory StringInput.create(
    GenericValidatorInstance<String> Function(StringValidator validator) validatorFactory, {
    String? defaultValue,
    bool pure = true,
    TranslateError<String>? translateError,
    String? inputName,
  }) {
    final instance = validatorFactory(StringValidator());

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          );
  }

  StringInput.dirty({
    String? value,
    super.validatorInstance,
    super.translateError,
    super.initialValue,
    super.inputName,
    super.valueComparator,
  }) : super.dirty(value: value ?? '');

  /// String input which allows empty (and null) values without any additional validations.
  factory StringInput.optional({
    String? defaultValue,
    bool pure = true,
    TranslateError<String>? translateError,
    String? inputName,
  }) {
    final instance = StringValidator().build();

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          );
  }

  StringInput.pure({
    String? value,
    super.validatorInstance,
    super.translateError,
    super.inputName,
    super.valueComparator,
  }) : super.pure(value: value ?? '');

  /// String input with predefined `notEmpty` validation rule.
  factory StringInput.required({
    GenericValidatorInstance<String> Function(StringValidator validator)? validatorFactory,
    String? defaultValue,
    bool pure = true,
    TranslateError<String>? translateError,
    String? inputName,
  }) {
    final instance = validatorFactory?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build();

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          );
  }

  @override
  StringInput asDirty(String? value) => StringInput.dirty(
        validatorInstance: validatorInstance,
        value: value ?? '',
        translateError: translateError,
        initialValue: initialValue,
        inputName: inputName,
        valueComparator: valueComparator,
      );

  @override
  StringInput asPure(String? value) => StringInput.pure(
        validatorInstance: validatorInstance,
        value: value ?? '',
        translateError: translateError,
        inputName: inputName,
        valueComparator: valueComparator,
      );
}
