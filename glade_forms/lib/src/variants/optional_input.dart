import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/validator/generic_validator.dart';

/// Predefined GenericInput without any validations.
///
/// Useful for input which allows null value without additional validations.
///
/// In case of need of any validation use `GenericInput` directly.
class OptionalInput<T> extends GenericInput<T?> {
  OptionalInput.dirty({
    super.value,
    super.translateError,
    super.valueComparator,
    super.inputKey,
    super.initialValue,
  }) : super.dirty(validatorInstance: GenericValidator<T>().build());

  OptionalInput.pure({
    super.value,
    super.translateError,
    super.valueComparator,
    super.inputKey,
  }) : super.pure(validatorInstance: GenericValidator<T>().build());

  @override
  OptionalInput<T> asDirty(T? value) => OptionalInput.dirty(
        value: value,
        translateError: translateError,
        inputKey: inputKey,
        valueComparator: valueComparator,
        initialValue: initialValue,
      );

  @override
  OptionalInput<T> asPure(T? value) => OptionalInput.pure(
        value: value,
        translateError: translateError,
        inputKey: inputKey,
        valueComparator: valueComparator,
      );
}
