// ignore_for_file: prefer-single-declaration-per-file

import 'package:glade_forms/src/converters/converters.dart';
import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/validator/specialized/int_validator.dart';

/// A [GladeInput] for [int] values.
///
/// This input is required by default.
///
/// Includes default conversion from string to [int] using [GladeTypeConverters.intConverter].
///
/// Includes default validator [IntValidator] with [IntValidator.notNull] rule if `isRequired` is true.
class GladeIntInput extends GladeInput<int> {
  GladeIntInput({
    super.inputKey,
    super.value,
    super.initialValue,
    IntValidatorFactory? validator,
    super.isPure,
    super.validationTranslate,
    super.valueComparator,
    StringToTypeConverter<int>? stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = false,
    super.valueTransform,
    super.defaultValidationTranslations,
    super.trackUnchanged = true,
    bool isRequired = true,
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.intConverter,
          validatorInstance: isRequired
              ? (validator?.call(IntValidator()..notNull()) ?? (IntValidator()..notNull()).build())
              : (validator?.call(IntValidator()) ?? IntValidator().build()),
        );
}

/// A [GladeInput] for [int?] values.
///
/// This input is not required by default.
///
/// Includes default conversion from string to [int] using [GladeTypeConverters.intConverterNullable].
///
/// Includes default validator [IntValidatorNullable] with [IntValidatorNullable.notNull] rule if `isRequired` is true.
class GladeIntInputNullable extends GladeInput<int?> {
  GladeIntInputNullable({
    super.inputKey,
    super.value,
    super.initialValue,
    IntValidatorFactoryNullable? validator,
    super.isPure,
    super.validationTranslate,
    super.valueComparator,
    StringToTypeConverter<int?>? stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = false,
    super.valueTransform,
    super.defaultValidationTranslations,
    super.trackUnchanged = true,
    bool isRequired = false,
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.intConverterNullable,
          validatorInstance: isRequired
              ? (validator?.call(IntValidatorNullable()..notNull()) ?? (IntValidatorNullable()..notNull()).build())
              : (validator?.call(IntValidatorNullable()) ?? IntValidatorNullable().build()),
        );
}
