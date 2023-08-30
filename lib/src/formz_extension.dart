import 'package:formz/formz.dart';
import 'package:glade_forms/src/generic_input.dart';

// ignore: prefer-match-file-name, file contains multiple extensions
mixin FormzErrorFormat on FormzMixin {
  /// Formats errors from `inputs`.
  String get formattedValidationErrors => inputs.map((e) {
        if (e is GenericInput) {
          if (e.error?.errors.isNotEmpty ?? false) {
            return '${e.inputName ?? e.runtimeType} - ${e.errorFormatted()}';
          }

          return '${e.inputName ?? e.runtimeType} - VALID';
        }

        return e.error.toString();
      }).join('\n');

  // ignore: avoid-dynamic, error from Formz is dynamic
  List<dynamic> get errors => inputs.map((e) => e.error).toList();
}

mixin GenericInputsFormzMixin on FormzMixin {
  /// Formz model is unchaged -> each input is unchanged.
  bool get isUnchanged => inputs.every((e) => e.isUnchanged);

  @override
  // ignore: avoid-dynamic, each Input can have different type
  List<GenericInput<dynamic>> get inputs;
}
