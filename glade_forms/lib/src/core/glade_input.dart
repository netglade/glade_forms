import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/converters/glade_type_converters.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/error_translator.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/core/type_helper.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

typedef ValueComparator<T> = bool Function(T? initial, T? value);
typedef ValidatorFactory<T> = ValidatorInstance<T> Function(GladeValidator<T> v);
typedef StringValidatorFactory = ValidatorInstance<String> Function(StringValidator validator);
typedef OnChange<T> = void Function(ChangesInfo<T> info, InputDependencies dependencies);
typedef ValueTransform<T> = T Function(T input);

typedef StringInput = GladeInput<String>;

T _defaultTransform<T>(T input) => input;
Type _typeOf<T>() => T;

class GladeInput<T> extends ChangeNotifier {
  /// Compares initial and current value.
  @protected
  // ignore: prefer-correct-callback-field-name, ok name
  final ValueComparator<T>? valueComparator;

  @protected
  final ValidatorInstance<T> validatorInstance;

  @protected
  final StringToTypeConverter<T>? stringTovalueConverter;

  // ignore: prefer-correct-callback-field-name, ok name
  final InputDependenciesFactory dependenciesFactory;

  /// An input's identification.
  ///
  /// Used within listener changes and dependency related funcions such as validation.
  final String inputKey;

  // ignore: prefer-correct-callback-field-name, ok name
  final ErrorTranslator<T>? translateError;

  /// Validation message for conversion error.
  final DefaultTranslations? defaultTranslations;

  /// Called when input's value changed.
  OnChange<T>? onChange;

  /// Determines whether this input will be considered in isUnchanged on model.
  ///
  /// That means, when the value is false, it will opt-out this input from the computation.
  bool trackUnchanged;

  /// Transforms passed value before assigning it into input.
  // ignore: prefer-correct-callback-field-name, ok name
  ValueTransform<T> valueTransform;

  /// Initial value - does not change after creating.
  T? _initialValue;

  TextEditingController? _textEditingController;

  final StringToTypeConverter<T> _defaultConverter = StringToTypeConverter<T>(converter: (x, _) => x as T);

  /// Current input's value.
  T _value;

  /// Previous inputs'value.
  T? _previousValue;

  /// Input did not updated its value from initialValue.
  bool _isPure;

  /// Input is in invalid state when there was conversion error.
  ConvertError<T>? __conversionError;

  GladeModel? _bindedModel;

  T? get initialValue => _initialValue;

  TextEditingController? get controller => _textEditingController;

  T get value => _value;

  T? get previousValue => _previousValue;

  /// Input's value was not changed.
  bool get isPure => _isPure;

  ValidatorResult<T> get validatorResult => _validator(value);

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  bool get isUnchanged => valueComparator?.call(initialValue, value) ?? _valueIsSameAsInitialValue;

  /// Input does not have conversion error nor validation error.
  bool get isValid => !hasConversionError && _validator(value).isValid;

  bool get isNotValid => !isValid;

  bool get hasConversionError => __conversionError != null;

  /// String representattion of [value].
  String get stringValue => stringTovalueConverter?.convertBack(value) ?? value.toString();

  bool get _valueIsSameAsInitialValue {
    if (identical(value, initialValue)) return true;

    if (value is List || value is Map || value is Set) {
      return const DeepCollectionEquality().equals(value, initialValue);
    }

    return value == initialValue;
  }

  set value(T value) => _setValue(value, shouldTriggerOnChange: true);

  // ignore: avoid_setters_without_getters, ok for internal use
  set _conversionError(ConvertError<T> value) {
    __conversionError = value;
    _bindedModel?.notifyInputUpdated(this);
  }

  GladeInput({
    required T value,
    required this.validatorInstance,
    required bool isPure,
    required this.valueComparator,
    required String? inputKey,
    required this.translateError,
    required this.stringTovalueConverter,
    required InputDependenciesFactory? dependenciesFactory,
    required this.defaultTranslations,
    required this.onChange,
    required ValueTransform<T>? valueTransform,
    T? initialValue,
    TextEditingController? textEditingController,
    bool createTextController = true,
    this.trackUnchanged = true,
  })  : _isPure = isPure,
        _value = value,
        _initialValue = initialValue,
        dependenciesFactory = dependenciesFactory ?? (() => []),
        inputKey = inputKey ?? '__${T.runtimeType}__${Random().nextInt(100000000)}',
        valueTransform = valueTransform ?? _defaultTransform,
        _textEditingController = textEditingController ??
            (createTextController
                ? TextEditingController(
                    text: switch (value) {
                      final String? x => x,
                      != null => stringTovalueConverter?.convertBack(value),
                      _ => null,
                    },
                  )
                : null) {
    validatorInstance.bindInput(this);
  }

