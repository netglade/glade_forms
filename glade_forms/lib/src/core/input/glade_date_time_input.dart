// ignore_for_file: prefer-single-declaration-per-file

import 'package:glade_forms/src/converters/converters.dart';
import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/validator/specialized/date_time_validator.dart';

/// A [GladeInput] for [DateTime] values.
///
/// This input is required by default.
///
/// Includes default conversion from string to [DateTime] using [GladeTypeConverters.dateTimeIso8601].
///
/// Includes default validator [DateTimeValidator] with [DateTimeValidator.notNull] rule if `isRequired` is true.
class GladeDateTimeInput extends GladeInput<DateTime> {
  GladeDateTimeInput({
    super.inputKey,
    super.value,
    super.initialValue,
    DateTimeValidatorFactory? validator,
    super.isPure,
    super.translateError,
    super.valueComparator,
    StringToTypeConverter<DateTime>? stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = false,
    super.valueTransform,
    super.defaultTranslations,
    super.trackUnchanged = true,
    bool isRequired = true,
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.dateTimeIso8601,
          validatorInstance: isRequired
              ? (validator?.call(DateTimeValidator()..notNull()) ?? (DateTimeValidator()..notNull()).build())
              : (validator?.call(DateTimeValidator()) ?? DateTimeValidator().build()),
        );
}

/// A [GladeInput] for [DateTime?] values.
///
/// This input is not required by default.
///
/// Includes default conversion from string to [DateTime] using [GladeTypeConverters.dateTimeIso8601Nullable].
///
/// Includes default validator [DateTimeValidatorNullable] with [DateTimeValidatorNullable.notNull] rule if `isRequired` is true.
class GladeDateTimeInputNullable extends GladeInput<DateTime?> {
  GladeDateTimeInputNullable({
    super.inputKey,
    super.value,
    super.initialValue,
    DateTimeValidatorFactoryNullable? validator,
    super.isPure,
    super.translateError,
    super.valueComparator,
    StringToTypeConverter<DateTime?>? stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = false,
    super.valueTransform,
    super.defaultTranslations,
    super.trackUnchanged = true,
    bool isRquired = false,
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.dateTimeIso8601Nullable,
          validatorInstance: isRquired
              ? (validator?.call(DateTimeValidatorNullable()..notNull()) ??
                  (DateTimeValidatorNullable()..notNull()).build())
              : (validator?.call(DateTimeValidatorNullable()) ?? DateTimeValidatorNullable().build()),
        );
}
