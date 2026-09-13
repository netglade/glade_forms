import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/error/error.dart';
import 'package:glade_forms/src/core/input/async_validation_runner.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/model/async_validation_mode.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/utils/type_helper.dart';
import 'package:glade_forms/src/utils/value_equality.dart';
import 'package:glade_forms/src/validator/validator.dart';
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
  final ValidationTranslator<T>? validationTranslate;

  /// Validation message for conversion error.
  final DefaultValidationTranslations? defaultValidationTranslations;

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

  /// True when the controller was created by the input itself and therefore input is responsible for disposing it.
  final bool _ownsTextEditingController;

  /// Initial value - does not change after creating.
  T? _initialValue;

  TextEditingController? _textEditingController;

  final StringToTypeConverter<T> _defaultConverter = StringToTypeConverter(converter: (x, _) => x as T);

  /// Current input's value.
  T _value;

  /// Previous inputs'value.
  T? _previousValue;

  /// Input did not updated its value from initialValue.
  bool _isPure;

  /// If true onChange() is triggered.
  bool _controllerTriggersOnChange = true;

  bool _isDisposed = false;

  /// Input is in invalid state when there was conversion error.
  ConvertError<T>? __conversionError;

  GladeModel? _bindedModel;

  AsyncValidationRunner<T>? _asyncRunner;

  InputDependencies get dependencies => dependenciesFactory();

  /// Initial value of input.
  T? get initialValue => _initialValue;

  /// Text editing controller for input. Used for syncing input with text field.
  TextEditingController? get controller => _textEditingController;

  /// Input was already disposed and should not be used anymore.
  bool get isDisposed => _isDisposed;

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
  ///
  /// With [AsyncValidationMode.strict] (default) pending async validation makes the input invalid.
  /// Never triggers async validation, see [validate].
  bool get isValid {
    if (hasConversionError) return false;

    final result = validatorResult;

    return _applyAsyncMode(result, result.isValid);
  }

  /// Input does not have conversion error nor validation errors nor warnings.
  ///
  /// With [AsyncValidationMode.strict] (default) pending async validation makes the input invalid.
  bool get isValidAndWithoutWarnings {
    if (hasConversionError) return false;

    final result = validatorResult;

    return _applyAsyncMode(result, result.isValidWithoutWarnings);
  }

  /// True when input is not valid - it has errors.
  bool get isNotValid => !isValid;

  /// True when asynchronous validation for the current value is scheduled or running.
  bool get isValidating => _asyncRunner?.isValidating ?? false;

  /// True when the input declares at least one asynchronous validator.
  bool get hasAsyncValidation => validatorInstance.hasAsyncParts;

  /// True when input has conversion error.
  bool get hasConversionError => __conversionError != null;

  /// Synchronous result merged with the cached asynchronous result for the current value.
  ///
  /// Pure read, never triggers async validation. Use [validate] or [validateAsync] to trigger it.
  ValidatorResult<T> get validatorResult {
    final runner = _asyncRunner;

    if (runner == null) return validatorInstance.validate(value);
    if (runner.cachedResult case final cached?) return cached;

    return validatorInstance.validate(value).copyWith(asyncState: runner.isValidating ? .pending : .notRun);
  }

  List<GladeInputValidation<T>> get validationErrors => validatorResult.errors;

  List<GladeInputValidation<T>> get validationWarnings => validatorResult.warnings;

  /// String representattion of [value].
  String get stringValue => stringToValueConverter?.convertBack(value) ?? value.toString();

  bool get _valueIsSameAsInitialValue => ValueEquality.equals(value, initialValue);

  AsyncValidationMode get _asyncValidationMode => _bindedModel?.asyncValidationMode ?? .strict;

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
    this.validationTranslate,
    this.valueComparator,
    this.stringToValueConverter,
    InputDependenciesFactory? dependencies,
    this.onChange,
    this.onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    this.defaultValidationTranslations,
    this.trackUnchanged = true,
  }) : assert(
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
       _useTextEditingController = textEditingController != null ? true : useTextEditingController,
       _ownsTextEditingController = textEditingController == null && useTextEditingController {
    final defaultValue = (value ?? initialValue) as T;
    _textEditingController =
        textEditingController ??
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

    if (validatorInstance.hasAsyncParts) {
      _asyncRunner = AsyncValidationRunner(
        validatorInstance: validatorInstance,
        onCompleted: _onAsyncValidationCompleted,
      );
    }
  }

  /// At least one of [value] or [initialValue] MUST be set.
  factory GladeInput.create({
    String? inputKey,
    T? value,
    T? initialValue,
    ValidatorFactory<T>? validator,
    bool isPure = true,
    ValidationTranslator<T>? validationTranslate,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? stringToValueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    DefaultValidationTranslations? defaultTranslations,
    bool trackUnchanged = true,
  }) => GladeInput.internalCreate(
    validatorInstance: validator?.call(GladeValidator()) ?? GladeValidator<T>().build(),
    inputKey: inputKey,
    value: value,
    initialValue: initialValue,
    isPure: isPure,
    validationTranslate: validationTranslate,
    valueComparator: valueComparator,
    stringToValueConverter: stringToValueConverter,
    dependencies: dependencies,
    onChange: onChange,
    onDependencyChange: onDependencyChange,
    textEditingController: textEditingController,
    useTextEditingController: useTextEditingController,
    valueTransform: valueTransform,
    defaultValidationTranslations: defaultTranslations,
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
    ValidationTranslator<T>? validationTranslate,
    DefaultValidationTranslations? defaultTranslations,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? stringToValueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    bool trackUnchanged = true,
  }) => GladeInput.create(
    validator: (v) => v.build(),
    value: value ?? initialValue,
    initialValue: initialValue,
    validationTranslate: validationTranslate,
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
    ValidationTranslator<T>? validationTranslate,
    DefaultValidationTranslations? defaultTranslations,
    ValueComparator<T>? valueComparator,
    StringToTypeConverter<T>? stringToValueConverter,
    InputDependenciesFactory? dependencies,
    OnChange<T>? onChange,
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    ValueTransform<T>? valueTransform,
    bool trackUnchanged = true,
  }) => GladeInput.create(
    validator: (v) => (v..notNull()).build(),
    value: value,
    initialValue: initialValue,
    validationTranslate: validationTranslate,
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

  /// Returns current validation result and triggers asynchronous validation when it did not run for the current value yet.
  ValidatorResult<T> validate() {
    _scheduleAsyncValidation();

    return validatorResult;
  }

  /// Runs asynchronous validation for the current value immediately, skipping the debounce, and awaits it.
  ///
  /// Returns the cached result when async validation already finished for the current value, unless [force] is `true`.
  /// Joins a running validation instead of starting a new one. Without async validators returns the synchronous result.
  Future<ValidatorResult<T>> validateAsync({bool force = false}) {
    final runner = _asyncRunner;

    if (runner == null || hasConversionError || _isDisposed) return Future.value(validatorResult);

    if (force) runner.invalidate();

    if (!validatorInstance.shouldRunAsyncParts(validatorInstance.validate(value))) return Future.value(validatorResult);

    return runner.runNow(value);
  }

  String? translate({String delimiter = '.'}) => _translate(delimiter: delimiter, customError: validatorResult);

  String errorFormatted() {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return _translateConversionError(__conversionError!);

    return validatorResult.isNotValid ? (_translate() ?? '') : '';
  }

  String errorOrWarningFormatted({String delimiter = '.'}) {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return _translateConversionError(__conversionError!);

    return _translate(severity: .warning, delimiter: delimiter) ?? '';
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  /// If there are multiple errors they are concenated into one string with [delimiter].
  ///
  /// Triggers asynchronous validation of the input's current value.
  /// The [value] argument is only used for the synchronous message.
  String? textFormFieldInputValidatorCustom(
    String? value, {
    String delimiter = '.',
    ValidationSeverity severity = .error,
  }) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringToValueConverter != null,
      'For non-string values [converter] must be provided. TInput type: $T',
    );
    final converter = stringToValueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(value);

      _scheduleAsyncValidation();

      final result = ValueEquality.equals(convertedValue, this.value)
          ? validatorResult
          : validatorInstance.validate(convertedValue);

      return !result.isValidWithSeverity(severity)
          ? _translate(delimiter: delimiter, customError: result, severity: severity)
          : null;
    } on ConvertError<T> catch (e) {
      return _translate(delimiter: delimiter, customError: e, severity: severity);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  ///
  /// Triggers asynchronous validation of the input's current value.
  /// The [value] argument is only used for the synchronous message.
  String? textFormFieldInputValidator(
    String? value, {
    ValidationSeverity severity = .error,
    String delimiter = '.',
  }) => textFormFieldInputValidatorCustom(value, severity: severity, delimiter: delimiter);

  /// Shorthand validator for Form field input.
  ///
  /// Returns translated validation message. Triggers asynchronous validation of the input's current value.
  String? formFieldValidator(
    T value, {
    ValidationSeverity severity = .error,
    String delimiter = '.',
  }) {
    _scheduleAsyncValidation();

    final result = ValueEquality.equals(value, this.value) ? validatorResult : validatorInstance.validate(value);

    return result.isNotValid ? _translate(customError: result, severity: severity, delimiter: delimiter) : null;
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
    _asyncRunner?.invalidate();

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

    _asyncRunner?.invalidate();

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
    ValidationTranslator<T>? validationTranslate,
    T? value,
    bool? isPure,
    DefaultValidationTranslations? defaultValidationTranslations,
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
      validationTranslate: validationTranslate ?? this.validationTranslate,
      isPure: isPure ?? this.isPure,
      defaultValidationTranslations: defaultValidationTranslations ?? this.defaultValidationTranslations,
      onChange: onChange ?? this.onChange,
      onDependencyChange: onDependencyChange ?? this.onDependencyChange,
      textEditingController: textEditingController ?? _textEditingController,
      valueTransform: valueTransform ?? _valueTransform,
      trackUnchanged: trackUnchanged ?? this.trackUnchanged,
    );
  }

  /// Releases input's resources.
  ///
  /// Disposes [controller] but only when it was created by the input itself.
  /// Externally provided controller is left untouched and its owner is responsible for disposing it.
  ///
  /// Called automatically by `GladeModel.dispose()`. Repeated calls are no-op.
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    _asyncRunner?.invalidate();

    _textEditingController?.removeListener(_onTextControllerChange);

    if (_ownsTextEditingController) _textEditingController?.dispose();
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

    if (!ValueEquality.equals(_previousValue, _value)) {
      _asyncRunner?.onValueChanged();
      _scheduleAsyncValidation();
    }

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

  void _scheduleAsyncValidation() {
    final runner = _asyncRunner;

    if (runner == null || hasConversionError || _isDisposed) return;
    if (!validatorInstance.shouldRunAsyncParts(validatorInstance.validate(value))) return;

    runner.schedule(value);
  }

  void _onAsyncValidationCompleted() {
    if (_isDisposed) return;

    _bindedModel?.notifyInputValidationUpdated(this);
  }

  bool _applyAsyncMode(ValidatorResult<T> result, bool isValidByKnownResults) {
    if (!isValidByKnownResults || !result.isValidating) return isValidByKnownResults;

    return _asyncValidationMode == .lastKnown;
  }

  // *
  // * Translation methods
  // *

  /// Translates input's errors (validation or conversion).
  String? _translate({
    String delimiter = '.',
    Object? customError,
    ValidationSeverity severity = .error,
  }) {
    final err = customError ?? validatorResult;

    if (err is ValidatorResult<T> && err.isValidWithSeverity(severity)) return null;

    if (err is ValidatorResult<T>) {
      return _translateGenericValidation(err, delimiter, severity: severity);
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
    final defaultTranslationsTmp = defaultValidationTranslations;
    final translateTmp = validationTranslate;
    final defaultConversionMessage = defaultTranslationsTmp?.defaultConversionMessage;

    if (translateTmp != null) {
      return translateTmp(err, err.key, err.devMessage, dependenciesFactory());
    } else if (defaultConversionMessage != null) {
      return defaultConversionMessage;
    } else if (_bindedModel case final model?) {
      return model.defaultValidationTranslate(err, err.key, err.devMessage, dependenciesFactory());
    }

    return err.devMessage;
  }

  String _translateGenericValidation(
    ValidatorResult<T> validatorResult,
    String delimiter, {
    ValidationSeverity severity = .error,
  }) {
    final translateTmp = validationTranslate;

    final results = switch (severity) {
      .error => validatorResult.errors,
      // * Warning + Error
      .warning => validatorResult.all,
    };

    final defaultTranslationsTmp = defaultValidationTranslations;
    if (translateTmp != null) {
      return results.map((e) => translateTmp(e, e.key, e.devValidationMessage, dependenciesFactory())).join(delimiter);
    }

    return results
        .map((e) {
          if (defaultTranslationsTmp != null &&
              (e.isNullError || e.hasStringEmptyOrNullErrorKey || e.hasNullValueOrEmptyValueKey)) {
            return defaultTranslationsTmp.defaultValueIsNullOrEmptyMessage ?? e.toString();
          } else if (defaultTranslationsTmp?.defaultAsyncValidationFailedMessage case final message?
              when e.isAsyncValidationFailedError) {
            return message;
          } else if (_bindedModel case final model?) {
            return model.defaultValidationTranslate(e, e.key, e.devValidationMessage, dependenciesFactory());
          }

          return e.toString();
        })
        .join(delimiter);
  }
}
