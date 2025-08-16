import 'package:glade_forms/src/converters/glade_type_converters.dart';
import 'package:glade_forms/src/core/input/input.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/validator/validator.dart';

/// A [GladeInput] for [bool] values.
///
/// This class is a specialized [GladeInput] for [bool] values.
class GladeBoolInput extends GladeInput<bool> {
  GladeBoolInput({
    super.inputKey,
    super.value,
    super.initialValue,
    ValidatorFactory<bool>? validator,
    super.isPure,
    super.translateError,
    super.valueComparator,
    StringToTypeConverter<bool>? stringToValueConverter,
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
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.boolConverter,
          validatorInstance: isRequired
              ? (validator?.call(GladeValidator<bool>()..notNull()) ?? (GladeValidator<bool>()..notNull()).build())
              : (validator?.call(GladeValidator()) ?? GladeValidator<bool>().build()),
        );
}
