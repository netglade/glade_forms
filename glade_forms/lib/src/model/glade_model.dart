import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends ChangeNotifier {
  List<GladeInput<Object?>> _lastUpdates = [];
  bool _groupEdit = false;

  bool get isValid => inputs.every((input) => input.isValid);

  bool get isNotValid => !isValid;

  bool get isPure => inputs.every((input) => input.isPure);

  bool get isUnchanged => inputs.where((input) => input.trackUnchanged).every((input) => input.isUnchanged);

  bool get isDirty => !isPure;

  ErrorTranslator<Object?> get defaultErrorTranslate => (error, key, devMessage, dependencies) => devMessage;

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
  String get formattedValidationErrors => inputs
      .map((e) {
        if (e.validatorResult.isInvalid) {
          return e.errorFormatted();
        }

        return '';
      })
      .where((element) => element.isNotEmpty)
      .join('\n');

  String get debugFormattedValidationErrors => inputs.map((e) {
        if (e.hasConversionError) return '${e.inputKey} - CONVERSION ERROR';

        if (e.validatorResult.isInvalid) {
          return '${e.inputKey} - ${e.errorFormatted()}';
        }

        return '${e.inputKey} - VALID';
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
    assert(
      inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
      'Model contains inputs with duplicated key!',
    );

    for (final input in allInputs) {
      input.bindToModel(this);
    }
  }

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
      notifyDependecies();
      notifyListeners();
    }
  }

  /// Use it to update multiple inputs at once before these changes are popragated through notifyListeners().
  void groupEdit(VoidCallback edit) {
    _groupEdit = true;

    edit();

    _groupEdit = false;

    notifyDependecies();

    notifyListeners();
  }

  void notifyDependecies() {
    final updatedKeys = _lastUpdates.map((e) => e.inputKey);
    for (final input in inputs) {
      final union = input.dependencies.map((e) => e.inputKey).toSet().union(updatedKeys.toSet());

      if (union.isNotEmpty) input.onDependencyChange?.call(union.toList());
    }
  }
}
