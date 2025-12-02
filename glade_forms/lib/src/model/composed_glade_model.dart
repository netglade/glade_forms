import 'package:flutter/material.dart';
import 'package:glade_forms/src/src.dart';

import 'package:glade_forms/src/validator/validator_result.dart';

abstract class ComposedGladeModel<M extends GladeModel> extends ChangeNotifier {
  final List<M> _models = [];

  /// Returns true if all models are valid.
  bool get isValid => models.every((model) => model.isValid);

  bool get isValidWithoutWarnings => models.every((model) => model.isValidWithoutWarnings);

  /// Returns true if any model is not valid.
  bool get isNotValid => !isValid;

  bool get isPure => models.every((model) => model.isPure);

  /// Returns true if model is not pure.
  bool get isDirty => !isPure;

  /// Returns true if all models have unchanged inputs.
  ///
  /// Input is unchanged if its value is same as initial value, even if value was updated into initial value.
  bool get isUnchanged => models.every((model) => model.isUnchanged);

  List<M> get models => _models;

  List<ValidatorResult<Object?>> get validatorResults => [
        for (final e in models) ...e.validatorResults,
      ];

  ComposedGladeModel([List<M>? initialModels]) {
    if (initialModels != null) {
      for (final model in initialModels) {
        addModel(model);
      }
    }
  }

  void addModel(M model) {
    _models.add(model);
    model.addListener(notifyListeners);
    notifyListeners();
  }

  void removeModel(M model) {
    model.removeListener(notifyListeners);
    final _ = _models.remove(model);
    notifyListeners();
  }
}
