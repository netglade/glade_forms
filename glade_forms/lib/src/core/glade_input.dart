import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/converters/glade_type_converters.dart';
import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/error_translator.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/core/type_helper.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

typedef ValueComparator<T> = bool Function(T? initial, T? value);
typedef ValidatorFactory<T> = ValidatorInstance<T> Function(GladeValidator<T> v);

class GladeInput<T> extends ChangeNotifier {
  /// Compares initial and current value.
  @protected
  final ValueComparator<T>? valueComparator;

  @protected
  final ValidatorInstance<T> validatorInstance;

  @protected
  final StringToTypeConverter<T>? stringTovalueConverter;

  final InputDependenciesFactory dependenciesFactory;

  /// An input's identification.
  final String? inputKey;

  /// Initial value - does not change after creating.
  final T? initialValue;

  final ErrorTranslator<T>? translateError;

  /// Validation message for conversion error.
  final DefaultTranslations? defaultTranslations;

  final StringToTypeConverter<T> _defaultConverter = StringToTypeConverter<T>(converter: (x, _) => x as T);

  /// Current input's value.
  T _value;

  /// Input did not updated its value from initialValue.
  bool _isPure;

  /// Input is in invalid state when there was conversion error.
  bool _conversionError = false;

  T get value => _value;

  /// Input's value was not changed.
  bool get isPure => _isPure;

  ValidatorResult<T>? get validatorError => _validator(value);

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  bool get isUnchanged => (valueComparator?.call(initialValue, value) ?? value) == initialValue;

  /// Input does not have conversion error nor validation error.
  bool get isValid => !_conversionError && _validator(value) == null;

  bool get isNotValid => !isValid;

  bool get hasConversionError => _conversionError;

  /// String representattion of [value].
  String get stringValue => stringTovalueConverter?.convertBack(value) ?? value.toString();

  // ignore: no_runtimetype_tostring, in this case it is ok - only for dev purposes
  String get inputName => inputKey ?? '$runtimeType($value)';

  set value(T value) {
    _value = value;

    _isPure = false;
    _conversionError = false;

    notifyListeners();
  }

  GladeInput({
    required T value,
    required this.validatorInstance,
    required bool isPure,
    required this.initialValue,
    required this.valueComparator,
    required this.inputKey,
    required this.translateError,
    required this.stringTovalueConverter,
    required this.dependenciesFactory,
    required this.defaultTranslations,
  })  : _isPure = isPure,
        _value = value {
    validatorInstance.bindInput(this);
  }

  GladeInput.pure(
    T value, {
    T? initialValue,
    String? inputKey,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    ValidatorInstance<T>? validatorInstance,
    InputDependenciesFactory? dependencies,
    ErrorTranslator<T>? translateError,
    DefaultTranslations? defaultTranslations,
  }) : this(
          value: value,
          isPure: true,
          inputKey: inputKey,
          initialValue: initialValue ?? value,
          valueComparator: valueComparator,
          stringTovalueConverter: valueConverter,
          dependenciesFactory: dependencies ?? () => [],
          validatorInstance: validatorInstance ?? GladeValidator<T>().build(),
          translateError: translateError,
          defaultTranslations: defaultTranslations,
        );

  GladeInput.dirty(
    T value, {
    T? initialValue,
    String? inputKey,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    ValidatorInstance<T>? validatorInstance,
    InputDependenciesFactory? dependencies,
    ErrorTranslator<T>? translateError,
    DefaultTranslations? defaultTranslations,
  }) : this(
          value: value,
          isPure: false,
          inputKey: inputKey,
          initialValue: initialValue,
          valueComparator: valueComparator,
          stringTovalueConverter: valueConverter,
          dependenciesFactory: dependencies ?? () => [],
          validatorInstance: validatorInstance ?? GladeValidator<T>().build(),
          translateError: translateError,
          defaultTranslations: defaultTranslations,
        );

  factory GladeInput.create({
    /// Sets current value of input.
    required T value,
    ValidatorFactory<T>? validator,

    /// Initial value when GenericInput is created.
    ///
    /// This value can potentially differ from value. Used for computing `isUnchanged`.
    T? initialValue,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? comparator,
    String? inputKey,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
  }) {
    final validatorInstance = validator?.call(GladeValidator<T>()) ?? GladeValidator<T>().build();

    return pure
        ? GladeInput.pure(
            value,
            validatorInstance: validatorInstance,
            initialValue: initialValue ?? value,
            translateError: translateError,
            valueComparator: comparator,
            inputKey: inputKey,
            valueConverter: valueConverter,
            dependencies: dependencies,
          )
        : GladeInput.dirty(
            value,
            validatorInstance: validatorInstance,
            initialValue: initialValue,
            translateError: translateError,
            valueComparator: comparator,
            inputKey: inputKey,
            valueConverter: valueConverter,
            dependencies: dependencies,
          );
  }

  // Predefined GenericInput without any validations.
  ///
  /// Useful for input which allows null value without additional validations.
  ///
  /// In case of need of any validation use [GladeInput.create] directly.
  factory GladeInput.optional({
    required T value,
    T? initialValue,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? comparator,
    String? inputKey,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
  }) =>
      GladeInput.create(
        validator: (v) => v.build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        comparator: comparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
      );

  /// Predefined GenericInput with predefined `notNull` validation.
  ///
  /// In case of need of any aditional validation use [GladeInput.create] directly.
  factory GladeInput.required({
    required T value,
    T? initialValue,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? comparator,
    String? inputKey,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
  }) =>
      GladeInput.create(
        validator: (v) => (v..notNull()).build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        comparator: comparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
      );

