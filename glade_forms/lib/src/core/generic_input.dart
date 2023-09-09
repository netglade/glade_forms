import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:meta/meta.dart';

typedef TranslateError<T> = String Function(
  GenericValidatorError<T> error,
  Object? key,
  String defaultMessage,
);

typedef Comparator<T> = bool Function(T? initial, T? value);

@immutable
class GenericInput<T> extends GladeInputBase<T> {
  @override
  @protected
  final GenericValidatorInstance<T> validatorInstance;

  GenericInput._({
    required super.value,
    required this.validatorInstance,
    super.isPure,
    super.initialValue,
    super.valueComparator,
    super.translateError,
    super.inputName,
  }) {
    validatorInstance.bindInput(this);
  }

  GenericInput.dirty({
    required T value,
    T? initialValue,
    String? inputName,
    TranslateError<T>? translateError,
    Comparator<T>? valueComparator,
    GenericValidatorInstance<T>? validatorInstance,
  }) : this._(
          value: value,
          validatorInstance: validatorInstance ?? GenericValidator<T>().build(),
          inputName: inputName,
          initialValue: initialValue,
          translateError: translateError,
          valueComparator: valueComparator,
          isPure: false,
        );

  GenericInput.pure({
    required T value,
    T? initialValue,
    String? inputName,
    TranslateError<T>? translateError,
    Comparator<T>? valueComparator,
    GenericValidatorInstance<T>? validatorInstance,
  }) : this._(
          value: value,
          validatorInstance: validatorInstance ?? GenericValidator<T>().build(),
          inputName: inputName,
          initialValue: initialValue ?? value,
          translateError: translateError,
          valueComparator: valueComparator,
          isPure: true,
        );

  factory GenericInput.create(
    GenericValidatorInstance<T> Function(GenericValidator<T> validator) validatorFactory, {
    /// Sets current value of input.
    required T value,

    /// Initial value when GenericInput is created.
    ///
    /// This value can potentially differ from value. Used for computing `isUnchanged`.
    T? initialValue,
    bool pure = true,
    TranslateError<T>? translateError,
    Comparator<T>? comparator,
    String? inputName,
  }) {
    final validator = validatorFactory(GenericValidator<T>());

    return pure
        ? GenericInput.pure(
            validatorInstance: validator,
            value: value,
            translateError: translateError,
            valueComparator: comparator,
            inputName: inputName,
          )
        : GenericInput.dirty(
            validatorInstance: validator,
            value: value,
            initialValue: initialValue,
            translateError: translateError,
            valueComparator: comparator,
            inputName: inputName,
          );
  }

  @override
  GenericInput<T> asDirty(T value) => GenericInput.dirty(
        validatorInstance: validatorInstance,
        value: value,
        translateError: translateError,
        initialValue: initialValue,
        inputName: inputName,
        valueComparator: valueComparator,
      );

  @override
  GenericInput<T> asPure(T value) => GenericInput.pure(
        validatorInstance: validatorInstance,
        value: value,
        translateError: translateError,
        initialValue: initialValue,
        inputName: inputName,
        valueComparator: valueComparator,
      );

  @override
  String errorFormatted({String delimiter = '|'}) => error?.errors.map((e) => e.toString()).join(delimiter) ?? '';

  @protected
  // ignore: avoid-dynamic, ok for now
  bool errorIsGenericInputError(dynamic error) => error is ValidatorErrors<T>;

  @override
  String? translate({String delimiter = '.', Object? customError}) {
    final err = customError ?? error;

    if (err == null) return null;

    if (errorIsGenericInputError(err)) {
      return translateGenericErrors(err as ValidatorErrors<T>, delimiter);
    }

    //ignore: avoid-dynamic, ok for now
    if (err is List<dynamic>) {
      return err.map((x) => x.toString()).join('.');
    }

    return err.toString();
  }

  @protected
  String translateGenericErrors(ValidatorErrors<T> errors, String delimiter) {
    final translateErrorTmp = translateError;
    if (translateErrorTmp != null) {
      return errors.errors.map((e) => translateErrorTmp(e, e.key, e.onErrorMessage)).join(delimiter);
    }

    return errors.errors.map((e) => e.toString()).join(delimiter);
  }

  ValidatorErrors<T>? validate() => validator(value);

  @override
  ValidatorErrors<T>? validator(T? value) {
    final result = validatorInstance.validate(value);

    if (result.isValid) return null;

    return result;
  }

  String? formFieldValidator(T? value, {String delimiter = '.'}) {
    final convertedError = validator(value);

    return convertedError != null ? translate(delimiter: delimiter, customError: convertedError) : null;
  }
}
