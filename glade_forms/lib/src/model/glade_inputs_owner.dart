import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/error/validation_translator.dart';
import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';

/// Adds ownership of [GladeInput]s to a model.
///
/// Mixed-in by `GladeModel`, where inputs are the model's fields, and by `GladeComposedModel`,
/// where inputs are the composed model's own fields living next to its contained models.
///
/// The mixin is applied by these two classes only - applying it to a custom [GladeModelBase]
/// descendant is not supported, because nothing would call [initialize] and the inputs would
/// never be binded to the model.
mixin GladeInputsOwner on GladeModelBase {
  bool _groupEdit = false;

  ValidationTranslator<Object?> get defaultValidationTranslate => (error, key, devMessage, dependencies) => devMessage;

  /// Currently tracked inputs by the model.
  ///
  /// Be aware that on initialize() these input are binded to model. Later included inputs are not automatically binded.
  ///
  /// Either use [allInputs] getter to list all possible model's input or use [bindToModel] method to manually bind input.
  List<GladeInput<Object?>> get inputs;

  /// All inputs registered in the model.
  ///
  /// By default equals to [inputs].
  List<GladeInput<Object?>> get allInputs => inputs;

  /// Formats errors from `inputs`.
  String get formattedValidationErrors =>
      inputs.map((e) => e.errorFormatted()).where((element) => element.isNotEmpty).join('\n');

  /// Formats errors and warnings from `inputs`.
  String get formattedValidationErrorsAndWarnings =>
      inputs.map((e) => e.errorOrWarningFormatted()).where((element) => element.isNotEmpty).join('\n');

  /// Formats errors from `inputs` with debug information.
  String get debugFormattedValidationErrors => inputs.map((e) {
    if (e.hasConversionError) return '${e.inputKey} - CONVERSION ERROR';

    if (e.validatorResult.isNotValid) {
      return '${e.inputKey} - ${e.errorFormatted()}';
    }

    return '${e.inputKey} - VALID';
  }).join('\n');

  /// Returns true if model has any debug metadata.
  bool get hasDebugMetadata => fillDebugMetadata().isNotEmpty;

  /// True while [groupEdit]'s callback is being executed.
  ///
  /// Notifications raised during a group edit are deferred into the single notification
  /// which [groupEdit] emits at the end.
  @protected
  bool get isGroupEditing => _groupEdit;

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @protected
  void initialize() {
    assert(
      inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
      '''
Model contains inputs with duplicated key!
Did you forget to override initialize() and create the model's inputs there?''',
    );

    for (final input in allInputs) {
      input.bindToModel(this);
    }
  }

  /// Binds input to model.
  void bindToModel(GladeInput<Object?> input) => input.bindToModel(this);

  /// Updates model's input with String? value using its converter.
  void stringFieldUpdateInput<INPUT extends GladeInput<Object?>>(INPUT input, String? value) {
    assert(_ownsInput(input), _foreignInputMessage(input));

    if (input.value == value) return;

    input.updateValueWithString(value);
    notifyListeners();
  }

  /// Updates model's input value.
  void updateInput<INPUT extends GladeInput<T?>, T>(INPUT input, T value) {
    assert(_ownsInput(input), _foreignInputMessage(input));

    if (input.value == value) return;

    lastUpdates = [input];

    input.value = value;
    notifyListeners();
  }

  @internal
  void notifyInputUpdated(GladeInput<Object?> input) {
    if (_groupEdit) {
      lastUpdates.add(input);
    } else {
      lastUpdates = [input];
      notifyDependencies();
      // Re-assigned on purpose: a dependency callback can update another input or a contained model,
      // and that nested notification rewrites lastUpdates. This notification is still about [input].
      lastUpdates = [input];
      notifyListeners();
    }
  }

  /// Use it to update multiple inputs at once before these changes are popragated through notifyListeners().
  void groupEdit(VoidCallback edit) {
    // Keys of previous updates do not belong to this batch. A nested groupEdit is part of the batch
    // already being accumulated, so it must not drop what the outer one collected.
    if (!_groupEdit) lastUpdates = [];

    _groupEdit = true;

    try {
      edit();
    } finally {
      // In `finally` so a throwing callback can not swallow updates which already happened - including
      // a notification of a contained model, which is deferred while the batch is open.
      _groupEdit = false;

      notifyDependencies();

      notifyListeners();
    }
  }

  /// Notifies dependant inputs about changes.
  void notifyDependencies() {
    final updatedKeys = lastUpdates.map((e) => e.inputKey).toSet();
    for (final input in inputs) {
      final updatedKeysExceptInputItself = updatedKeys.difference({input.inputKey});
      final union = input.dependencies.map((e) => e.inputKey).toSet().intersection(updatedKeysExceptInputItself);

      if (union.isNotEmpty) input.onDependencyChange?.call(union.toList());
    }
  }

  /// Sets the initial values of all inputs to their current values.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  void setInputValuesAsNewInitialValues({bool shouldTriggerOnChange = true}) {
    for (final input in inputs) {
      input.setNewInitialValueAsCurrentValue(shouldTriggerOnChange: shouldTriggerOnChange);
    }

    notifyListeners();
  }

  /// Resets all inputs in the model to their initial values.
  ///
  /// [shouldTriggerOnChange] - if true, onChange callbacks will be triggered.
  void resetToInitialValue({bool shouldTriggerOnChange = true}) {
    for (final input in inputs) {
      input.resetToInitialValue(shouldTriggerOnChange: shouldTriggerOnChange);
    }
    notifyListeners();
  }

  /// Fills debug metadata for the model.
  ///
  /// Override to provide metadata.
  /// By default returns empty map.
  Map<String, Object> fillDebugMetadata() {
    return {};
  }

  bool _ownsInput(GladeInput<Object?> input) => input.bindedModel == null || input.bindedModel == this;

  String _foreignInputMessage(GladeInput<Object?> input) =>
      '''
Input '${input.inputKey}' is owned by ${input.bindedModel.runtimeType}, not by $runtimeType.
Update the input through the model which owns it.''';
}
