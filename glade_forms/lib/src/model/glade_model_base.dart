import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/devtools/devtools_registry.dart';
import 'package:glade_forms/src/src.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

abstract class GladeModelBase extends ChangeNotifier {
  List<GladeInput<Object?>> lastUpdates = [];
  final List<GladeComposedModel> _bindedComposeModels = [];
  String? _devtoolsId;

  /// Unique identifier for the model instance.
  ///
  /// Used for DevTools inspection.
  String get debugKey => runtimeType.toString();

  bool get isValid;

  bool get isValidWithoutWarnings;

  bool get isPure;

  bool get isUnchanged;

  List<ValidatorResult<Object?>> get validatorResults;

  bool get isNotValid => !isValid;

  bool get isDirty => !isPure;

  List<String> get lastUpdatedInputKeys => lastUpdates.map((e) => e.inputKey).toList();

  /// Binds current model to compose model.
  void bindToComposedModel(GladeComposedModel model) {
    _bindedComposeModels.add(model);
  }

  /// Unbinds current model from compose model.
  bool unbindFromComposedModel(GladeComposedModel model) {
    return _bindedComposeModels.remove(model);
  }

  /// Registers this model with DevTools for inspection.
  void registerWithDevTools() {
    if (kReleaseMode) return;

    final devtoolsId = '${runtimeType}_${identityHashCode(this)}';
    _devtoolsId = devtoolsId;
    GladeFormsDevToolsRegistry().registerModel(devtoolsId, this);
  }

  @override
  void dispose() {
    if (_devtoolsId != null) {
      GladeFormsDevToolsRegistry().unregisterModel(_devtoolsId!);
    }

    // Iterate over a copy to avoid concurrent modification
    for (final composeModel in _bindedComposeModels.toList()) {
      composeModel.removeModel(this);
    }

    super.dispose();
  }
}
