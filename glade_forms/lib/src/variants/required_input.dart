import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/validator/generic_validator.dart';

/// Predefined GenericInput with predefined `notNull` validation.
///
/// In case of need of any aditional validation use `GenericInput` directly.
class RequiredInput<T> extends GenericInput<T> {
  RequiredInput.dirty({
    required super.value,
    super.translateError,
    super.valueComparator,
    super.inputName,
    super.initialValue,
  }) : super.dirty(validatorInstance: (GenericValidator<T>()..notNull()).build());

  RequiredInput.pure({
    required super.value,
    super.translateError,
    super.valueComparator,
    super.inputName,
  }) : super.pure(validatorInstance: (GenericValidator<T>()..notNull()).build());

  @override
  RequiredInput<T> asDirty(T value) => RequiredInput.dirty(
        value: value,
        translateError: translateError,
        inputName: inputName,
        valueComparator: valueComparator,
        initialValue: initialValue,
      );

  @override
  RequiredInput<T> asPure(T value) => RequiredInput.pure(
        value: value,
        translateError: translateError,
        inputName: inputName,
        valueComparator: valueComparator,
      );
}
