import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/error/error.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/utils/type_helper.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

typedef ValueComparator<T> = bool Function(T? initial, T? value);

typedef OnChange<T> = void Function(ChangesInfo<T> info);
typedef OnDependencyChange = void Function(List<String> updateInputKeys);
typedef ValueTransform<T> = T Function(T input);

class GladeInput<T> {
  /// Compares initial and current value.
  @protected
  // ignore: prefer-correct-callback-field-name, ok name
  final ValueComparator<T>? valueComparator;

  @protected
  final ValidatorInstance<T> validatorInstance;

  @protected
  final StringToTypeConverter<T>? stringToValueConverter;

  // ignore: prefer-correct-callback-field-name, ok name
  final InputDependenciesFactory dependenciesFactory;

  /// An input's identification.
  ///
  /// Used within listener changes and dependency related functions such as validation.
  final String inputKey;

  // ignore: prefer-correct-callback-field-name, ok name
  final ValidationTranslator<T>? translateError;

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

  /// If true onChange() is triggered.
  bool _controllerTriggersOnChange = true;

  /// Input is in invalid state when there was conversion error.
  ConvertError<T>? __conversionError;

  GladeModel? _bindedModel;

  InputDependencies get dependencies => dependenciesFactory();

  /// Initial value of input.
  T? get initialValue => _initialValue;

  /// Text editing controller for input. Used for syncing input with text field.
  TextEditingController? get controller => _textEditingController;

  T get value => _value;

  T? get previousValue => _previousValue;

  /// Input is pure if its value is same as initial value and value was never updated.
  ///
  /// Pure can be reset when [resetToInitialValue] is called.
  bool get isPure => _isPure;

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  bool get isUnchanged => valueComparator?.call(initialValue, value) ?? _valueIsSameAsInitialValue;

  /// Input does not have conversion error nor validation errors but can include warnings.
  bool get isValid => !hasConversionError && validatorInstance.validate(value).isValid;

  /// Input does not have conversion error nor validation errors nor warnings.
  bool get isValidAndWithoutWarnings => !hasConversionError && validatorInstance.validate(value).isValidWithoutWarnings;

  /// True when input is not valid - it has errors.
  bool get isNotValid => !isValid;

  /// True when input has conversion error.
  bool get hasConversionError => __conversionError != null;

  ValidatorResult<T> get validatorResult => validatorInstance.validate(value);

  List<GladeInputValidation<T>> get validationErrors => validatorResult.errors;

  List<GladeInputValidation<T>> get validationWarnings => validatorResult.warnings;

  /// String representattion of [value].
  String get stringValue => stringToValueConverter?.convertBack(value) ?? value.toString();

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

  @internal
  GladeInput.internalCreate({
    required this.validatorInstance,
    String? inputKey,
    T? value,
    T? initialValue,
    bool isPure = true,
    this.translateError,
    this.valueComparator,
    this.stringToValueConverter,
    InputDependenciesFactory? dependencies,
    this.onChange,
    this.onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    this.defaultTranslations,
    this.trackUnchanged = true,
  })  : assert(
          value != null || initialValue != null || TypeHelper.typeIsNullable<T>(),
          'If type is not nullable, at least one of value or initialValue must be set (affected input: $inputKey)',
        ),
        _isPure = isPure,
        _value = (value ?? initialValue) as T,
        _initialValue = initialValue,
        dependenciesFactory = dependencies ?? (() => []),
        inputKey = inputKey ?? '__${T.runtimeType}__${Random().nextInt(100_000_000)}',
        _valueTransform = valueTransform,

        // ignore: avoid_bool_literals_in_conditional_expressions, cant be simplified.
        _useTextEditingController = textEditingController != null ? true : useTextEditingController {
    final defaultValue = (value ?? initialValue) as T;
    _textEditingController = textEditingController ??
        (useTextEditingController
            ? TextEditingController(
                text: switch (defaultValue) {
                  final String? x => x,
                  != null => stringToValueConverter?.convertBack(defaultValue),
                  _ => null,
                },
              )
            : null);

    validatorInstance.bindInput(this);

    if (_useTextEditingController) {
      _textEditingController?.addListener(_onTextControllerChange);
    }
  }

  /// At least one of [value] or [initialValue] MUST be set.
  factory GladeInput.create({
    String? inputKey,
    T? value,
    T? initialValue,
    ValidatorFactory<T>? validator,
    bool isPure = true,
    ValidationTranslator<T>? translateError,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? stringToValueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    DefaultTranslations? defaultTranslations,
    bool trackUnchanged = true,
  }) =>
      GladeInput.internalCreate(
        validatorInstance: validator?.call(GladeValidator()) ?? GladeValidator<T>().build(),
        inputKey: inputKey,
        value: value,
        initialValue: initialValue,
        isPure: isPure,
        translateError: translateError,
        valueComparator: valueComparator,
        stringToValueConverter: stringToValueConverter,
        dependencies: dependencies,
        onChange: onChange,
        onDependencyChange: onDependencyChange,
        textEditingController: textEditingController,
        useTextEditingController: useTextEditingController,
        valueTransform: valueTransform,
        defaultTranslations: defaultTranslations,
        trackUnchanged: trackUnchanged,
      );

