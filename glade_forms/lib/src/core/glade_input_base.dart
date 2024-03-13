import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/changes_info.dart';
import 'package:glade_forms/src/core/input_dependencies.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:glade_forms/src/validator/validator.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

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
typedef StringValidatorFactory = ValidatorInstance<String?> Function(StringValidator validator);
typedef OnChange<T> = void Function(ChangesInfo<T> info, InputDependencies dependencies);
typedef ValueTransform<T> = T Function(T input);

abstract class GladeInputBase<T> extends ChangeNotifier {
  /// An input's identification.
  ///
  /// Used within listener changes and dependency related funcions such as validation.
  final String inputKey;

  bool get isValid;
  Future<bool> get isValidAsync;
  bool get isPure;
  bool get isUnchanged;
  bool get isChanging;
  bool get hasConversionError;

  bool get isNotValid => !isValid;
  Future<bool> get isNotValidAsync async => !(await isValidAsync);

  T get value;

  InputDependencies get dependencies;

  ValidatorResult<T> get validatorResult;

  Future<ValidatorResult<T>> get validatorResultAsync;

  GladeInputBase({required String? inputKey})
      : inputKey = inputKey ?? '__${T.runtimeType}__${Random().nextInt(100000000)}';

  String errorFormatted({String delimiter = '|'});

  Future<String> errorFormattedAsync({String delimiter = '|'});

  void updateValue(T value);
  Future<void> updateValueAsync(T value);

  void updateValueWithString(String? strValue);
  Future<void> updateValueWithStringAsync(String? strValue);

  void bindToModel(GladeModelBase model);
}
