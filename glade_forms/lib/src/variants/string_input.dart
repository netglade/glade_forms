import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/generic_validator_instance.dart';
import 'package:glade_forms/src/validator/string_validator.dart';

class StringInput extends GladeInput<String> {
  factory StringInput.create(
    GenericValidatorInstance<String> Function(StringValidator validator) validatorFactory, {
    String? defaultValue,
    bool pure = true,
    ErrorTranslator<String>? translateError,
    String? inputKey,
  }) {
    final instance = validatorFactory(StringValidator());

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputKey: inputKey,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputKey: inputKey,
          );
  }

  StringInput.dirty({
    String? value,
    super.validatorInstance,
    super.translateError,
    super.initialValue,
    super.inputKey,
    super.valueComparator,
    super.dependencies,
    super.defaultTranslations,
  }) : super.dirty(value ?? '');

  /// String input which allows empty (and null) values without any additional validations.
  factory StringInput.optional({
    String? defaultValue,
    bool pure = true,
    ErrorTranslator<String>? translateError,
    String? inputKey,
    InputDependenciesFactory? dependencies,
    DefaultTranslations? defaultTranslations,
  }) {
    final instance = StringValidator().build();

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          );
  }

  StringInput.pure({
    String? value,
    super.validatorInstance,
    super.translateError,
    super.inputKey,
    super.valueComparator,
    super.dependencies,
    super.initialValue,
    super.defaultTranslations,
  }) : super.pure(value ?? '');

  /// String input with predefined `notEmpty` validation rule.
  factory StringInput.required({
    GenericValidatorInstance<String> Function(StringValidator validator)? validatorFactory,
    String? defaultValue,
    bool pure = true,
    ErrorTranslator<String>? translateError,
    String? inputKey,
    InputDependenciesFactory? dependencies,
    DefaultTranslations? defaultTranslations,
  }) {
    final instance = validatorFactory?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build();

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue ?? '',
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          );
  }

  @override
  StringInput asDirty(String? value) => StringInput.dirty(
        validatorInstance: validatorInstance,
        value: value ?? '',
        translateError: translateError,
        initialValue: initialValue,
        inputKey: inputKey,
        valueComparator: valueComparator,
        dependencies: dependencies,
        defaultTranslations: defaultTranslations,
      );

  @override
  StringInput asPure(String? value) => StringInput.pure(
        validatorInstance: validatorInstance,
        value: value ?? '',
        translateError: translateError,
        inputKey: inputKey,
        valueComparator: valueComparator,
        dependencies: dependencies,
        defaultTranslations: defaultTranslations,
      );
}
