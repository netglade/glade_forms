import 'package:glade_forms/src/generic_input.dart';
import 'package:glade_forms/src/validator/generic_validator.dart';

/// Predefined GenericInput with predefined `notNull` validation.
///
/// In case of need of any aditional validation use `GenericInput` directly.
class RequiredInput<T> extends GenericInput<T> {
  RequiredInput.dirty({
    super.value,
    super.translateError,
    super.comparator,
    super.inputName,
    super.initialValue,
  }) : super.dirty(validator: (GenericValidator<T>()..notNull()).build());

  RequiredInput.pure({
    super.value,
    super.translateError,
    super.comparator,
    super.inputName,
  }) : super.pure(validator: (GenericValidator<T>()..notNull()).build());

  @override
  RequiredInput<T> asDirty(T? value) => RequiredInput.dirty(
        value: value,
        translateError: translateError,
        inputName: inputName,
        comparator: comparator,
        initialValue: initial,
      );

  @override
  RequiredInput<T> asPure(T? value) => RequiredInput.pure(
        value: value,
        translateError: translateError,
        inputName: inputName,
        comparator: comparator,
      );
}
