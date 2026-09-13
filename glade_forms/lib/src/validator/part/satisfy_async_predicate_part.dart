import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/validator_error.dart';

/// Asynchronous predicate which the value has to satisfy.
typedef AsyncSatisfyPredicate<T> = Future<bool> Function(T value);

/// Asynchronous part requiring that value satisfies [predicate].
class SatisfyAsyncPredicatePart<T> extends AsyncInputValidatorPart<T> {
  /// Developer message used when [predicate] is not satisfied.
  // ignore: prefer-correct-callback-field-name, ok name
  final OnValidate<T> devMessage;

  /// Asynchronous predicate which the value has to satisfy.
  // ignore: prefer-correct-callback-field-name, ok name
  final AsyncSatisfyPredicate<T> predicate;

  /// Additional data associated with this part.
  // ignore: no-object-declaration, metaData can be any object
  final Object? metaData;

  const SatisfyAsyncPredicatePart({
    required this.predicate,
    required this.devMessage,
    super.key,
    super.shouldValidate,
    this.metaData,
    super.serverity,
    super.runOnlyWhenSyncValid,
    super.onError,
  });

  @override
  Future<GladeValidatorResult<T>?> validate(T value) async {
    final satisfied = await predicate(value);

    return satisfied
        ? null
        : ValueSatisfyPredicateError<T>(value: value, devMessage: devMessage, key: key, errorServerity: serverity);
  }
}
