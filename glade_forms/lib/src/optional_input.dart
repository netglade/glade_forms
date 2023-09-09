import 'package:glade_forms/src/generic_input.dart';
import 'package:glade_forms/src/validator/generic_validator.dart';

/// Predefined GenericInput without any validations.
///
/// Useful for input which allows null value without additional validations.
///
/// In case of need of any validation use `GenericInput` directly.
class OptionalInput<T> extends GenericInput<T> {
  OptionalInput.dirty({
    super.value,
    super.translateError,
    super.comparator,
    super.inputName,
    super.initialValue,
  }) : super.dirty(validator: GenericValidator<T>().build());

  OptionalInput.pure({
    super.value,
    super.translateError,
    super.comparator,
    super.inputName,
  }) : super.pure(validator: GenericValidator<T>().build());

  @override
  OptionalInput<T> asDirty(T? value) => OptionalInput.dirty(
        value: value,
        translateError: translateError,
        inputName: inputName,
        comparator: comparator,
        initialValue: initial,
      );

  @override
  OptionalInput<T> asPure(T? value) => OptionalInput.pure(
        value: value,
        translateError: translateError,
        inputName: inputName,
        comparator: comparator,
      );
}
