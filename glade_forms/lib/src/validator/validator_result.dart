import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/validator_error/glade_validator_error.dart';

class ValidatorResult<T> extends Equatable {
  final GladeInputBase<T>? associatedInput;
  final List<GladeValidatorError<T>> errors;

  bool get isValid => errors.isEmpty;
  bool get isInvalid => errors.isNotEmpty;

  @override
  List<Object?> get props => [associatedInput, errors];

  const ValidatorResult({
    required this.errors,
    required this.associatedInput,
  });
}
