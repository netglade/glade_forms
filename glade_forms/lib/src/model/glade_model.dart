import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/glade_input.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends GladeModelBase<GladeInput<Object?>> {
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  GladeModel() {
    initialize();
  }

  @override
  @protected
  @mustCallSuper
  void initialize() {
    initializeInputs();

    assert(
      inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
      'Model contains inputs with duplicated key!',
    );

    for (final input in inputs) {
      input.bindToModel(this);
    }

    _isInitialized = true;
    notifyListeners();
  }

  void initializeInputs();
}
