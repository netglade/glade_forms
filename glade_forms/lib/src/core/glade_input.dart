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
typedef IntValidatorFactory = ValidatorInstance<int> Function(IntValidator validator);
typedef OnChange<T> = void Function(ChangesInfo<T> info);
typedef OnDependencyChange = void Function(List<String> updateInputKeys);
typedef ValueTransform<T> = T Function(T input);

typedef StringInput = GladeInput<String>;
typedef IntInput = GladeInput<int>;

class GladeInput<T> {
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
  final OnChange<T>? onChange;

  /// Called when one of dependencies changes.
  final OnDependencyChange? onDependencyChange;

  /// Determines whether this input will be considered in isUnchanged on model.
  ///
  /// That means, when the value is false, it will opt-out this input from the computation.
  bool trackUnchanged;

  /// Transforms passed value before assigning it into input.
  // ignore: prefer-correct-callback-field-name, ok name
  final ValueTransform<T>? _valueTransform;

  final bool _useTextEditingController;

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

  /// If true onChange() is not triggered.
  bool _controllerTriggersOnChange = true;

  /// Input is in invalid state when there was conversion error.
  ConvertError<T>? __conversionError;

  GladeModel? _bindedModel;

  InputDependencies get dependencies => dependenciesFactory();

  T? get initialValue => _initialValue;

  TextEditingController? get controller => _textEditingController;

  T get value => _value;

  T? get previousValue => _previousValue;

  /// Input's value was not changed.
  bool get isPure => _isPure;

  ValidatorResult<T> get validatorResult => validatorInstance.validate(value);

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  bool get isUnchanged => valueComparator?.call(initialValue, value) ?? _valueIsSameAsInitialValue;

  /// Input does not have conversion error nor validation error.
  bool get isValid => !hasConversionError && validatorInstance.validate(value).isValid;

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

  set value(T value) {
    if (_useTextEditingController) {
      _syncValueWithController(value, shouldTriggerOnChange: true);
    } else {
      _setValue(value, shouldTriggerOnChange: true);
    }
  }

  // ignore: avoid_setters_without_getters, ok for internal use
  set _conversionError(ConvertError<T> value) {
    __conversionError = value;
    _bindedModel?.notifyInputUpdated(this);
  }

