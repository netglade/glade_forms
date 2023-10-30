import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

class ChangesInfo<T> extends Equatable {
  final T? initialValue;
  final T? previousValue;
  final T value;
  final ValidatorResult<T>? validatorResult;

  @override
  List<Object?> get props => [initialValue, previousValue, value, validatorResult];
  const ChangesInfo({
    required this.previousValue,
    required this.value,
    required this.validatorResult,
    required this.initialValue,
  });
}
