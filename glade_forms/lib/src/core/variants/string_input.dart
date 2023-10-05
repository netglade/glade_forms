import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/string_validator.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';

typedef StringValidatorFactory = ValidatorInstance<String?> Function(StringValidator validator);

class StringInput extends GladeInput<String?> {
  factory StringInput.create({
    required StringValidatorFactory validator,
    String? value,
    bool pure = true,
    ErrorTranslator<String?>? translateError,
    String? inputKey,
  }) {
    final instance = validator(StringValidator());

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: value,
            translateError: translateError,
            inputKey: inputKey,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: value,
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
  }) : super.dirty(value);

  /// String input which allows empty (and null) values without any additional validations.
  factory StringInput.optional({
    String? defaultValue,
    bool pure = true,
    ErrorTranslator<String?>? translateError,
    String? inputKey,
    InputDependenciesFactory? dependencies,
    DefaultTranslations? defaultTranslations,
  }) {
    final instance = StringValidator().build();

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue,
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue,
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
  }) : super.pure(value);

  /// String input with predefined `notEmpty` validation rule.
  factory StringInput.required({
    StringValidatorFactory? validatorFactory,
    String? defaultValue,
    bool pure = true,
    ErrorTranslator<String?>? translateError,
    String? inputKey,
    InputDependenciesFactory? dependencies,
    DefaultTranslations? defaultTranslations,
  }) {
    final instance = validatorFactory?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build();

    return pure
        ? StringInput.pure(
            validatorInstance: instance,
            value: defaultValue,
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          )
        : StringInput.dirty(
            validatorInstance: instance,
            value: defaultValue,
            translateError: translateError,
            inputKey: inputKey,
            dependencies: dependencies,
            defaultTranslations: defaultTranslations,
          );
  }

  @override
  StringInput asDirty(String? value) => StringInput.dirty(
        validatorInstance: validatorInstance,
        value: value,
        translateError: translateError,
        initialValue: initialValue,
        inputKey: inputKey,
        valueComparator: valueComparator,
        dependencies: dependenciesFactory,
        defaultTranslations: defaultTranslations,
      );

  @override
  StringInput asPure(String? value) => StringInput.pure(
        validatorInstance: validatorInstance,
        value: value,
        translateError: translateError,
        inputKey: inputKey,
        valueComparator: valueComparator,
        dependencies: dependenciesFactory,
        defaultTranslations: defaultTranslations,
      );
}
