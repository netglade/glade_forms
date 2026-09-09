import 'package:glade_forms/src/src.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends GladeModelBase with GladeInputsOwner {
  /// Returns true if all inputs are valid.
  @override
  bool get isValid => inputs.every((input) => input.isValid);

  @override
  bool get isValidWithoutWarnings => inputs.every((input) => input.isValidAndWithoutWarnings);

  /// Returns true if all inputs are pure.
  ///
  /// Input is pure if its value is same as initial value and value was never updated.
  ///
  /// Pure can be reset when [setInputValuesAsNewInitialValues] or [resetToInitialValue] on model or its inputs are called.
  @override
  bool get isPure => inputs.every((input) => input.isPure);

  /// Returns true if model is not pure.
  @override
  bool get isDirty => !isPure;

  /// Returns true if all inputs are unchanged.
  ///
  /// Input is unchanged if its value is same as initial value, even if value was updated into initial value.
  @override
  bool get isUnchanged => inputs.where((input) => input.trackUnchanged).every((input) => input.isUnchanged);

  @override
  List<ValidatorResult<Object?>> get validatorResults => inputs.map((e) => e.validatorResult).toList();

  GladeModel() {
    initialize();
    registerWithDevTools();
  }

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @mustBeOverridden
  @protected
  @override
  void initialize() => super.initialize();

  /// Disposes model and all its inputs (see [GladeInput.dispose]).
  @override
  void dispose() {
    for (final input in allInputs) {
      input.dispose();
    }

    super.dispose();
  }
}