  ///
  /// Useful for input which allows null value without additional validations.
  ///
  /// In case of need of any validation use [GladeInput.create] directly.
  factory GladeInput.optional({
    T? value,
    T? initialValue,
    String? inputKey,
    bool pure = true,
    ValidationTranslator<T>? translateError,
    DefaultTranslations? defaultTranslations,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? stringToValueConverter,
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
        stringToValueConverter: stringToValueConverter,
        inputKey: inputKey,
        isPure: pure,
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
    T? value,
    T? initialValue,
    String? inputKey,
    bool pure = true,
    ValidationTranslator<T>? translateError,
    DefaultTranslations? defaultTranslations,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? stringToValueConverter,
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
        stringToValueConverter: stringToValueConverter,
        inputKey: inputKey,
        isPure: pure,
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

  // *
  // * Public methods
  // *

  ValidatorResult<T> validate() => validatorInstance.validate(value);

  String? translate({String delimiter = '.'}) => _translate(delimiter: delimiter, customError: validatorResult);

  String errorFormatted() {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return _translateConversionError(__conversionError!);

    return validatorResult.isNotValid ? (_translate() ?? '') : '';
  }

  String errorOrWarningFormatted({String delimiter = '.'}) {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return _translateConversionError(__conversionError!);

    return _translate(severity: ValidationSeverity.warning, delimiter: delimiter) ?? '';
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  /// If there are multiple errors they are concenated into one string with [delimiter].
  String? textFormFieldInputValidatorCustom(
    String? value, {
    String delimiter = '.',
    ValidationSeverity severity = ValidationSeverity.error,
  }) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringToValueConverter != null,
      'For non-string values [converter] must be provided. TInput type: $T',
    );
    final converter = stringToValueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(value);
      final convertedError = validatorInstance.validate(convertedValue);

      return !convertedError.isValidWithSeverity(severity)
          ? _translate(delimiter: delimiter, customError: convertedError, severity: severity)
          : null;
    } on ConvertError<T> catch (e) {
      return _translate(delimiter: delimiter, customError: e, severity: severity);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  String? textFormFieldInputValidator(
    String? value, {
    ValidationSeverity severity = ValidationSeverity.error,
    String delimiter = '.',
  }) =>
      textFormFieldInputValidatorCustom(value, severity: severity, delimiter: delimiter);

  /// Shorthand validator for Form field input.
  ///
  /// Returns translated validation message.
  String? formFieldValidator(
    T value, {
    ValidationSeverity severity = ValidationSeverity.error,
    String delimiter = '.',
  }) {
    final convertedError = validatorInstance.validate(value);

    return convertedError.isNotValid
        ? _translate(customError: convertedError, severity: severity, delimiter: delimiter)
        : null;
  }

  void updateValueWithString(String? strValue, {bool shouldTriggerOnChange = true}) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringToValueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );

    final converter = stringToValueConverter ?? _defaultConverter;

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

  /// Sets new initial value and resets the input to it.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  void setNewInitialValue({
    required ValueGetter<T> initialValue,
    bool shouldResetToInitialValue = false,
    bool shouldTriggerOnChange = true,
  }) {
    _initialValue = initialValue();

    if (shouldResetToInitialValue) {
      resetToInitialValue(shouldTriggerOnChange: shouldTriggerOnChange);
    } else {
      _bindedModel?.notifyInputUpdated(this);
    }
  }

  /// Resets the input value to its initial value and sets it as pure.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  void resetToInitialValue({bool shouldTriggerOnChange = true}) {
    assert(_initialValue != null || TypeHelper.typeIsNullable<T>(), 'Initial can not be null for non-nullable type');

    if (!TypeHelper.typeIsNullable<T>() && _initialValue == null) return;

    if (_useTextEditingController) {
      _syncValueWithController(_initialValue as T, shouldTriggerOnChange: shouldTriggerOnChange);
    } else {
      updateValue(_initialValue as T, shouldTriggerOnChange: shouldTriggerOnChange);
    }

    _isPure = true;
    _bindedModel?.notifyInputUpdated(this);
  }

  /// Sets the input as pure and sets new initial value as current value.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  void setNewInitialValueAsCurrentValue({bool shouldTriggerOnChange = true}) {
    setNewInitialValue(
      initialValue: () => value,
      shouldResetToInitialValue: true,
      shouldTriggerOnChange: shouldTriggerOnChange,
    );
  }

  @protected
  GladeInput<T> copyWith({
    String? inputKey,
    ValueComparator<T>? valueComparator,
    ValidatorInstance<T>? validatorInstance,
    StringToTypeConverter<T>? stringToValueConverter,
    InputDependenciesFactory? dependencies,
    T? initialValue,
    ValidationTranslator<T>? translateError,
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
    return GladeInput.internalCreate(
      value: value ?? this.value,
      valueComparator: valueComparator ?? this.valueComparator,
      validatorInstance: validatorInstance ?? this.validatorInstance,
      stringToValueConverter: stringToValueConverter ?? this.stringToValueConverter,
      dependencies: dependencies ?? dependenciesFactory,
      inputKey: inputKey ?? this.inputKey,
      initialValue: initialValue ?? this.initialValue,
      translateError: translateError ?? this.translateError,
      isPure: isPure ?? this.isPure,
      defaultTranslations: defaultTranslations ?? this.defaultTranslations,
      onChange: onChange ?? this.onChange,
      onDependencyChange: onDependencyChange ?? this.onDependencyChange,
      textEditingController: textEditingController ?? _textEditingController,
      valueTransform: valueTransform ?? _valueTransform,
      trackUnchanged: trackUnchanged ?? this.trackUnchanged,
    );
  }

  @mustCallSuper
  void dispose() {
    _textEditingController?.removeListener(_onTextControllerChange);
  }

  @override
  String toString() {
    return '$inputKey ($value)';
  }

  void _syncValueWithController(T value, {required bool shouldTriggerOnChange}) {
    final converter = stringToValueConverter ?? _defaultConverter;
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
    final converter = stringToValueConverter ?? _defaultConverter;

    final shouldTriggerOnNextChange = _controllerTriggersOnChange;
    _controllerTriggersOnChange = true;

    try {
      final convertedValue = converter.convert(controller?.text);

      _setValue(convertedValue, shouldTriggerOnChange: shouldTriggerOnNextChange);
    } on ConvertError<T> catch (e) {
      _conversionError = e;
    }
  }

  void _setValue(T value, {required bool shouldTriggerOnChange}) {
    _previousValue = _value;

    // ignore: prefer-conditional-expressions, keep explicit if-else
    if (_valueTransform != null) {
      _value = TypeHelper.typeIsNullable<T>() ? _valueTransform(value) : (_valueTransform(value) ?? value);
    } else {
      _value = value;
    }

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
  String? _translate({
    String delimiter = '.',
    Object? customError,
    ValidationSeverity severity = ValidationSeverity.error,
  }) {
    final err = customError ?? validatorResult;

    if (err is ValidatorResult<T> && err.isValidWithSeverity(severity)) return null;

    if (err is ValidatorResult<T>) {
      return _translateGenericErrors(err, delimiter, severity: severity);
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
    final defaultTranslationsTmp = defaultTranslations;
    final translateErrorTmp = translateError;
    final defaultConversionMessage = defaultTranslationsTmp?.defaultConversionMessage;

    if (translateErrorTmp != null) {
      return translateErrorTmp(err, err.key, err.devMessage, dependenciesFactory());
    } else if (defaultConversionMessage != null) {
      return defaultConversionMessage;
    } else if (_bindedModel case final model?) {
      return model.defaultErrorTranslate(err, err.key, err.devMessage, dependenciesFactory());
    }

    return err.devMessage;
  }

  String _translateGenericErrors(
    ValidatorResult<T> validatorResult,
    String delimiter, {
    ValidationSeverity severity = ValidationSeverity.error,
  }) {
    final translateErrorTmp = translateError;

    final results = switch (severity) {
      ValidationSeverity.error => validatorResult.errors,
      // * Warning + Error
      ValidationSeverity.warning => validatorResult.all,
    };

    final defaultTranslationsTmp = defaultTranslations;
    if (translateErrorTmp != null) {
      return results
          .map((e) => translateErrorTmp(e, e.key, e.devValidationMessage, dependenciesFactory()))
          .join(delimiter);
    }

    return results.map((e) {
      if (defaultTranslationsTmp != null &&
          (e.isNullError || e.hasStringEmptyOrNullErrorKey || e.hasNullValueOrEmptyValueKey)) {
        return defaultTranslationsTmp.defaultValueIsNullOrEmptyMessage ?? e.toString();
      } else if (_bindedModel case final model?) {
        return model.defaultErrorTranslate(e, e.key, e.devValidationMessage, dependenciesFactory());
      }

      return e.toString();
    }).join(delimiter);
  }
}
