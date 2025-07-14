import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

typedef SatisfyPredicate<T> = bool Function(T value);

class SatisfyPredicatePart<T> extends InputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final OnValidateError<T> devError;

  // ignore: prefer-correct-callback-field-name, ok name
  final SatisfyPredicate<T> predicate;

  // ignore: no-object-declaration, metaData can be any object
  final Object? metaData;

  const SatisfyPredicatePart({
    required this.predicate,
    required this.devError,
    super.key,
    super.shouldValidate,
    this.metaData,
  });

  @override
  GladeValidatorError<T>? validate(T value) {
    return predicate(value)
        ? null
        : ValueSatisfyPredicateError<T>(
            value: value,
            devError: devError,
            key: key,
          );
  }
}
