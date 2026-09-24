import 'package:glade_forms/src/src.dart';
import 'package:meta/meta.dart';

abstract class GladeComposedModel<M extends GladeModelBase> extends GladeModelBase with GladeInputsOwner {
  final List<M> _models = [];

  /// Composed model's own inputs.
  ///
  /// These inputs belong to the composed model itself - e.g. a team's name standing next to the forms
  /// of its members. They are aggregated together with [models] into [isValid], [isValidWithoutWarnings],
  /// [isPure], [isUnchanged] and [validatorResults].
  ///
  /// Declare them exactly as on `GladeModel` - create the inputs in [initialize] and list them here.
  /// Never list an input which belongs to one of [models]; doing so is asserted against.
  ///
  /// Contained [models] do **not** observe these inputs - see the docs about cross-level dependencies.
  ///
  /// By default a composed model has no own inputs.
  @override
  List<GladeInput<Object?>> get inputs => const [];

  /// Returns true if all own inputs and all models are valid.
  @override
  bool get isValid => inputs.every((input) => input.isValid) && models.every((model) => model.isValid);

  /// Returns true if all own inputs and all models are valid without warnings.
  @override
  bool get isValidWithoutWarnings =>
      inputs.every((input) => input.isValidAndWithoutWarnings) && models.every((model) => model.isValidWithoutWarnings);

  /// Returns true if all own inputs and all models are pure.
  @override
  bool get isPure => inputs.every((input) => input.isPure) && models.every((model) => model.isPure);

  /// Returns true if model is not pure.
  @override
  bool get isDirty => !isPure;

  /// Returns true if all own inputs and all models have unchanged inputs.
  ///
  /// Input is unchanged if its value is same as initial value, even if value was updated into initial value.
  /// Own inputs with `trackUnchanged: false` are excluded, same as on `GladeModel`.
  @override
  bool get isUnchanged =>
      inputs.where((input) => input.trackUnchanged).every((input) => input.isUnchanged) &&
      models.every((model) => model.isUnchanged);

  /// Models that this composed model is currently listening to.
  List<M> get models => _models;

  /// Validation results of own inputs, followed by results of all [models].
  @override
  List<ValidatorResult<Object?>> get validatorResults => [
    for (final input in inputs) input.validatorResult,
    for (final model in models) ...model.validatorResults,
  ];

  /// Constructor can take form models to start with.
  GladeComposedModel([List<M>? initialModels]) {
    initialize();

    if (initialModels != null) {
      for (final model in initialModels) {
        addModel(model, shouldNotify: false);
      }
    }
    registerWithDevTools();
  }

  /// Initialize composed model's own inputs.
  ///
  /// Unlike on `GladeModel`, overriding is optional - a composed model without own inputs does not need it.
  ///
  /// Called from the constructor **before** models passed into it are attached, so [models] is still
  /// empty here.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @protected
  @override
  void initialize() => super.initialize();

  /// Adds model to `models` list.
  /// Whenever form model changes, it triggers also change on this composed model.
  ///
  /// [shouldNotify] - if false, listeners are not notified about the attachment.
  /// Use it when model is attached during widget's build phase where notifying listeners is not allowed.
  void addModel(M model, {bool shouldNotify = true}) {
    _models.add(model);

    assert(_acceptsAddedModel(model), '''
Model ${model.runtimeType} shares an input with composed model $runtimeType.
A composed model must list only its own inputs in `inputs`/`allInputs`.
Inputs of a contained model are aggregated through that model itself.''');

    model
      ..addListener(_onModelsChanged)
      ..bindToComposedModel(this);

    if (shouldNotify) _onModelsChanged();
  }

  /// Removes model from `models` list.
  /// Also unregisters from listening to its changes.
  ///
  /// [shouldNotify] - if false, listeners are not notified about the detachment.
  void removeModel(M model, {bool shouldNotify = true}) {
    final _ = _models.remove(model);
    model
      ..removeListener(_onModelsChanged)
      ..unbindFromComposedModel(this);

    if (shouldNotify) _onModelsChanged();
  }

  /// Sets the initial values of own inputs and of all [models] to their current values.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  @override
  void setInputValuesAsNewInitialValues({bool shouldTriggerOnChange = true}) {
    // Batched, otherwise every contained model notifies on its own and listeners are handed
    // intermediate states where a part of the form is already updated and the rest is not.
    groupEdit(() {
      for (final model in models) {
        if (model is GladeInputsOwner) {
          model.setInputValuesAsNewInitialValues(shouldTriggerOnChange: shouldTriggerOnChange);
        }
      }

      super.setInputValuesAsNewInitialValues(shouldTriggerOnChange: shouldTriggerOnChange);
    });
  }

  /// Resets own inputs and all [models] to their initial values.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  @override
  void resetToInitialValue({bool shouldTriggerOnChange = true}) {
    // Batched, otherwise every contained model notifies on its own and listeners are handed
    // intermediate states - a form half reset and half still holding its old values.
    groupEdit(() {
      for (final model in models) {
        if (model is GladeInputsOwner) {
          model.resetToInitialValue(shouldTriggerOnChange: shouldTriggerOnChange);
        }
      }

      super.resetToInitialValue(shouldTriggerOnChange: shouldTriggerOnChange);
    });
  }

  @override
  void dispose() {
    (Object, StackTrace)? failure;

    // Iterate over a copy to avoid concurrent modification
    for (final model in _models.toList()) {
      model.removeListener(_onModelsChanged);

      try {
        model.dispose();
      } on Object catch (e, stackTrace) {
        // Disposal of the remaining models must not be skipped, so the first failure is kept
        // and rethrown once everything is torn down.
        failure ??= (e, stackTrace);
      }
    }
    _models.clear();

    try {
      // Detaching from parent composed models (in super.dispose()) notifies them synchronously.
      // Own inputs must outlive those notifications, therefore they are disposed as the very last step.
      super.dispose();
    } finally {
      // In `finally` so own inputs (and their controllers) can not be leaked.
      for (final input in allInputs) {
        input.dispose();
      }
    }

    if (failure case (final error, final stackTrace)?) Error.throwWithStackTrace(error, stackTrace);
  }

  /// Whether a model which was just added may stay attached.
  ///
  /// Called from an assert, so it runs in debug mode only. The model is already in [models] so that
  /// a flattened `inputs` getter is caught too, and a rejected model is detached again before the
  /// assert fails - it must never be left half attached.
  bool _acceptsAddedModel(M model) {
    if (model is GladeInputsOwner && model.allInputs.any(allInputs.contains)) {
      final _ = _models.remove(model);

      return false;
    }

    return true;
  }

  /// Propagates a change which was not caused by composed model's own inputs - a contained model
  /// changed, or a model was attached or detached.
  ///
  /// Own [lastUpdates] are cleared, otherwise keys of the previous own-input update would be
  /// re-broadcast as if they described this change.
  ///
  /// During [groupEdit] the notification is skipped - it is folded into the single notification
  /// which `groupEdit` emits at the end of the batch.
  void _onModelsChanged() {
    if (isGroupEditing) return;

    lastUpdates = [];
    notifyListeners();
  }
}
