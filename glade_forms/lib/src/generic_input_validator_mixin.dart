import 'package:glade_forms/src/base_input.dart';

mixin GenericInputValidatorMixin<T, E> on BaseInput<T?, E> {
  String? formFieldValidator(T? value, {String delimiter = '.'}) {
    final convertedError = validator(value);

    return convertedError != null ? translate(delimiter: delimiter, customError: convertedError) : null;
  }
}
