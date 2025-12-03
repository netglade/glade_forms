import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/src.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends ChangeNotifier {
  List<GladeInput<Object?>> _lastUpdates = [];
  bool _groupEdit = false;
  final List<GladeComposedModel> _bindedComposeModels = [];

  /// Returns true if all inputs are valid.
  bool get isValid => inputs.every((input) => input.isValid);

  bool get isValidWithoutWarnings => inputs.every((input) => input.isValidAndWithoutWarnings);

  /// Returns true if any input is not valid.
  bool get isNotValid => !isValid;

  /// Returns true if all inputs are pure.
  ///
  /// Input is pure if its value is same as initial value and value was never updated.
  ///
  /// Pure can be reset when [setInputValuesAsNewInitialValues] or [resetToInitialValue] on model or its inputs are called.
  bool get isPure => inputs.every((input) => input.isPure);

  /// Returns true if model is not pure.
  bool get isDirty => !isPure;

  /// Returns true if all inputs are unchanged.
  ///
  /// Input is unchanged if its value is same as initial value, even if value was updated into initial value.
  bool get isUnchanged => inputs.where((input) => input.trackUnchanged).every((input) => input.isUnchanged);

  ValidationTranslator<Object?> get defaultValidationTranslate => (error, key, devMessage, dependencies) => devMessage;

  /// Currently tracked inputs by GladeModel.
  ///
  /// Be aware that on initialize() these input are binded to model. Later included inputs are not automatically binded.
  ///
  /// Either use [allInputs] getter to list all possible model's input or use [bindToModel] method to manually bind input.
  List<GladeInput<Object?>> get inputs;

  /// All inputs registered in GladeModel.
  ///
  /// By default equals to [inputs].
  List<GladeInput<Object?>> get allInputs => inputs;

  List<String> get lastUpdatedInputKeys => _lastUpdates.map((e) => e.inputKey).toList();

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

  List<ValidatorResult<Object?>> get validatorResults => inputs.map((e) => e.validatorResult).toList();

  GladeModel() {
    initialize();
  }

  /// Binds current model to compose model.
  void bindToComposedModel(GladeComposedModel model) {
    _bindedComposeModels.add(model);
  }

  /// Unbinds current model from compose model.
  bool unbindFromComposedModel(GladeComposedModel model) {
    return _bindedComposeModels.remove(model);
  }

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @mustBeOverridden
  @protected
  void initialize() {
    assert(
      inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
      'Model contains inputs with duplicated key!',
    );

    for (final input in allInputs) {
      input.bindToModel(this);
    }
  }

  /// Binds input to model.
  void bindToModel(GladeInput<Object?> input) => input.bindToModel(this);

  /// Updates model's input with String? value using its converter.
  void stringFieldUpdateInput<INPUT extends GladeInput<Object?>>(INPUT input, String? value) {
    if (input.value == value) return;

    input.updateValueWithString(value);
    notifyListeners();
  }

  /// Updates model's input value.
  void updateInput<INPUT extends GladeInput<T?>, T>(INPUT input, T value) {
    if (input.value == value) return;

    _lastUpdates = [input];

    input.value = value;
    notifyListeners();
  }

  @internal
  void notifyInputUpdated(GladeInput<Object?> input) {
    if (_groupEdit) {
      _lastUpdates.add(input);
    } else {
      _lastUpdates = [input];
      notifyDependencies();
      notifyListeners();
    }
  }

  /// Use it to update multiple inputs at once before these changes are popragated through notifyListeners().
  void groupEdit(VoidCallback edit) {
    _groupEdit = true;

    edit();

    _groupEdit = false;

    notifyDependencies();

    notifyListeners();
  }

  /// Notifies dependant inputs about changes.
  void notifyDependencies() {
    final updatedKeys = _lastUpdates.map((e) => e.inputKey).toSet();
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

  @override
  void dispose() {
    for (final composeModel in _bindedComposeModels) {
      composeModel.removeModel(this);
    }

    super.dispose();
  }
}
