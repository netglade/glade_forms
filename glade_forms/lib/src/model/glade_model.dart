import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends ChangeNotifier {
  bool get isValid => inputs.every((input) => input.isValid);

  bool get isNotValid => !isValid;

  bool get isPure => inputs.every((input) => input.isPure);

  bool get isUnchanged => inputs.every((input) => input.isUnchanged);

  bool get isDirty => !isPure;

  List<GladeInput<Object?>> get inputs;

  /// Formats errors from `inputs`.
  String get formattedValidationErrors => inputs.map((e) {
        if (e.hasConversionError) return '${e.inputKey ?? e.runtimeType} - CONVERSION ERROR';

        if (e.validatorResult.isInvalid) {
          return '${e.inputKey ?? e.runtimeType} - ${e.errorFormatted()}';
        }

        return '${e.inputKey ?? e.runtimeType} - VALID';
      }).join('\n');

  List<Object?> get errors => inputs.map((e) => e.validatorResult).toList();

  GladeModel() {
    initialize();
  }

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @mustBeOverridden
  @protected
  void initialize() {
    for (final input in inputs) {
      input.bindToModel(this);
    }
  }

  /// Updates model's input with String? value using its converter.
  void stringFieldUpdateInput<INPUT extends GladeInput<Object?>>(INPUT input, String? value) {
    if (input.value == value) return;

    input.updateValueWithString(value);
    notifyListeners();
  }

  /// Updates model's input value.
  void updateInput<INPUT extends GladeInput<T?>, T>(INPUT input, T value) {
    if (input.value == value) return;

    input.value = value;
    notifyListeners();
  }

  @internal
  void notifyInputUpdated() => notifyListeners();
}
