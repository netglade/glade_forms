import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/generic_input.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

class ValidatorErrors<T> extends Equatable {
  final GenericInput<T> associatedInput;
  final List<GenericValidatorError<T>> errors;

  bool get isValid => errors.isEmpty;

  @override
  List<Object?> get props => [associatedInput, errors];

  const ValidatorErrors({
    required this.errors,
    required this.associatedInput,
  });
}
