import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

class ChangesInfo<T> extends Equatable {
  final String inputKey;
  final T? initialValue;
  final T? previousValue;

  /// Currently set value.
  final T value;
  final ValidatorResult<T>? validatorResult;

  @override
  List<Object?> get props => [initialValue, previousValue, value, validatorResult, inputKey];

  const ChangesInfo({
    required this.inputKey,
    required this.previousValue,
    required this.value,
    required this.validatorResult,
    required this.initialValue,
  });
}
