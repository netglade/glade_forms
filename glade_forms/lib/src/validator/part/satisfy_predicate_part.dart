import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/validator_error.dart';

typedef SatisfyPredicate<T> = bool Function(T value);

class SatisfyPredicatePart<T> extends InputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final OnValidate<T> devMessage;

  // ignore: prefer-correct-callback-field-name, ok name
  final SatisfyPredicate<T> predicate;

  // ignore: no-object-declaration, metaData can be any object
  final Object? metaData;

  const SatisfyPredicatePart({
    required this.predicate,
    required this.devMessage,
    super.key,
    super.shouldValidate,
    this.metaData,
    super.serverity,
  });

  @override
  GladeValidatorResult<T>? validate(T value) {
    return predicate(value)
        ? null
        : ValueSatisfyPredicateError<T>(
            value: value,
            devMessage: devMessage,
            key: key,
            errorServerity: serverity,
          );
  }
}
