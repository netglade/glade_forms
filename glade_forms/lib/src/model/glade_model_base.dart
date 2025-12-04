import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/src.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

abstract class GladeModelBase extends ChangeNotifier {
  final List<GladeInput<Object?>> _lastUpdates = [];
  final List<GladeComposedModel> _bindedComposeModels = [];

  bool get isValid;

  bool get isValidWithoutWarnings;

  bool get isPure;

  bool get isUnchanged;

  List<ValidatorResult<Object?>> get validatorResults;

  bool get isNotValid => !isValid;

  bool get isDirty => !isPure;

  List<String> get lastUpdatedInputKeys => _lastUpdates.map((e) => e.inputKey).toList();

  /// Binds current model to compose model.
  void bindToComposedModel(GladeComposedModel model) {
    _bindedComposeModels.add(model);
  }

  /// Unbinds current model from compose model.
  bool unbindFromComposedModel(GladeComposedModel model) {
    return _bindedComposeModels.remove(model);
  }

  @override
  void dispose() {
    for (final composeModel in _bindedComposeModels) {
      composeModel.removeModel(this);
    }
    super.dispose();
  }
}
