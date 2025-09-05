import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

typedef ShouldValidateCallback<T> = bool Function(T value);

abstract class InputValidatorPart<T> extends Equatable {
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: prefer-correct-callback-field-name, name is ok.
  final ShouldValidateCallback<T>? shouldValidate;

  final ValidationSeverity serverity;

  @override
  // ignore: list-all-equatable-fields, on purpose
  List<Object?> get props => [key, serverity];

  const InputValidatorPart({this.key, this.shouldValidate, this.serverity = ValidationSeverity.error});

  GladeValidatorResult<T>? validate(T value);
}