  /// At least one of [value] or [initialValue] MUST be set.
  factory GladeInput.create({
    String? inputKey,

    /// Sets current value of input.
    /// When value is null, it is set to [initialValue].
    T? value,

    /// Initial value when GenericInput is created.
    ///
    /// This value can potentially differ from [value].
    /// Used for computing [isUnchanged].
    T? initialValue,
    ValidatorFactory<T>? validator,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<T>? valueTransform,
    DefaultTranslations? defaultTranslations,
    bool trackUnchanged = true,
  }) {
    assert(
      value != null || initialValue != null || TypeHelper.typeIsNullable<T>(),
      'If type is not nullable, at least one of value or initialValue must be set',
    );

    final validatorInstance = validator?.call(GladeValidator<T>()) ?? GladeValidator<T>().build();

    return GladeInput(
      value: (value ?? initialValue) as T,
      isPure: pure,
      validatorInstance: validatorInstance,
      initialValue: initialValue,
      translateError: translateError,
      valueComparator: valueComparator,
      inputKey: inputKey,
      stringTovalueConverter: valueConverter,
      dependenciesFactory: dependencies,
      onChange: onChange,
      textEditingController: textEditingController,
      createTextController: createTextController,
      valueTransform: valueTransform,
      defaultTranslations: defaultTranslations,
      trackUnchanged: trackUnchanged,
    );
  }

