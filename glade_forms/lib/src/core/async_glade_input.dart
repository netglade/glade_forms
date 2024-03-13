import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/converters/glade_type_converters.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/error_translator.dart';
import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/core/type_helper.dart';
import 'package:glade_forms/src/model/model.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

typedef OnChangeAsync<T> = Future<void> Function(ChangesInfo<T> info, InputDependencies dependencies);
typedef AsyncStringInput = AsyncGladeInput<String?>;

T _defaultTransform<T>(T input) => input;

class AsyncGladeInput<T> extends GladeInputBase<T> {
  /// Compares initial and current value.
  @protected
  final ValueComparator<T>? valueComparator;

  @protected
  final ValidatorInstance<T> validatorInstance;

  @protected
  final StringToTypeConverter<T>? stringTovalueConverter;

  final ErrorTranslator<T>? translateError;

  /// Validation message for conversion error.
  final DefaultTranslations? defaultTranslations;

  /// Called when input's value changed.
  OnChangeAsync<T>? onChangeAsync;

  /// Transforms passed value before assigning it into input.
  ValueTransform<T> valueTransform;

  final InputDependenciesFactory _dependenciesFactory;

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

  GladeModelBase? _bindedModel;

  bool __isChanging = false;

  T? get initialValue => _initialValue;

  TextEditingController? get controller => _textEditingController;

  @override
  T get value => _value;

  T? get previousValue => _previousValue;

  /// Input's value was not changed.
  @override
  bool get isPure => _isPure;

  @override
  @Deprecated('Use [validatorResultAsync] in AsyncGladeInput')
  ValidatorResult<T> get validatorResult => throw UnsupportedError('Use [validatorResultAsync] in AsyncGladeInput');

  @override
  Future<ValidatorResult<T>> get validatorResultAsync => _validator(value);

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  @override
  bool get isUnchanged => valueComparator?.call(initialValue, value) ?? (value == initialValue);

  /// Input does not have conversion error nor validation error.
  @override
  @Deprecated('Use [isValidAsync] in AsyncGladeInput')
  bool get isValid => throw UnsupportedError('Use [isValidAsync] in AsyncGladeInput');

  @override
  Future<bool> get isValidAsync async => !hasConversionError && (await _validator(value)).isValid;

  @override
  @Deprecated('Use [isNotValidAsync] in AsyncGladeInput')
  bool get isNotValid => throw UnsupportedError('Use [isNotValidAsync] in AsyncGladeInput');

  @override
  Future<bool> get isNotValidAsync async => !(await isValidAsync);

  @override
  bool get hasConversionError => __conversionError != null;

  /// String representattion of [value].
  String get stringValue => stringTovalueConverter?.convertBack(value) ?? value.toString();

  @override
  InputDependencies get dependencies => _dependenciesFactory();

  @override
  bool get isChanging => __isChanging;

  // ignore: avoid_setters_without_getters, ok for internal use
  set _conversionError(ConvertError<T> value) {
    __conversionError = value;
    _bindedModel?.notifyInputUpdated(this);
  }

  AsyncGladeInput({
    required T value,
    required this.validatorInstance,
    required bool isPure,
    required this.valueComparator,
    required super.inputKey,
    required this.translateError,
    required this.stringTovalueConverter,
    required InputDependenciesFactory? dependenciesFactory,
    required this.defaultTranslations,
    required this.onChangeAsync,
    required ValueTransform<T>? valueTransform,
    T? initialValue,
    TextEditingController? textEditingController,
    bool createTextController = true,
  })  : _isPure = isPure,
        _value = value,
        _initialValue = initialValue,
        _dependenciesFactory = dependenciesFactory ?? (() => []),
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

  factory AsyncGladeInput.create({
    /// Sets current value of input.
    required T value,
    String? inputKey,
    ValidatorFactory<T>? validator,

    /// Initial value when GenericInput is created.
    ///
    /// This value can potentially differ from value. Used for computing `isUnchanged`.
    T? initialValue,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChangeAsync<T>? onChangeAsync,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<T>? valueTransform,
    DefaultTranslations? defaultTranslations,
  }) {
    final validatorInstance = validator?.call(GladeValidator<T>()) ?? GladeValidator<T>().build();

    return AsyncGladeInput(
      value: value,
      isPure: pure,
      validatorInstance: validatorInstance,
      initialValue: initialValue,
      translateError: translateError,
      valueComparator: valueComparator,
      inputKey: inputKey,
      stringTovalueConverter: valueConverter,
      dependenciesFactory: dependencies,
      onChangeAsync: onChangeAsync,
      textEditingController: textEditingController,
      createTextController: createTextController,
      valueTransform: valueTransform,
      defaultTranslations: defaultTranslations,
    );
  }

