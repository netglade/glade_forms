import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/convert_error.dart';
import 'package:glade_forms/src/core/error_translator.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/core/string_to_type_converter.dart';
import 'package:glade_forms/src/core/type_helper.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

/// isValid
/// isPure
/// isUnchanged
/// isChanging
/// inputKey
/// errorFormatted
/// validatorResult
/// bindToModel
/// canUpdate
/// updateValue

typedef ValueComparator<T> = bool Function(T? initial, T? value);
typedef ValidatorFactory<T> = ValidatorInstance<T> Function(GladeValidator<T> v);
typedef StringValidatorFactory = ValidatorInstance<String> Function(StringValidator validator);
typedef OnChange<T> = void Function(ChangesInfo<T> info);
typedef OnDependencyChange = void Function(List<String> updateInputKeys);
typedef ValueTransform<T> = T Function(T input);

abstract class GladeInputBase<T> {
  @protected
  final StringToTypeConverter<T>? stringTovalueConverter;

  /// Compares initial and current value.
  @protected
  // ignore: prefer-correct-callback-field-name, ok name
  final ValueComparator<T>? valueComparator;

  @protected
  final ValidatorInstance<T> validatorInstance;

  /// Validation message for conversion error.
  @protected
  final DefaultTranslations? defaultTranslations;

  @protected
  final ErrorTranslator<T>? translateError;

  @protected
  final InputDependenciesFactory dependenciesFactory;

  /// Called when input's value changed.
  final OnChange<T>? onChange;

  /// Called when one of dependencies changes.
  final OnDependencyChange? onDependencyChange;

  /// Determines whether this input will be considered in isUnchanged on model.
  ///
  /// That means, when the value is false, it will opt-out this input from the computation.
  bool trackUnchanged;

  /// An input's identification.
  ///
  /// Used within listener changes and dependency related funcions such as validation.
  final String inputKey;

  @internal
  final StringToTypeConverter<T> defaultConverter = StringToTypeConverter<T>(converter: (x, _) => x as T);

  /// Transforms passed value before assigning it into input.
  @internal
  final ValueTransform<T>? valueTransform;

  /// Input is valid when tehre are no validation error.
  bool get isValid;
  Future<bool> get isValidAsync;

  /// Input's value wasn't updated yet.
  bool get isPure;

  /// Input's [value] is equal to [initialValue].
  bool get isUnchanged;
  bool get isChanging;
  bool get hasConversionError;

  bool get isNotValid => !isValid;
  Future<bool> get isNotValidAsync async => !(await isValidAsync);

  T get value;

  T? get initialValue;

  T? get previousValue;

  String get stringValue;

  InputDependencies get dependencies;

  ValidatorResult<T> get validation;

  Future<ValidatorResult<T>> get validationAsync;

  TextEditingController? get controller;

  GladeInputBase({
    required String? inputKey,
    required this.validatorInstance,
    required this.dependenciesFactory,
    required this.valueTransform,
    this.stringTovalueConverter,
    this.valueComparator,
    this.defaultTranslations,
    this.translateError,
    this.onChange,
    this.onDependencyChange,
    this.trackUnchanged = true,
  }) : inputKey = inputKey ?? '__${T.runtimeType}__${Random().nextInt(100000000)}';

  /// Used as shorthand for field setter.
  ///
  /// When `useTextEditingController` true, method will sync controller with provided value.
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValue(T value, {bool shouldTriggerOnChange = true});

  // Future<void> updateValueAsync(T value, {bool shouldTriggerOnChange = true});

  /// Used as shorthand for field setter.
  ///
  /// If `T` is non-nullable type and provided value is `null`, update is **not invoked**.
  ///
  /// When [shouldTriggerOnChange] is set to false, the `onChange` callback will not be called.
  void updateValueWhenNotNull(T? value, {bool shouldTriggerOnChange = true}) {
    if (value == null) return;

    updateValue(value, shouldTriggerOnChange: shouldTriggerOnChange);
  }

  // Future<void> updateValueWhenNotNullAsync(T? value, {bool shouldTriggerOnChange = true}) async {
  //   if (value == null) return;

  //   return updateValueAsync(value, shouldTriggerOnChange: shouldTriggerOnChange);
  // }

  void updateValueWithString(String? strValue, {bool shouldTriggerOnChange = true});

  // Future<void> updateValueWithStringAsync(String? strValue, {bool shouldTriggerOnChange = true});

  void bindToModel(GladeModelBase model);

  String errorFormatted({String delimiter = '|'});

  Future<String> errorFormattedAsync({String delimiter = '|'});

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  /// If there are multiple errors they are concenated into one string with [delimiter].
  String? textFormFieldInputValidatorCustom(String? value, {String delimiter = '.'}) {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: $T',
    );
    final converter = stringTovalueConverter ?? defaultConverter;

    try {
      final convertedValue = converter.convert(value);
      final convertedError = validatorInstance.validate(convertedValue);

      return !convertedError.isValid ? translateInternal(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (e) {
      return e.error != null ? translateInternal(delimiter: delimiter, customError: e) : e.devError(value);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  /// If there are multiple errors they are concenated into one string with [delimiter].
  Future<String?> textFormFieldInputValidatorCustomAsync(String? value, {String delimiter = '.'}) async {
    assert(
      TypeHelper.typesEqual<T, String>() || TypeHelper.typesEqual<T, String?>() || stringTovalueConverter != null,
      'For non-string values [converter] must be provided. TInput type: $T',
    );
    final converter = stringTovalueConverter ?? defaultConverter;

    try {
      final convertedValue = converter.convert(value);
      final convertedError = await validatorInstance.validateAsync(convertedValue);

      return !convertedError.isValid ? translateInternal(delimiter: delimiter, customError: convertedError) : null;
    } on ConvertError<T> catch (e) {
      return e.error != null ? translateInternal(delimiter: delimiter, customError: e) : e.devError(value);
    }
  }

  /// Shorthand validator for TextFieldForm inputs.
  ///
  /// Returns translated validation message.
  String? textFormFieldInputValidator(String? value) => textFormFieldInputValidatorCustom(value);

  Future<String?> textFormFieldInputValidatorAsync(String? value) => textFormFieldInputValidatorCustomAsync(value);

  /// Shorthand validator for Form field input.
  ///
  /// Returns translated validation message.
  String? formFieldValidator() {
    final convertedError = validation;

    return convertedError.isInvalid ? translateInternal(customError: convertedError) : null;
  }

  // *
  // * Translation methods
  // *

  String? translate({String delimiter = '.'});

  Future<String?> translateAsync({String delimiter = '.'});

  /// Translates input's errors (validation or conversion).
  @internal
  String? translateInternal({String delimiter = '.', Object? customError}) {
    final err = customError ?? validation;

    if (err is ValidatorResult<T> && err.isValid) return null;

    if (err is ValidatorResult<T>) {
      return translateGenericErrors(err, delimiter);
    }

    if (err is ConvertError<T>) {
      return translateConversionError(err);
    }

    //ignore: avoid-dynamic, ok for now
    if (err is List<dynamic>) {
      return err.map((x) => x.toString()).join('.');
    }

    return err.toString();
  }

  @internal
  String translateConversionError(ConvertError<T> err) {
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

  @internal
  String translateGenericErrors(ValidatorResult<T> inputErrors, String delimiter) {
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
