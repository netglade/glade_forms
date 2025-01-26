import 'package:glade_forms/glade_forms.dart';

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
  }) : super.internalCreate(
          stringToValueConverter: stringToValueConverter ?? GladeTypeConverters.boolConverter,
          validatorInstance: validator?.call(GladeValidator()) ?? GladeValidator<bool>().build(),
        );
}