  ///
  /// Useful for input which allows null value without additional validations.
  ///
  /// In case of need of any validation use [GladeInput.create] directly.
  factory AsyncGladeInput.optional({
    required T value,
    String? inputKey,
    T? initialValue,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChangeAsync<T>? onChangeAsync,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<T>? valueTransform,
  }) =>
      AsyncGladeInput.create(
        validator: (v) => v.build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        valueComparator: valueComparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
        onChangeAsync: onChangeAsync,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
      );

  /// Predefined GenericInput with predefined `notNull` validation.
  ///
  /// In case of need of any aditional validation use [GladeInput.create] directly.
  factory AsyncGladeInput.required({
    required T value,
    String? inputKey,
    T? initialValue,
    bool pure = true,
    ErrorTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChangeAsync<T>? onChangeAsync,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<T>? valueTransform,
  }) =>
      AsyncGladeInput.create(
        validator: (v) => (v..notNull()).build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        valueComparator: valueComparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
        onChangeAsync: onChangeAsync,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
      );

  @override
  @Deprecated('Use [updateValueAsync] in AsyncGladeInput')
  void updateValue(T value) => throw UnsupportedError('Use [updateValueAsync] in AsyncGladeInput');

  @override
  Future<void> updateValueAsync(T value) async {
    __isChanging = true;
    _previousValue = _value;

    _value = valueTransform(value);

    final strValue = stringValue;
    // synchronize text controller with value
    _textEditingController?.value = TextEditingValue(
      text: strValue,
      selection: TextSelection.collapsed(offset: strValue.length),
    );

    _isPure = false;
    __conversionError = null;

    // propagate input's changes
    await onChangeAsync?.call(
      ChangesInfo(
        previousValue: _previousValue,
        value: value,
        initialValue: initialValue,
        validatorResult: await validate(),
      ),
      _dependenciesFactory(),
    );
    __isChanging = false;
    _bindedModel?.notifyInputUpdated(this);

    notifyListeners();
  }

  @override
  @internal
  // ignore: use_setters_to_change_properties, as method.
  void bindToModel(GladeModelBase model) => _bindedModel = model;

  static AsyncGladeInput<int> intInput({
    required int value,
    String? inputKey,
    ValidatorFactory<int>? validator,
    int? initialValue,
    bool pure = true,
    ErrorTranslator<int>? translateError,
    ValueComparator<int>? valueComparator,
    InputDependenciesFactory? dependencies,
    OnChangeAsync<int>? onChangeAsync,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<int>? valueTransform,
  }) =>
      AsyncGladeInput.create(
        value: value,
        initialValue: initialValue,
        validator: validator,
        pure: pure,
        translateError: translateError,
        valueComparator: valueComparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.intConverter,
        onChangeAsync: onChangeAsync,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
      );

  static AsyncGladeInput<bool> boolInput({
    required bool value,
    String? inputKey,
    ValidatorFactory<bool>? validator,
    bool? initialValue,
    bool pure = true,
    ErrorTranslator<bool>? translateError,
    ValueComparator<bool>? valueComparator,
    InputDependenciesFactory? dependencies,
    OnChangeAsync<bool>? onChangeAsync,
    TextEditingController? textEditingController,
    bool createTextController = true,
    ValueTransform<bool>? valueTransform,
  }) =>
      AsyncGladeInput.create(
        value: value,
        initialValue: initialValue,
        validator: validator,
        pure: pure,
        translateError: translateError,
        valueComparator: valueComparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.boolConverter,
        onChangeAsync: onChangeAsync,
        textEditingController: textEditingController,
        createTextController: createTextController,
        valueTransform: valueTransform,
      );

  static AsyncGladeInput<String?> stringInput({
    String? inputKey,
    String? value,
    StringValidatorFactory? validator,
    String? initialValue,
    bool pure = true,
    ErrorTranslator<String?>? translateError,
    DefaultTranslations? defaultTranslations,
    InputDependenciesFactory? dependencies,
    OnChangeAsync<String?>? onChangeAsync,
    TextEditingController? textEditingController,
    bool createTextController = true,
    bool isRequired = true,
    ValueTransform<String?>? valueTransform,
    ValueComparator<String?>? valueComparator,
  }) {
    final requiredInstance = validator?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build();
    final optionalInstance = validator?.call(StringValidator()) ?? StringValidator().build();

    return AsyncStringInput(
      value: value,
      isPure: pure,
      initialValue: initialValue,
      validatorInstance: isRequired ? requiredInstance : optionalInstance,
      translateError: translateError,
      defaultTranslations: defaultTranslations,
      inputKey: inputKey,
      dependenciesFactory: dependencies,
      onChangeAsync: onChangeAsync,
      textEditingController: textEditingController,
      createTextController: createTextController,
      valueComparator: valueComparator,
      stringTovalueConverter: null,
      valueTransform: valueTransform,
    );
  }

