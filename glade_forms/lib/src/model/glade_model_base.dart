import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/devtools/devtools_registry.dart';
import 'package:glade_forms/src/src.dart';

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

  /// True when any input's asynchronous validation waits for the debounce or is running.
  bool get isValidating;

  /// True when any input has an asynchronous validation request in flight.
  ///
  /// Unlike [isValidating] this is `false` while only the debounce is running.
  bool get isAsyncValidationRunning;

  List<ValidatorResult<Object?>> get validatorResults;

  bool get isNotValid => !isValid;

  bool get isDirty => !isPure;

  List<String> get lastUpdatedInputKeys => lastUpdates.map((e) => e.inputKey).toList();

  /// Runs asynchronous validation of all inputs immediately, awaits it and returns [isValid].
  ///
  /// Use it before submitting when [AsyncValidationMode.lastKnown] is used, or to validate initial values.
  Future<bool> validateAsync();

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
