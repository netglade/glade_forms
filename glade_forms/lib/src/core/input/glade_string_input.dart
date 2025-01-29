import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/validator/specialized/string_validator.dart';

class GladeStringInput extends GladeInput<String> {
  GladeStringInput({
    super.inputKey,
    String? value,
    String? initialValue,
    StringValidatorFactory? validator,
    super.isPure,
    super.translateError,
    super.valueComparator,
    super.stringToValueConverter,
    super.dependencies,
    super.onChange,
    super.onDependencyChange,
    super.textEditingController,
    super.useTextEditingController = true,
    super.valueTransform,
    super.defaultTranslations,
    super.trackUnchanged = true,
    bool isRequired = true,
  }) : super.internalCreate(
          value: value ?? initialValue ?? '',
          initialValue: initialValue ?? '',
          validatorInstance: isRequired
              ? (validator?.call(StringValidator()..notNull()) ?? (StringValidator()..notNull()).build())
              : (validator?.call(StringValidator()) ?? StringValidator().build()),
        );
}
