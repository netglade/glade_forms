// ignore_for_file: prefer-single-declaration-per-file

import 'package:glade_forms/src/converters/converters.dart';
import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/validator/specialized/int_validator.dart';

class GladeIntInput extends GladeInput<int> {
  GladeIntInput({
    super.inputKey,
    super.value,
    super.initialValue,
    IntValidatorFactory? validator,
    super.isPure,
    super.translateError,
    super.valueComparator,
    StringToTypeConverter<int>? stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = false,
    super.valueTransform,
    super.defaultTranslations,
    super.trackUnchanged = true,
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.intConverter,
          validatorInstance: validator?.call(IntValidator()) ?? IntValidator().build(),
        );
}

class GladeIntInputNullabe extends GladeInput<int?> {
  GladeIntInputNullabe({
    super.inputKey,
    super.value,
    super.initialValue,
    IntValidatorFactoryNullable? validator,
    super.isPure,
    super.translateError,
    super.valueComparator,
    StringToTypeConverter<int>? stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = false,
    super.valueTransform,
    super.defaultTranslations,
    super.trackUnchanged = true,
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.intConverterNullable,
          validatorInstance: validator?.call(IntValidatorNullable()) ?? IntValidatorNullable().build(),
        );
}
