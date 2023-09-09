import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

typedef SatisfyPredicate<T> = bool Function(T? value, Object? extra);

class SatisfyPredicatePart<T> extends InputValidatorPart<T> {
  final OnError<T> devError;

  // ignore: no-object-declaration, extra can be any object
  final Object? extra;

  final SatisfyPredicate<T> predicate;

  const SatisfyPredicatePart({
    required this.predicate,
    required this.devError,
    this.extra,
    super.key,
  });

  @override
  GenericValidatorError<T>? validate(T? value, {required Object? extra}) {
    return predicate(value, extra)
        ? null
        : ValueSatisfyPredicateError<T>(
            value: value,
            devError: devError,
            extra: extra,
            key: key,
          );
  }
}
