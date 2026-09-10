import 'package:glade_forms/src/src.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

abstract class GladeComposedModel<M extends GladeModelBase> extends GladeModelBase {
  final List<M> _models = [];

  /// Returns true if all models are valid.
  @override
  bool get isValid => models.every((model) => model.isValid);

  @override
  bool get isValidWithoutWarnings => models.every((model) => model.isValidWithoutWarnings);

  @override
  bool get isPure => models.every((model) => model.isPure);

  /// Returns true if model is not pure.
  @override
  bool get isDirty => !isPure;

  /// Returns true if all models have unchanged inputs.
  ///
  /// Input is unchanged if its value is same as initial value, even if value was updated into initial value.
  @override
  bool get isUnchanged => models.every((model) => model.isUnchanged);

  /// Models that this composed model is currently listening to.
  List<M> get models => _models;

  @override
  List<ValidatorResult<Object?>> get validatorResults => [
        for (final e in models) ...e.validatorResults,
      ];

  /// Constructor can take form models to start with.
  GladeComposedModel([List<M>? initialModels]) {
    if (initialModels != null) {
      for (final model in initialModels) {
        addModel(model, shouldNotify: false);
      }
    }
    registerWithDevTools();
  }

  /// Adds model to `models` list.
  /// Whenever form model changes, it triggers also change on this composed model.
  ///
  /// [shouldNotify] - if false, listeners are not notified about the attachment.
  /// Use it when model is attached during widget's build phase where notifying listeners is not allowed.
  void addModel(M model, {bool shouldNotify = true}) {
    _models.add(model);
    model
      ..addListener(notifyListeners)
      ..bindToComposedModel(this);

    if (shouldNotify) notifyListeners();
  }

  /// Removes model from `models` list.
  /// Also unregisters from listening to its changes.
  ///
  /// [shouldNotify] - if false, listeners are not notified about the detachment.
  void removeModel(M model, {bool shouldNotify = true}) {
    final _ = _models.remove(model);
    model
      ..removeListener(notifyListeners)
      ..unbindFromComposedModel(this);

    if (shouldNotify) notifyListeners();
  }

  @override
  void dispose() {
    // Iterate over a copy to avoid concurrent modification
    for (final model in _models.toList()) {
      model
        ..removeListener(notifyListeners)
        ..dispose();
    }
    _models.clear();
    super.dispose();
  }
}
