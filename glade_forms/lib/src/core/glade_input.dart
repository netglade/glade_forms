import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/converters/glade_type_converters.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/error_translator.dart';
import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/core/type_helper.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

typedef StringInput = GladeInput<String>;

class GladeInput<T> extends GladeInputBase<T> {
  final bool _useTextEditingController;

  /// Initial value - does not change after creating.
  T? _initialValue;

  TextEditingController? _textEditingController;

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

  bool _isChanging = false;

  GladeModelBase? _bindedModel;

  @override
  TextEditingController? get controller => _textEditingController;

  @override
  T get value => _value;

  @override
  T? get initialValue => _initialValue;

  @override
  T? get previousValue => _previousValue;

  /// String representattion of [value].
  @override
  String get stringValue => stringTovalueConverter?.convertBack(value) ?? value.toString();

  @override
  InputDependencies get dependencies => dependenciesFactory();

  @override
  ValidatorResult<T> get validation => validatorInstance.validate(value);

  @override
  Future<ValidatorResult<T>> get validationAsync => Future.value(validation);

  /// Input's value was not changed.
  @override
  bool get isPure => _isPure;

  /// [value] is equal to [initialValue].
  ///
  /// Can be dirty or pure.
  @override
  bool get isUnchanged => valueComparator?.call(initialValue, value) ?? _valueIsSameAsInitialValue;

  @override
  bool get isChanging => _isChanging;

  /// Input does not have conversion error nor validation error.
  @override
  bool get isValid => !hasConversionError && validation.isValid;

  @override
  Future<bool> get isValidAsync => Future.value(isValid);

  @override
  bool get isNotValid => !isValid;

