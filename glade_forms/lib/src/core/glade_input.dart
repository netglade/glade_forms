import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/error_translator.dart';
import 'package:glade_forms/src/core/glade_model.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/core/type_helper.dart';
import 'package:glade_forms/src/validator/validator.dart';

typedef ValueComparator<T> = bool Function(T? initial, T? value);

class GladeInput<T> extends ChangeNotifier {
  final GladeModel? bindContext;

  @protected
  final ValueComparator<T>? valueComparator;

  @protected
  final GenericValidatorInstance<T> validatorInstance;

  @protected
  final StringToTypeConverter<T>? stringTovalueConverter;

  final InputDependenciesFactory dependencies;

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

  bool get isPure => _isPure;

  // @override
  // int get hashCode => Object.hashAll([value, _isPure]);

  ValidatorErrors<T>? get error => _validator(value);

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  bool get isUnchanged => (valueComparator?.call(initialValue, value) ?? value) == initialValue;

  bool get isValid => !_conversionError && _validator(value) == null;

  bool get isNotValid => !isValid;

  bool get hasConversionError => _conversionError;

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
    required this.bindContext,
    required this.stringTovalueConverter,
    required this.dependencies,
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
    GladeModel? bindContext,
    StringToTypeConverter<T>? valueConverter,
    GenericValidatorInstance<T>? validatorInstance,
    InputDependenciesFactory? dependencies,
    ErrorTranslator<T>? translateError,
    DefaultTranslations? defaultTranslations,
  }) : this(
          value: value,
          isPure: true,
          inputKey: inputKey,
          initialValue: initialValue ?? value,
          valueComparator: valueComparator,
          bindContext: bindContext,
          stringTovalueConverter: valueConverter,
          dependencies: dependencies ?? () => [],
          validatorInstance: validatorInstance ?? GenericValidator<T>().build(),
          translateError: translateError,
          defaultTranslations: defaultTranslations,
        );

  GladeInput.dirty(
    T value, {
    T? initialValue,
    String? inputKey,
    ValueComparator<T>? valueComparator,
    GladeModel? bindContext,
    StringToTypeConverter<T>? valueConverter,
    GenericValidatorInstance<T>? validatorInstance,
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
          bindContext: bindContext,
          dependencies: dependencies ?? () => [],
          validatorInstance: validatorInstance ?? GenericValidator<T>().build(),
          translateError: translateError,
          defaultTranslations: defaultTranslations,
        );

  factory GladeInput.create(
    GenericValidatorInstance<T> Function(GenericValidator<T> v) validatorFactory, {
    /// Sets current value of input.
    required T value,

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
    final validator = validatorFactory(GenericValidator<T>());

    return pure
        ? GladeInput.pure(
            value,
            validatorInstance: validator,
            initialValue: initialValue ?? value,
            translateError: translateError,
            valueComparator: comparator,
            inputKey: inputKey,
            valueConverter: valueConverter,
            dependencies: dependencies,
          )
        : GladeInput.dirty(
            value,
            validatorInstance: validator,
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
        (v) => v.build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        comparator: comparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
      );

  // Predefined GenericInput with predefined `notNull` validation.
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
        (v) => (v..notNull()).build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        comparator: comparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
      );

  GladeInput<T> asDirty(T value) => copyWith(isPure: false, value: value);

  GladeInput<T> asPure(T value) => copyWith(isPure: true, value: value);

  ValidatorErrors<T>? validate() => _validator(value);

  // TODO(petr): Consider to pass BuildContext. This would allow use context based translation.
  String? translate({String delimiter = '.', Object? customError}) {
    final err = customError ?? error;

    if (err == null) return null;

    if (err is ValidatorErrors<T>) {
      return _translateGenericErrors(err, delimiter);
    }

    if (err is ConvertError<T>) {
      final defaultTranslationsTmp = this.defaultTranslations;
      final translateErrorTmp = translateError;
      if (translateErrorTmp != null) {
        return translateErrorTmp(err, err.key, err.devErrorMessage, dependencies: dependencies);
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

  String errorFormatted({String delimiter = '|'}) => error?.errors.map((e) => e.toString()).join(delimiter) ?? '';

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message. Translated message is returned through [translate].
  /// If there are multiple errors they are concenated into one string with [delimiter].
  String? formFieldInputValidatorCustom(String? value, {String delimiter = '.'}) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );
    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(value);
      final convertedError = _validator(convertedValue);

      return convertedError != null ? translate(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (formatError) {
      return formatError.error != null
          ? translate(delimiter: delimiter, customError: formatError)
          : formatError.devError(value, extra: error);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message. Translated message is returned through [translate].
  String? formFieldInputValidator(String? value) => formFieldInputValidatorCustom(value);

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

  // @override
  // bool operator ==(Object other) {
  //   if (other.runtimeType != runtimeType) return false;

  //   return other is GladeInputBase<T> && other.value == value && other._isPure == _isPure;
  // }

  @protected
  GladeInput<T> copyWith({
    GladeModel? bindContext,
    ValueComparator<T>? valueComparator,
    GenericValidatorInstance<T>? validatorInstance,
    StringToTypeConverter<T>? stringTovalueConverter,
    InputDependenciesFactory? dependencies,
    String? inputKey,
    T? initialValue,
    ErrorTranslator<T>? translateError,
    T? value,
    bool? isPure,
    DefaultTranslations? defaultTranslations,
  }) {
    return GladeInput<T>(
      value: value ?? this.value,
      bindContext: bindContext ?? this.bindContext,
      valueComparator: valueComparator ?? this.valueComparator,
      validatorInstance: validatorInstance ?? this.validatorInstance,
      stringTovalueConverter: stringTovalueConverter ?? this.stringTovalueConverter,
      dependencies: dependencies ?? this.dependencies,
      inputKey: inputKey ?? this.inputKey,
      initialValue: initialValue ?? this.initialValue,
      translateError: translateError ?? this.translateError,
      isPure: isPure ?? this.isPure,
      defaultTranslations: defaultTranslations ?? this.defaultTranslations,
    );
  }

  ValidatorErrors<T>? _validator(T value) {
    final result = validatorInstance.validate(value);

    if (result.isValid) return null;

    return result;
  }

  String _translateGenericErrors(ValidatorErrors<T> inputErrors, String delimiter) {
    final translateErrorTmp = translateError;

    final defaultTranslationsTmp = this.defaultTranslations;
    if (translateErrorTmp != null) {
      return inputErrors.errors
          .map((e) => translateErrorTmp(e, e.key, e.devErrorMessage, dependencies: dependencies))
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
