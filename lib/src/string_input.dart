import 'package:glade_forms/src/generic_input.dart';
import 'package:glade_forms/src/text_form_field_input_validator.dart';
import 'package:glade_forms/src/validator/generic_validator_instance.dart';
import 'package:glade_forms/src/validator/string_validator.dart';

class StringInput extends GenericInput<String> with TextFormFieldInputValidator {
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
            validator: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          )
        : StringInput.dirty(
            validator: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          );
  }

  StringInput.dirty({
    String? value,
    super.validator,
    super.translateError,
    super.initialValue,
    super.inputName,
    super.comparator,
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
            validator: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          )
        : StringInput.dirty(
            validator: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          );
  }

  StringInput.pure({
    String? value,
    super.validator,
    super.translateError,
    super.inputName,
    super.comparator,
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
            validator: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          )
        : StringInput.dirty(
            validator: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputName: inputName,
          );
  }

  @override
  StringInput asDirty(String? value) => StringInput.dirty(
        validator: validatorInstance,
        value: value ?? '',
        translateError: translateError,
        initialValue: initial,
        inputName: inputName,
        comparator: comparator,
      );

  @override
  StringInput asPure(String? value) => StringInput.pure(
        validator: validatorInstance,
        value: value ?? '',
        translateError: translateError,
        inputName: inputName,
        comparator: comparator,
      );
}