  ///
  /// Useful for input which allows null value without additional validations.
  ///
  /// In case of need of any validation use [GladeInput.create] directly.
  factory GladeInput.optional({
    T? value,
    T? initialValue,
    String? inputKey,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<T>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        validator: (v) => v.build(),
        value: value ?? initialValue,
        initialValue: initialValue,
        translateError: translateError,
        valueComparator: valueComparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
        onChange: onChange,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
        trackUnchanged: trackUnchanged,
      );

  /// Predefined GenericInput with predefined `notNull` validation.
  ///
  /// In case of need of any aditional validation use [GladeInput.create] directly.
  factory GladeInput.required({
    required T value,
    T? initialValue,
    String? inputKey,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<T>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        validator: (v) => (v..notNull()).build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        valueComparator: valueComparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
        onChange: onChange,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
        trackUnchanged: trackUnchanged,
      );

  @internal
  // ignore: use_setters_to_change_properties, as method.
  void bindToModel(GladeModel model) => _bindedModel = model;

  static GladeInput<int> intInput({
    required int value,
    String? inputKey,
    int? initialValue,
    ValidatorFactory<int>? validator,
    bool pure = true,
    ErrorTranslator<int>? translateError,
    ValueComparator<int>? valueComparator,
    InputDependenciesFactory? dependencies,
    OnChange<int>? onChange,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<int>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        value: value,
        initialValue: initialValue ?? value,
        validator: validator,
        pure: pure,
        translateError: translateError,
        valueComparator: valueComparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.intConverter,
        onChange: onChange,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
        trackUnchanged: trackUnchanged,
      );

  static GladeInput<bool> boolInput({
    required bool value,
    String? inputKey,
    bool? initialValue,
    ValidatorFactory<bool>? validator,
    bool pure = true,
    ErrorTranslator<bool>? translateError,
    ValueComparator<bool>? valueComparator,
    InputDependenciesFactory? dependencies,
    OnChange<bool>? onChange,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<bool>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        value: value,
        initialValue: initialValue ?? value,
        validator: validator,
        pure: pure,
        translateError: translateError,
        valueComparator: valueComparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.boolConverter,
        onChange: onChange,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
        trackUnchanged: trackUnchanged,
      );

  static GladeInput<String> stringInput({
    String? inputKey,
    String? value,
    String? initialValue,
    StringValidatorFactory? validator,
    bool pure = true,
    ErrorTranslator<String>? translateError,
    DefaultTranslations? defaultTranslations,
    InputDependenciesFactory? dependencies,
    OnChange<String>? onChange,
    TextEditingController? textEditingController,
    bool createTextController = true,
    bool isRequired = true,
    ValueTransform<String>? valueTransform,
    ValueComparator<String>? valueComparator,
    bool trackUnchanged = true,
  }) {
    final requiredInstance = validator?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build();
    final optionalInstance = validator?.call(StringValidator()) ?? StringValidator().build();

    return GladeInput(
      value: value ?? initialValue ?? '',
      isPure: pure,
      initialValue: initialValue ?? '',
      validatorInstance: isRequired ? requiredInstance : optionalInstance,
      translateError: translateError,
      defaultTranslations: defaultTranslations,
      inputKey: inputKey,
      dependenciesFactory: dependencies,
      onChange: onChange,
      textEditingController: textEditingController,
      createTextController: createTextController,
      valueComparator: valueComparator,
      stringTovalueConverter: null,
      valueTransform: valueTransform,
      trackUnchanged: trackUnchanged,
    );
  }

  ValidatorResult<T> validate() => _validator(value);

  String? translate({String delimiter = '.'}) => _translate(delimiter: delimiter, customError: validatorResult);

  String errorFormatted() {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return _translateConversionError(__conversionError!);

    return validatorResult.isInvalid ? _translate() ?? '' : '';
  }

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

      return !convertedError.isValid ? _translate(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (e) {
      return e.error != null
          ? _translate(delimiter: delimiter, customError: e)
          : e.devError(value, extra: validatorResult);
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

    return convertedError.isInvalid ? _translate(customError: convertedError) : null;
  }

  void updateValueWithString(String? strValue) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );

    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      this.value = converter.convert(strValue);
    } on ConvertError<T> catch (e) {
      _conversionError = e;
    }
  }

  /// Used as shorthand for field setter.
  ///
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValue(T value, {bool shouldTriggerOnChange = true}) =>
      _setValue(value, shouldTriggerOnChange: shouldTriggerOnChange);

  /// Used as shorthand for field setter.
  ///
  /// If `T` is non-nullable type and provided value is `null`, update is **not invoked**.
  ///
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValueWhenNotNull(T? value, {bool shouldTriggerOnChange = true}) {
    if (value == null) return;

    return _setValue(value, shouldTriggerOnChange: shouldTriggerOnChange);
  }

  /// Resets input into pure state.
  ///
  /// Allows to sets new initialValue and value if needed.
  /// By default ([invokeUpdate]=`true`) setting value will trigger  listeners.
  void resetToPure({ValueGetter<T>? value, ValueGetter<T>? initialValue, bool invokeUpdate = true}) {
    this._isPure = true;
    if (value != null) {
      if (invokeUpdate) {
        this.value = value();
      } else {
        _value = value();
      }
    }

    if (initialValue != null) {
      this._initialValue = initialValue();
    }
  }

  @protected
  GladeInput<T> copyWith({
    String? inputKey,
    ValueComparator<T>? valueComparator,
    ValidatorInstance<T>? validatorInstance,
    StringToTypeConverter<T>? stringTovalueConverter,
    InputDependenciesFactory? dependenciesFactory,
    T? initialValue,
    ErrorTranslator<T>? translateError,
    T? value,
    bool? isPure,
    DefaultTranslations? defaultTranslations,
    OnChange<T>? onChange,
    TextEditingController? textEditingController,
    // ignore: avoid-unused-parameters, it is here just to be linter happy ¯\_(ツ)_/¯
    bool? createTextController,
    ValueTransform<T>? valueTransform,
    bool? trackUnchanged,
  }) {
    return GladeInput(
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
      onChange: onChange ?? this.onChange,
      textEditingController: textEditingController ?? this._textEditingController,
      valueTransform: valueTransform ?? this.valueTransform,
      trackUnchanged: trackUnchanged ?? this.trackUnchanged,
    );
  }

  void _setValue(T value, {required bool shouldTriggerOnChange}) {
    _previousValue = _value;

    _value = valueTransform(value);

    final strValue = stringValue;
    // synchronize text controller with value
    _textEditingController?.value = TextEditingValue(
      text: strValue,
      selection: _textEditingController?.selection ?? const TextSelection.collapsed(offset: -1),
    );

    _isPure = false;
    __conversionError = null;

    // propagate input's changes
    if (shouldTriggerOnChange) {
      onChange?.call(
        ChangesInfo(
          previousValue: _previousValue,
          value: value,
          initialValue: initialValue,
          validatorResult: validate(),
        ),
        dependenciesFactory(),
      );
    }

    _bindedModel?.notifyInputUpdated(this);

    notifyListeners();
  }

  /// Translates input's errors (validation or conversion).
  String? _translate({String delimiter = '.', Object? customError}) {
    final err = customError ?? validatorResult;

    if (err is ValidatorResult<T> && err.isValid) return null;

    if (err is ValidatorResult<T>) {
      return _translateGenericErrors(err, delimiter);
    }

    if (err is ConvertError<T>) {
      return _translateConversionError(err);
    }

    //ignore: avoid-dynamic, ok for now
    if (err is List<dynamic>) {
      return err.map((x) => x.toString()).join('.');
    }

    return err.toString();
  }

  String _translateConversionError(ConvertError<T> err) {
    final defaultTranslationsTmp = this.defaultTranslations;
    final translateErrorTmp = translateError;
    final defaultConversionMessage = defaultTranslationsTmp?.defaultConversionMessage;

    if (translateErrorTmp != null) {
      return translateErrorTmp(err, err.key, err.devErrorMessage, dependenciesFactory());
    } else if (defaultConversionMessage != null) {
      return defaultConversionMessage;
    }

    return err.devErrorMessage;
  }

  ValidatorResult<T> _validator(T value) {
    return validatorInstance.validate(value);
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
      if (defaultTranslationsTmp != null &&
          (e.isNullError || e.hasStringEmptyOrNullErrorKey || e.hasNullValueOrEmptyValueKey)) {
        return defaultTranslationsTmp.defaultValueIsNullOrEmptyMessage ?? e.toString();
      }

      return e.toString();
    }).join(delimiter);
  }
}
