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

typedef AsyncStringInput = AsyncGladeInput<String>;

class AsyncGladeInput<T> extends GladeInputBase<T> {
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

  // @override
  // ValidatorResult<T> get validation => validatorInstance.validate(value);

  //todo is this wanted?
  @override
  ValidatorResult<T> get validation => throw 'Use validationAsync instead';

  @override
  Future<ValidatorResult<T>> get validationAsync => validatorInstance.validateAsync(value);

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
  bool get isValid => throw 'Use isValidAsync';

  @override
  Future<bool> get isValidAsync async {
    if (hasConversionError) return false;

    return (await validationAsync).isValid;
  }

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

  AsyncGladeInput._({
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
  factory AsyncGladeInput.create({
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

    return AsyncGladeInput._(
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
  factory AsyncGladeInput.optional({
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
      AsyncGladeInput.create(
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
  factory AsyncGladeInput.required({
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
      AsyncGladeInput.create(
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

  @override
  @internal
  // ignore: use_setters_to_change_properties, as method.
  void bindToModel(GladeModelBase model) => _bindedModel = model;

  static AsyncGladeInput<int> intInput({
    required int value,
    String? inputKey,
    int? initialValue,
    ValidatorFactory<int>? validator,
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
  }) =>
      AsyncGladeInput.create(
        value: value,
        initialValue: initialValue ?? value,
        validator: validator,
        pure: pure,
        translateError: translateError,
        defaultTranslations: defaultTranslations,
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

  static AsyncGladeInput<bool> boolInput({
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
      AsyncGladeInput.create(
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

  static AsyncGladeInput<String> stringInput({
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

    return AsyncGladeInput._(
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
    throw 'Use errorFormattedAsync';
  }

  @override
  Future<String> errorFormattedAsync({String delimiter = '|'}) async {
    // ignore: avoid-non-null-assertion, it is not null
    if (hasConversionError) return translateConversionError(__conversionError!);

    final result = await validationAsync;

    return result.isInvalid ? translateInternal(delimiter: delimiter, customError: result) ?? '' : '';
  }

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
  String textFormFieldInputValidator(String? value) {
    throw UnsupportedError('Use textFormFieldInputValidatorAsync');
  }

  // @override
  // Future<void> updateValueAsync(T value, {bool shouldTriggerOnChange = true}) async =>
  //     updateValue(value, shouldTriggerOnChange: shouldTriggerOnChange);

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

  /// Used as shorthand for field setter.
  ///
  /// If `T` is non-nullable type and provided value is `null`, update is **not invoked**.
  ///
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValueWhenNotNull(T? value, {bool shouldTriggerOnChange = true}) {
    if (value == null) return;

    updateValue(value, shouldTriggerOnChange: shouldTriggerOnChange);
  }

  /// Resets input into pure state.
  ///
  /// Allows to sets new initialValue and value if needed.
  /// By default ([invokeUpdate]=`true`) setting value will trigger  listeners.
  void resetToPure({
    ValueGetter<T>? value,
    ValueGetter<T>? initialValue,
    bool invokeUpdate = true,
    bool copyValueToInitialValue = false,
  }) {
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

      if (invokeUpdate) _bindedModel?.notifyInputUpdated(this);
    }

    if (copyValueToInitialValue) {
      this._initialValue = this.value;

      if (invokeUpdate) _bindedModel?.notifyInputUpdated(this);
    }
  }

  // @protected
  // AsyncGladeInput<T> copyWith({
  //   String? inputKey,
  //   ValueComparator<T>? valueComparator,
  //   ValidatorInstance<T>? validatorInstance,
  //   StringToTypeConverter<T>? stringTovalueConverter,
  //   InputDependenciesFactory? dependenciesFactory,
  //   T? initialValue,
  //   ErrorTranslator<T>? translateError,
  //   T? value,
  //   bool? isPure,
  //   DefaultTranslations? defaultTranslations,
  //   OnChange<T>? onChange,
  //   OnDependencyChange? onDependencyChange,
  //   TextEditingController? textEditingController,
  //   // ignore: avoid-unused-parameters, it is here just to be linter happy ¯\_(ツ)_/¯
  //   bool? useTextEditingController,
  //   ValueTransform<T>? valueTransform,
  //   bool? trackUnchanged,
  // }) {
  //   return AsyncGladeInput._(
  //     value: value ?? this.value,
  //     valueComparator: valueComparator ?? this.valueComparator,
  //     validatorInstance: validatorInstance ?? this.validatorInstance,
  //     stringTovalueConverter: stringTovalueConverter ?? this.stringTovalueConverter,
  //     dependenciesFactory: dependenciesFactory ?? this.dependenciesFactory,
  //     inputKey: inputKey ?? this.inputKey,
  //     initialValue: initialValue ?? this.initialValue,
  //     translateError: translateError ?? this.translateError,
  //     isPure: isPure ?? this.isPure,
  //     defaultTranslations: defaultTranslations ?? this.defaultTranslations,
  //     onChange: onChange ?? this.onChange,
  //     onDependencyChange: onDependencyChange ?? this.onDependencyChange,
  //     textEditingController: textEditingController ?? this._textEditingController,
  //     valueTransform: valueTransform ?? this.valueTransform,
  //     trackUnchanged: trackUnchanged ?? this.trackUnchanged,
  //   );
  // }

  @mustCallSuper
  void dispose() {
    _textEditingController?.removeListener(_onTextControllerChange);
  }

  @override
  String translate({String delimiter = '.'}) => throw 'Use translateAsync';

  @override
  Future<String?> translateAsync({String delimiter = '.'}) async =>
      translateInternal(delimiter: delimiter, customError: (await validationAsync));

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
}
