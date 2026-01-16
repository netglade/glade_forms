import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

/// Information about changes in the input.
class ChangesInfo<T> with EquatableMixin {
  /// Key of the input.
  final String inputKey;

  /// Initial value of the input.
  final T? initialValue;

  /// Previous value of the input.
  final T? previousValue;

  /// Currently set value.
  final T value;

  /// Validation result of the input.
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
