import 'package:glade_forms/src/forms.dart';
import 'package:meta/meta.dart';

typedef TranslateError<T> = String Function(
  GenericValidatorError<T> error,
  Object? localeKey,
  String defaultMessage,
);

typedef Comparator<T> = bool Function(T? initial, T? value);

class GenericInput<T> extends BaseInput<T?, ValidatorErrors<T>> with GenericInputValidator<T?, ValidatorErrors<T>> {
  @protected
  final Comparator<T>? comparator;

  /// Initial value - does not change after creating.
  final T? initial;

  /// Input's name - useful for debugging.
  final String? inputName;

  final TranslateError<T>? translateError;

  @protected
  final GenericValidatorInstance<T> validatorInstance;

  bool get isUnchanged => (comparator?.call(initial, value) ?? value) == initial;

  factory GenericInput.create(
    GenericValidatorInstance<T> Function(GenericValidator<T> validator) validatorFactory, {
    /// Sets current value of input.
    T? value,

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
            validator: validator,
            value: value,
            translateError: translateError,
            comparator: comparator,
            inputName: inputName,
          )
        : GenericInput.dirty(
            validator: validator,
            value: value,
            initialValue: initialValue,
            translateError: translateError,
            comparator: comparator,
            inputName: inputName,
          );
  }

  GenericInput.dirty({
    T? value,
    GenericValidatorInstance<T>? validator,
    this.translateError,
    T? initialValue,
    this.comparator,
    this.inputName,
  })  : validatorInstance = validator ?? GenericValidator<T>().build(),
        initial = initialValue,
        super.dirty(value) {
    validatorInstance.bindInput(this);
  }

  GenericInput.pure({
    T? value,
    GenericValidatorInstance<T>? validator,
    this.translateError,
    this.comparator,
    this.inputName,
  })  : validatorInstance = validator ?? GenericValidator<T>().build(),
        initial = value,
        super.pure(value) {
    validatorInstance.bindInput(this);
  }

  GenericInput<T> asDirty(T? value) => GenericInput.dirty(
        validator: validatorInstance,
        value: value,
        translateError: translateError,
        initialValue: initial,
        inputName: inputName,
        comparator: comparator,
      );

  GenericInput<T> asPure(T? value) => GenericInput.pure(
        validator: validatorInstance,
        value: value,
        translateError: translateError,
        inputName: inputName,
        comparator: comparator,
      );

  String errorFormatted({String delimiter = '|'}) => error?.errors.map((e) => e.toString()).join(delimiter) ?? '';

  @protected
  // ignore: avoid-dynamic, ok for now
  bool errorIsGenericInputError(dynamic error) => error is ValidatorErrors<T>;

  @override
  // ignore: avoid-dynamic, error can be anything
  String? translate({String delimiter = '.', dynamic customError}) {
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
      return errors.errors.map((e) => translateErrorTmp(e, e.localeKey, e.onErrorMessage)).join(delimiter);
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
}
