import 'package:collection/collection.dart';
import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:meta/meta.dart';

typedef InputDependencies = List<GenericInput<dynamic>>;

extension InputDependenciesFunctions on InputDependencies {
  GenericInput? byKey(String key) => firstWhereOrNull((x) => x.inputKey == key);
}

@immutable
class GenericInput<T> extends GladeInputBase<T> {
  @protected
  final GenericValidatorInstance<T> validatorInstance;

  final InputDependencies dependencies;

  GenericInput._({
    required super.value,
    required this.validatorInstance,
    super.isPure,
    super.initialValue,
    super.valueComparator,
    super.translateError,
    super.inputKey,
    this.dependencies = const [],
  }) {
    validatorInstance.bindInput(this);
  }

  GenericInput.dirty({
    required T value,
    T? initialValue,
    String? inputKey,
    TranslateError<T>? translateError,
    ValueComparator<T>? valueComparator,
    GenericValidatorInstance<T>? validatorInstance,
    InputDependencies dependencies = const [],
  }) : this._(
          value: value,
          validatorInstance: validatorInstance ?? GenericValidator<T>().build(),
          inputKey: inputKey,
          initialValue: initialValue,
          translateError: translateError,
          valueComparator: valueComparator,
          dependencies: dependencies,
          isPure: false,
        );

  GenericInput.pure({
    required T value,
    T? initialValue,
    String? inputKey,
    TranslateError<T>? translateError,
    ValueComparator<T>? valueComparator,
    GenericValidatorInstance<T>? validatorInstance,
    InputDependencies dependencies = const [],
  }) : this._(
          value: value,
          validatorInstance: validatorInstance ?? GenericValidator<T>().build(),
          inputKey: inputKey,
          initialValue: initialValue ?? value,
          translateError: translateError,
          valueComparator: valueComparator,
          dependencies: dependencies,
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
    ValueComparator<T>? comparator,
    String? inputKey,
    InputDependencies dependencies = const [],
  }) {
    final validator = validatorFactory(GenericValidator<T>());

    return pure
        ? GenericInput.pure(
            validatorInstance: validator,
            value: value,
            translateError: translateError,
            valueComparator: comparator,
            inputKey: inputKey,
            dependencies: dependencies,
          )
        : GenericInput.dirty(
            validatorInstance: validator,
            value: value,
            initialValue: initialValue,
            translateError: translateError,
            valueComparator: comparator,
            inputKey: inputKey,
            dependencies: dependencies,
          );
  }

  @override
  GenericInput<T> asDirty(T value) => GenericInput.dirty(
        validatorInstance: validatorInstance,
        value: value,
        translateError: translateError,
        initialValue: initialValue,
        inputKey: inputKey,
        valueComparator: valueComparator,
        dependencies: dependencies,
      );

  @override
  GenericInput<T> asPure(T value) => GenericInput.pure(
        validatorInstance: validatorInstance,
        value: value,
        translateError: translateError,
        initialValue: initialValue,
        inputKey: inputKey,
        valueComparator: valueComparator,
        dependencies: dependencies,
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
      return errors.errors
          .map((e) => translateErrorTmp(e, e.key, e.onErrorMessage, dependencies: dependencies))
          .join(delimiter);
    }

    return errors.errors.map((e) => e.toString()).join(delimiter);
  }

  ValidatorErrors<T>? validate() => validator(value);

  @override
  ValidatorErrors<T>? validator(T value) {
    final result = validatorInstance.validate(value);

    if (result.isValid) return null;

    return result;
  }

  String? formFieldValidator(T value, {String delimiter = '.'}) {
    final convertedError = validator(value);

    return convertedError != null ? translate(delimiter: delimiter, customError: convertedError) : null;
  }
}