  GladeInput._({
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
    required this.onDependencyChange,
    required ValueTransform<T>? valueTransform,
    T? initialValue,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    this.trackUnchanged = true,
  })  : assert(
          dependenciesFactory == null || (onDependencyChange != null),
          'When dependencies are provided, provide onDependencyChange as well',
        ),
        _isPure = isPure,
        _value = value,
        _initialValue = initialValue,
        dependenciesFactory = dependenciesFactory ?? (() => []),
        inputKey = inputKey ?? '__${T.runtimeType}__${Random().nextInt(100000000)}',
        _valueTransform = valueTransform,
        _textEditingController = textEditingController ??
            (useTextEditingController
                ? TextEditingController(
                    text: switch (value) {
                      final String? x => x,
                      != null => stringTovalueConverter?.convertBack(value),
                      _ => null,
                    },
                  )
                : null),
        // ignore: avoid_bool_literals_in_conditional_expressions, cant be simplified.
        _useTextEditingController = textEditingController != null ? true : useTextEditingController {
    validatorInstance.bindInput(this);

    if (_useTextEditingController) {
      _textEditingController?.addListener(_onTextControllerChange);
    }
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
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    DefaultTranslations? defaultTranslations,
    bool trackUnchanged = true,
  }) {
    assert(
      value != null || initialValue != null || TypeHelper.typeIsNullable<T>(),
      'If type is not nullable, at least one of value or initialValue must be set',
    );

    final validatorInstance = validator?.call(GladeValidator()) ?? GladeValidator<T>().build();

    return GladeInput._(
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
      onDependencyChange: onDependencyChange,
      textEditingController: textEditingController,
      useTextEditingController: useTextEditingController,
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
    DefaultTranslations? defaultTranslations,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        validator: (v) => v.build(),
        value: value ?? initialValue,
        initialValue: initialValue,
        translateError: translateError,
        defaultTranslations: defaultTranslations,
        valueComparator: valueComparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
        onChange: onChange,
        onDependencyChange: onDependencyChange,
        textEditingController: textEditingController,
        useTextEditingController: useTextEditingController,
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
    DefaultTranslations? defaultTranslations,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? valueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        validator: (v) => (v..notNull()).build(),
        value: value,
        initialValue: initialValue,
        translateError: translateError,
        defaultTranslations: defaultTranslations,
        valueComparator: valueComparator,
        valueConverter: valueConverter,
        inputKey: inputKey,
        pure: pure,
        dependencies: dependencies,
        onChange: onChange,
        onDependencyChange: onDependencyChange,
        textEditingController: textEditingController,
        useTextEditingController: useTextEditingController,
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
    IntValidatorFactory? validator,
    bool pure = true,
    ErrorTranslator<int>? translateError,
    DefaultTranslations? defaultTranslations,
    ValueComparator<int>? valueComparator,
    InputDependenciesFactory? dependencies,
    OnChange<int>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<int>? valueTransform,
    bool trackUnchanged = true,
  }) {
    final validatorInstance = validator?.call(IntValidator()) ?? IntValidator().build();

    return GladeInput._(
      value: value,
      initialValue: initialValue ?? value,
      validatorInstance: validatorInstance,
      isPure: pure,
      translateError: translateError,
      defaultTranslations: defaultTranslations,
      valueComparator: valueComparator,
      inputKey: inputKey,
      dependenciesFactory: dependencies,
      stringTovalueConverter: GladeTypeConverters.intConverter,
      onChange: onChange,
      onDependencyChange: onDependencyChange,
      textEditingController: textEditingController,
      useTextEditingController: useTextEditingController,
      valueTransform: valueTransform,
      trackUnchanged: trackUnchanged,
    );
  }

  static GladeInput<bool> boolInput({
    required bool value,
    String? inputKey,
    bool? initialValue,
    ValidatorFactory<bool>? validator,
    bool pure = true,
    ErrorTranslator<bool>? translateError,
    DefaultTranslations? defaultTranslations,
    ValueComparator<bool>? valueComparator,
    InputDependenciesFactory? dependencies,
    OnChange<bool>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<bool>? valueTransform,
    bool trackUnchanged = true,
  }) =>
      GladeInput.create(
        value: value,
        initialValue: initialValue ?? value,
        validator: validator,
        pure: pure,
        translateError: translateError,
        defaultTranslations: defaultTranslations,
        valueComparator: valueComparator,
        inputKey: inputKey,
        dependencies: dependencies,
        valueConverter: GladeTypeConverters.boolConverter,
        onChange: onChange,
        onDependencyChange: onDependencyChange,
        textEditingController: textEditingController,
        useTextEditingController: useTextEditingController,
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
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = true,
    bool isRequired = true,
    ValueTransform<String>? valueTransform,
    ValueComparator<String>? valueComparator,
    bool trackUnchanged = true,
  }) {
    final requiredInstance = validator?.call(StringValidator()..notEmpty()) ?? (StringValidator()..notEmpty()).build();
    final optionalInstance = validator?.call(StringValidator()) ?? StringValidator().build();

    return GladeInput._(
      value: value ?? initialValue ?? '',
      isPure: pure,
      initialValue: initialValue ?? '',
      validatorInstance: isRequired ? requiredInstance : optionalInstance,
      translateError: translateError,
      defaultTranslations: defaultTranslations,
      inputKey: inputKey,
      dependenciesFactory: dependencies,
      onChange: onChange,
      onDependencyChange: onDependencyChange,
      textEditingController: textEditingController,
      useTextEditingController: useTextEditingController,
      valueComparator: valueComparator,
      stringTovalueConverter: null,
      valueTransform: valueTransform,
      trackUnchanged: trackUnchanged,
    );
  }

  // *
  // * Public methods
  // *

  ValidatorResult<T> validate() => validatorInstance.validate(value);

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
      final convertedError = validatorInstance.validate(convertedValue);

      return !convertedError.isValid ? _translate(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (e) {
      return e.error != null ? _translate(delimiter: delimiter, customError: e) : e.devError(value);
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
    final convertedError = validatorInstance.validate(value);

    return convertedError.isInvalid ? _translate(customError: convertedError) : null;
  }

  void updateValueWithString(String? strValue, {bool shouldTriggerOnChange = true}) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );

    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      if (_useTextEditingController) {
        _syncStringValueWithController(strValue, shouldTriggerOnChange: shouldTriggerOnChange);
      } else {
        final convertedValue = converter.convert(strValue);
        _setValue(convertedValue, shouldTriggerOnChange: shouldTriggerOnChange);
      }
    } on ConvertError<T> catch (e) {
      _conversionError = e;
    }
  }

  /// Used as shorthand for field setter.
  ///
  /// When `useTextEditingController` true, method will sync controller with provided value.
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValue(T value, {bool shouldTriggerOnChange = true}) {
    if (_useTextEditingController) {
      _syncValueWithController(value, shouldTriggerOnChange: shouldTriggerOnChange);
    } else {
      _setValue(value, shouldTriggerOnChange: shouldTriggerOnChange);
    }
  }

  /// Used as shorthand for field setter.
  ///
  /// If `T` is non-nullable type and provided value is `null`, update is **not invoked**.
  ///
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValueWhenNotNull(T? value, {bool shouldTriggerOnChange = true}) {
    if (value == null) return;

    updateValue(value, shouldTriggerOnChange: shouldTriggerOnChange);
  }

  /// Sets a new pure state for the input.
  ///
  /// Allows to set new initialValue and value if needed.
  /// By default ([invokeUpdate]=`true`) setting value will trigger listeners.
  void setAsNewPure({
    ValueGetter<T>? value,
    ValueGetter<T>? initialValue,
    bool invokeUpdate = true,
    bool copyValueToInitialValue = false,
  }) {
    if (value != null) {
      if (_useTextEditingController) {
        _syncValueWithController(value(), shouldTriggerOnChange: invokeUpdate);
      } else {
        if (invokeUpdate) {
          this.value = value();
        } else {
          _value = value();
        }
      }
    }
    this._isPure = true;
    if (initialValue != null) {
      this._initialValue = initialValue();

      if (invokeUpdate) _bindedModel?.notifyInputUpdated(this);
    }

    if (copyValueToInitialValue) {
      this._initialValue = this.value;

      if (invokeUpdate) _bindedModel?.notifyInputUpdated(this);
    }
  }

  /// Resets the input value to its initial value and sets it as pure.
  void resetToPure() {
    if (_useTextEditingController) {
      _syncValueWithController(_initialValue as T, shouldTriggerOnChange: true);
    } else {
      _value = _initialValue as T;
    }
    this._isPure = true;
    _bindedModel?.notifyInputUpdated(this);
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
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    // ignore: avoid-unused-parameters, it is here just to be linter happy ¯\_(ツ)_/¯
    bool? useTextEditingController,
    ValueTransform<T>? valueTransform,
    bool? trackUnchanged,
  }) {
    return GladeInput._(
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
      onDependencyChange: onDependencyChange ?? this.onDependencyChange,
      textEditingController: textEditingController ?? this._textEditingController,
      valueTransform: valueTransform ?? this._valueTransform,
      trackUnchanged: trackUnchanged ?? this.trackUnchanged,
    );
  }

  @mustCallSuper
  void dispose() {
    _textEditingController?.removeListener(_onTextControllerChange);
  }

  void _syncValueWithController(T value, {required bool shouldTriggerOnChange}) {
    final converter = stringTovalueConverter ?? _defaultConverter;
    try {
      _controllerTriggersOnChange = shouldTriggerOnChange;

      _textEditingController?.text = converter.convertBack(value);
    } on ConvertError<T> catch (e) {
      _conversionError = e;
      _controllerTriggersOnChange = true;
    }
  }

  void _syncStringValueWithController(String? value, {required bool shouldTriggerOnChange}) {
    _controllerTriggersOnChange = shouldTriggerOnChange;
    _textEditingController?.text = value ?? '';
  }

  // If using text controller - sync its value
  void _onTextControllerChange() {
    final converter = stringTovalueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(controller?.text);
      _setValue(convertedValue, shouldTriggerOnChange: _controllerTriggersOnChange);
    } on ConvertError<T> catch (e) {
      _conversionError = e;
    }
  }

  void _setValue(T value, {required bool shouldTriggerOnChange}) {
    _previousValue = _value;
    _value = _valueTransform?.call(value) ?? value;

    _isPure = false;
    __conversionError = null;

    // propagate input's changes
    if (shouldTriggerOnChange) {
      onChange?.call(
        ChangesInfo(
          inputKey: inputKey,
          previousValue: _previousValue,
          value: value,
          initialValue: initialValue,
          validatorResult: validate(),
        ),
      );
    }

    _bindedModel?.notifyInputUpdated(this);
  }

  // *
  // * Translation methods
  // *

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
    } else if (this._bindedModel case final model?) {
      return model.defaultErrorTranslate(err, err.key, err.devErrorMessage, dependenciesFactory());
    }

    return err.devErrorMessage;
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
      } else if (this._bindedModel case final model?) {
        return model.defaultErrorTranslate(e, e.key, e.devErrorMessage, dependenciesFactory());
      }

      return e.toString();
    }).join(delimiter);
  }
}
