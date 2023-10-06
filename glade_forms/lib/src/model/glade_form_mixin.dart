import 'package:glade_forms/src/core/glade_input.dart';

mixin GladeFormMixin {
  bool get isValid => inputs.every((input) => input.isValid);

  bool get isNotValid => !isValid;

  bool get isPure => inputs.every((input) => input.isPure);

  bool get isUnchanged => inputs.every((input) => input.isUnchanged);

  bool get isDirty => !isPure;

  List<GladeInput<Object?>> get inputs;

  /// Formats errors from `inputs`.
  String get formattedValidationErrors => inputs.map((e) {
        if (e.hasConversionError) return '${e.inputKey ?? e.runtimeType} - CONVERSION ERROR';

        if (e.validatorError?.errors.isNotEmpty ?? false) {
          return '${e.inputKey ?? e.runtimeType} - ${e.errorFormatted()}';
        }

        return '${e.inputKey ?? e.runtimeType} - VALID';
      }).join('\n');

  List<Object?> get errors => inputs.map((e) => e.validatorError).toList();
}
