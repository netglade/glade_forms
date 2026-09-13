import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Custom asynchronous validation function.
typedef CustomAsyncValidatorType<T> = Future<GladeValidatorResult<T>?> Function(T value);

/// Asynchronous part validating value through [customValidator].
class CustomAsyncValidationPart<T> extends AsyncInputValidatorPart<T> {
  /// Custom asynchronous validation function.
  // ignore: prefer-correct-callback-field-name, ok name
  final CustomAsyncValidatorType<T> customValidator;

  const CustomAsyncValidationPart({
    required this.customValidator,
    super.key,
    super.shouldValidate,
    super.serverity,
    super.runOnlyWhenSyncValid,
    super.onError,
  });

  @override
  Future<GladeValidatorResult<T>?> validate(T value) => customValidator(value);
}
