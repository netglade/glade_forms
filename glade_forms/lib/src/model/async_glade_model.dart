import 'dart:async';

import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

abstract class AsyncGladeModel extends GladeModelBase {
  bool _isInitialized = false;

  @override
  String get formattedValidationErrors => throw UnsupportedError('Use [formattedValidationErrorsAsync] version');

  @override
  List<ValidatorResult<Object?>> get errors => throw UnsupportedError('Use [errorsAsync]');

  @override
  String get debugFormattedValidationErrors => throw UnsupportedError('Use [debugFormattedValidationErrorsAsync]');

  @override
  bool get isInitialized => _isInitialized;

  AsyncGladeModel() {
    initializeAsync().ignore();
  }

  @override
  @protected
  @mustCallSuper
  void initialize() {
    throw UnsupportedError('Use [initializeAsync]');
  }

  @protected
  @mustCallSuper
  Future<void> initializeAsync() async {
    await initializeInputs();

    assert(
      inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
      'Model contains inputs with duplicated key!',
    );

    for (final input in inputs) {
      input.bindToModel(this);
    }

    _isInitialized = true;
    notifyListeners();

    return Future.value();
  }

  Future<void> initializeInputs();
}