  Future<ValidatorResult<T>> validate() => _validator(value);

  Future<String?> translate({String delimiter = '.'}) async =>
      _translate(delimiter: delimiter, customError: await validatorResultAsync);

  @override
  @Deprecated('Use [errorFormattedAsync] in AsyncGladeInput')
  String errorFormatted({String delimiter = '|'}) =>
      throw UnsupportedError('Use [errorFormattedAsync] in AsyncGladeInput');

  @override
  Future<String> errorFormattedAsync({String delimiter = '|'}) async {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return _translateConversionError(__conversionError!);

    final validation = await validatorResultAsync;

    return validation.isInvalid ? validation.errors.map((e) => e.toString()).join(delimiter) : '';
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  /// If there are multiple errors they are concenated into one string with [delimiter].
  Future<String?> textFormFieldInputValidatorCustom(String? value, {String delimiter = '.'}) async {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: $T',
    );
    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(value);
      final convertedError = await _validator(convertedValue);

      return !convertedError.isValid ? await _translate(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (e) {
      return e.error != null
          ? await _translate(delimiter: delimiter, customError: e)
          : e.devError(value, extra: await validatorResultAsync);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  Future<String?> textFormFieldInputValidator(String? value) => textFormFieldInputValidatorCustom(value);

  /// Shorthand validator for Form field input.
  ///
  /// Returns translated validation message.
  Future<String?> formFieldValidator(T value) async {
    final convertedError = await _validator(value);

    return convertedError.isInvalid ? _translate(customError: convertedError) : null;
  }

  @override
  @Deprecated('Use [updateValueWithStringAsync] in AsyncGladeInput')
  void updateValueWithString(String? strValue) =>
      throw UnsupportedError('Use [updateValueWithStringAsync] in AsyncGladeInput');

  @override
  Future<void> updateValueWithStringAsync(String? strValue) async {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );

    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      await updateValueAsync(converter.convert(strValue));
    } on ConvertError<T> catch (e) {
      _conversionError = e;
    }
  }

  // ignore: use_setters_to_change_properties, used as shorthand for field setter.
  //void updateValue(T value) => this.value = value;

  /// Resets input into pure state.
  ///
  /// Allows to sets new initialValue and value if needed.
  /// By default ([invokeUpdate]=`true`) setting value will trigger  listeners.
  void resetToPure({ValueGetter<T>? value, ValueGetter<T>? initialValue, bool invokeUpdate = true}) {
    this._isPure = true;
    if (value != null) {
      if (invokeUpdate) {
        updateValue(value());
      } else {
        _value = value();
      }
    }

    if (initialValue != null) {
      this._initialValue = initialValue();
    }
  }

  @protected
  AsyncGladeInput<T> copyWith({
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
    OnChangeAsync<T>? onChangeAsync,
    TextEditingController? textEditingController,
    // ignore: avoid-unused-parameters, it is here just to be linter happy ¯\_(ツ)_/¯
    bool? createTextController,
    ValueTransform<T>? valueTransform,
  }) {
    return AsyncGladeInput(
      value: value ?? this.value,
      valueComparator: valueComparator ?? this.valueComparator,
      validatorInstance: validatorInstance ?? this.validatorInstance,
      stringTovalueConverter: stringTovalueConverter ?? this.stringTovalueConverter,
      dependenciesFactory: dependenciesFactory ?? this._dependenciesFactory,
      inputKey: inputKey ?? this.inputKey,
      initialValue: initialValue ?? this.initialValue,
      translateError: translateError ?? this.translateError,
      isPure: isPure ?? this.isPure,
      defaultTranslations: defaultTranslations ?? this.defaultTranslations,
      onChangeAsync: onChangeAsync ?? this.onChangeAsync,
      textEditingController: textEditingController ?? this._textEditingController,
      valueTransform: valueTransform ?? this.valueTransform,
    );
  }

  /// Translates input's errors (validation or conversion).
  Future<String?> _translate({String delimiter = '.', Object? customError}) async {
    final err = customError ?? await validatorResultAsync;

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
      return translateErrorTmp(err, err.key, err.devErrorMessage, _dependenciesFactory());
    } else if (defaultConversionMessage != null) {
      return defaultConversionMessage;
    }

    return err.devErrorMessage;
  }

  Future<ValidatorResult<T>> _validator(T value) => validatorInstance.validateAsync(value);

  String _translateGenericErrors(ValidatorResult<T> inputErrors, String delimiter) {
    final translateErrorTmp = translateError;

    final defaultTranslationsTmp = this.defaultTranslations;
    if (translateErrorTmp != null) {
      return inputErrors.errors
          .map((e) => translateErrorTmp(e, e.key, e.devErrorMessage, _dependenciesFactory()))
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