  static GladeInput<int> intInput({
    required int value,
    ValidatorFactory<int>? validator,
    int? initialValue,
    bool pure = true,
    ErrorTranslator<int>? translateError,
    ValueComparator<int>? comparator,
    String? inputKey,
    InputDependenciesFactory? dependencies,
  }) =>
      GladeInput.create(
        value: value,
        initialValue: initialValue,
        validator: validator,
        pure: pure,
        translateError: translateError,
        comparator: comparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.intConverter,
      );

  static GladeInput<bool> boolInput({
    required bool value,
    ValidatorFactory<bool>? validator,
    bool? initialValue,
    bool pure = true,
    ErrorTranslator<bool>? translateError,
    ValueComparator<bool>? comparator,
    String? inputKey,
    InputDependenciesFactory? dependencies,
  }) =>
      GladeInput.create(
        value: value,
        initialValue: initialValue,
        validator: validator,
        pure: pure,
        translateError: translateError,
        comparator: comparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.boolConverter,
      );

  GladeInput<T> asDirty(T value) => copyWith(isPure: false, value: value);

  GladeInput<T> asPure(T value) => copyWith(isPure: true, value: value);

  ValidatorResult<T>? validate() => _validator(value);

  String? translate({String delimiter = '.'}) => _translate(delimiter: delimiter, customError: validatorError);

  String errorFormatted({String delimiter = '|'}) =>
      validatorError?.errors.map((e) => e.toString()).join(delimiter) ?? '';

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  /// If there are multiple errors they are concenated into one string with [delimiter].
  String? textFormFieldInputValidatorCustom(String? value, {String delimiter = '.'}) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: $T',
    );
    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(value);
      final convertedError = _validator(convertedValue);

      return convertedError != null ? _translate(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (formatError) {
      return formatError.error != null
          ? _translate(delimiter: delimiter, customError: formatError)
          : formatError.devError(value, extra: validatorError);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  String? textFormFieldInputValidator(String? value) => textFormFieldInputValidatorCustom(value);

  /// Shorthand validator for Form field input.
  ///
  /// Returns translated validation message.
  String? formFieldValidator(T value) {
    final convertedError = _validator(value);

    return convertedError != null ? _translate(customError: convertedError) : null;
  }

  void updateValueWithString(String? strValue) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );

    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      this.value = converter.convert(strValue);
    } on ConvertError<T> {
      _conversionError = true;
    }
  }

  @protected
  GladeInput<T> copyWith({
    ValueComparator<T>? valueComparator,
    ValidatorInstance<T>? validatorInstance,
    StringToTypeConverter<T>? stringTovalueConverter,
    InputDependenciesFactory? dependenciesFactory,
    String? inputKey,
    T? initialValue,
    ErrorTranslator<T>? translateError,
    T? value,
    bool? isPure,
    DefaultTranslations? defaultTranslations,
  }) {
    return GladeInput<T>(
      value: value ?? this.value,
      valueComparator: valueComparator ?? this.valueComparator,
      validatorInstance: validatorInstance ?? this.validatorInstance,
      stringTovalueConverter: stringTovalueConverter ?? this.stringTovalueConverter,
      dependenciesFactory: dependenciesFactory ?? this.dependenciesFactory,
      inputKey: inputKey ?? this.inputKey,
      initialValue: initialValue ?? this.initialValue,
      translateError: translateError ?? this.translateError,
      isPure: isPure ?? this.isPure,
      defaultTranslations: defaultTranslations ?? this.defaultTranslations,
    );
  }

  /// Translates input's errors (validation or conversion).
  String? _translate({String delimiter = '.', Object? customError}) {
    final err = customError ?? validatorError;

    if (err == null) return null;

    if (err is ValidatorResult<T>) {
      return _translateGenericErrors(err, delimiter);
    }

    if (err is ConvertError<T>) {
      final defaultTranslationsTmp = this.defaultTranslations;
      final translateErrorTmp = translateError;
      if (translateErrorTmp != null) {
        return translateErrorTmp(err, err.key, err.devErrorMessage, dependenciesFactory());
      } else if (defaultTranslationsTmp != null && defaultTranslationsTmp.defaultConversionMessage != null) {
        return defaultTranslationsTmp.defaultConversionMessage;
      }
    }

    //ignore: avoid-dynamic, ok for now
    if (err is List<dynamic>) {
      return err.map((x) => x.toString()).join('.');
    }

    return err.toString();
  }

  ValidatorResult<T>? _validator(T value) {
    final result = validatorInstance.validate(value);

    if (result.isValid) return null;

    return result;
  }

  String _translateGenericErrors(ValidatorResult<T> inputErrors, String delimiter) {
    final translateErrorTmp = translateError;

    final defaultTranslationsTmp = this.defaultTranslations;
    if (translateErrorTmp != null) {
      return inputErrors.errors
          .map((e) => translateErrorTmp(e, e.key, e.devErrorMessage, dependenciesFactory()))
          .join(delimiter);
    }

    return inputErrors.errors.map((e) {
      if (defaultTranslationsTmp != null && (e.isNullError || e.hasStringEmptyOrNullErrorKey)) {
        return defaultTranslationsTmp.defaultValueIsNullOrEmptyMessage ?? e.toString();
      }

      return e.toString();
    }).join(delimiter);
  }
}
