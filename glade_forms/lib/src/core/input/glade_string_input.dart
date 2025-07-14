import 'package:glade_forms/src/core/error/glade_error_keys.dart';
import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/validator/part/satisfy_predicate_part.dart';
import 'package:glade_forms/src/validator/specialized/string_validator.dart';

/// A string input.
///
/// This input is required by default.
///
/// Includes default validator [StringValidator] with [StringValidator.notEmpty] rule if `isRequired` is true.
///
/// Creates textEditingController by default.
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
              ? (validator?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build())
              : (validator?.call(StringValidator()) ?? StringValidator().build()),
        );

  /// Maximum length of the string if `maxLength()` standard validator is used.
  int? getMaxLength({Object? key}) {
    final validator = validatorInstance.tryFindValidatorPart(key ?? GladeErrorKeys.stringMaxLength);

    if (validator == null) return null;

    return validator is SatisfyPredicatePart ? (validator as SatisfyPredicatePart).metaData as int? : null;
  }
}