  @override
  bool get hasConversionError => __conversionError != null;

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
    required super.validatorInstance,
    required bool isPure,
    required super.valueComparator,
    required super.inputKey,
    required super.translateError,
    required super.stringTovalueConverter,
    required InputDependenciesFactory? dependenciesFactory,
    required super.defaultTranslations,
    required super.onChange,
    required super.onDependencyChange,
    required super.valueTransform,
    T? initialValue,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
    super.trackUnchanged = true,
  })  : assert(
          dependenciesFactory == null || (onDependencyChange != null),
          'When dependencies are provided, provide onDependencyChange as well',
        ),
        _isPure = isPure,
        _value = value,
        _initialValue = initialValue,
        //       super.dependenciesFactory = dependenciesFactory ?? (() => []),
        // _valueTransform = valueTransform,
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
        _useTextEditingController = textEditingController != null ? true : useTextEditingController,
        super(dependenciesFactory: dependenciesFactory ?? (() => [])) {
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

  @override
  @internal
  // ignore: use_setters_to_change_properties, as method.
  void bindToModel(GladeModelBase model) => _bindedModel = model;

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
    OnDependencyChange? onDependencyChange,
    TextEditingController? textEditingController,
    bool useTextEditingController = false,
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
        onDependencyChange: onDependencyChange,
        textEditingController: textEditingController,
        useTextEditingController: useTextEditingController,
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

  //@Deprecated('Use validatorResult')
  //ValidatorResult<T> validate() => validatorInstance.validate(value);

  //String? translate({String delimiter = '.'}) => _translate(delimiter: delimiter, customError: validation);
  //todo: maybe into base class?
  @override
  String errorFormatted({String delimiter = '|'}) {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return translateConversionError(__conversionError!);

    return validation.isInvalid ? translate() ?? '' : '';
  }

  @override
  Future<String> errorFormattedAsync({String delimiter = '|'}) => Future.value(errorFormatted(delimiter: delimiter));

  // /// Shorthand validator for TextFieldForm inputs.
  // ///
  // /// Returns translated validation message.
  // /// If there are multiple errors they are concenated into one string with [delimiter].
  // String? textFormFieldInputValidatorCustom(String? value, {String delimiter = '.'}) {
  //   assert(
  //     TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
  //     'For non-string values [converter] must be provided. TInput type: $T',
  //   );
  //   final converter = stringTovalueConverter ?? _defaultConverter;

  //   try {
  //     final convertedValue = converter.convert(value);
  //     final convertedError = validatorInstance.validate(convertedValue);

  //     return !convertedError.isValid ? _translate(delimiter: delimiter, customError: convertedError) : null;
  //   } on ConvertError<T> catch (e) {
  //     return e.error != null ? _translate(delimiter: delimiter, customError: e) : e.devError(value);
  //   }
  // }

  // /// Shorthand validator for TextFieldForm inputs.
  // ///
  // /// Returns translated validation message.
  // String? textFormFieldInputValidator(String? value) => textFormFieldInputValidatorCustom(value);

  // /// Shorthand validator for Form field input.
  // ///
  // /// Returns translated validation message.
  // String? formFieldValidator() {
  //   final convertedError = validation;

  //   return convertedError.isInvalid ? _translate(customError: convertedError) : null;
  // }

  /// Used as shorthand for field setter.
  ///
  /// When `useTextEditingController` true, method will sync controller with provided value.
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  @override
  void updateValue(T value, {bool shouldTriggerOnChange = true}) {
    if (_useTextEditingController) {
      _syncValueWithController(value, shouldTriggerOnChange: shouldTriggerOnChange);
    } else {
      _setValue(value, shouldTriggerOnChange: shouldTriggerOnChange);
    }
  }

  @override
  Future<void> updateValueAsync(T value, {bool shouldTriggerOnChange = true}) async =>
      updateValue(value, shouldTriggerOnChange: shouldTriggerOnChange);

  @override
  void updateValueWithString(String? strValue, {bool shouldTriggerOnChange = true}) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: ${T.runtimeType}',
    );

    final converter = stringTovalueConverter ?? defaultConverter;

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

  @override
  Future<void> updateValueWithStringAsync(String? strValue, {bool shouldTriggerOnChange = true}) async =>
      updateValueWithString(strValue, shouldTriggerOnChange: shouldTriggerOnChange);

  /// Resets input into pure state.
  ///
  /// Allows to sets new initialValue and value if needed.
  /// By default ([invokeUpdate]=`true`) setting value will trigger  listeners.
  void resetToPure({ValueGetter<T>? value, ValueGetter<T>? initialValue, bool invokeUpdate = true}) {
    this._isPure = true;

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
      valueTransform: valueTransform ?? this.valueTransform,
      trackUnchanged: trackUnchanged ?? this.trackUnchanged,
    );
  }

  @mustCallSuper
  void dispose() {
    _textEditingController?.removeListener(_onTextControllerChange);
  }

  void _syncValueWithController(T value, {required bool shouldTriggerOnChange}) {
    final converter = stringTovalueConverter ?? defaultConverter;
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
    final converter = stringTovalueConverter ?? defaultConverter;

    try {
      final convertedValue = converter.convert(controller?.text);
      _setValue(convertedValue, shouldTriggerOnChange: _controllerTriggersOnChange);
    } on ConvertError<T> catch (e) {
      _conversionError = e;
    }
  }

  void _setValue(T value, {required bool shouldTriggerOnChange}) {
    _isChanging = true;
    _previousValue = _value;
    _value = _useTextEditingController ? value : (valueTransform?.call(value) ?? value);

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
          validatorResult: validation,
        ),
      );
    }
    _isChanging = false;
    _bindedModel?.notifyInputUpdated(this);
  }

  // // *
  // // * Translation methods
  // // *

  // /// Translates input's errors (validation or conversion).
  // String? _translate({String delimiter = '.', Object? customError}) {
  //   final err = customError ?? validation;

  //   if (err is ValidatorResult<T> && err.isValid) return null;

  //   if (err is ValidatorResult<T>) {
  //     return _translateGenericErrors(err, delimiter);
  //   }

  //   if (err is ConvertError<T>) {
  //     return _translateConversionError(err);
  //   }

  //   //ignore: avoid-dynamic, ok for now
  //   if (err is List<dynamic>) {
  //     return err.map((x) => x.toString()).join('.');
  //   }

  //   return err.toString();
  // }

  // String _translateConversionError(ConvertError<T> err) {
  //   final defaultTranslationsTmp = this.defaultTranslations;
  //   final translateErrorTmp = translateError;
  //   final defaultConversionMessage = defaultTranslationsTmp?.defaultConversionMessage;

  //   if (translateErrorTmp != null) {
  //     return translateErrorTmp(err, err.key, err.devErrorMessage, dependenciesFactory());
  //   } else if (defaultConversionMessage != null) {
  //     return defaultConversionMessage;
  //   }

  //   return err.devErrorMessage;
  // }

  // String _translateGenericErrors(ValidatorResult<T> inputErrors, String delimiter) {
  //   final translateErrorTmp = translateError;

  //   final defaultTranslationsTmp = this.defaultTranslations;
  //   if (translateErrorTmp != null) {
  //     return inputErrors.errors
  //         .map((e) => translateErrorTmp(e, e.key, e.devErrorMessage, dependenciesFactory()))
  //         .join(delimiter);
  //   }

  //   return inputErrors.errors.map((e) {
  //     if (defaultTranslationsTmp != null &&
  //         (e.isNullError || e.hasStringEmptyOrNullErrorKey || e.hasNullValueOrEmptyValueKey)) {
  //       return defaultTranslationsTmp.defaultValueIsNullOrEmptyMessage ?? e.toString();
  //     }

  //     return e.toString();
  //   }).join(delimiter);
  // }
}
