import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_error/validator_error.dart';

typedef SatisfyPredicate<T> = bool Function(T value, Object? extra, InputDependencies dependencies);
typedef SatisfyPredicateAsync<T> = Future<bool> Function(T value, Object? extra, InputDependencies dependencies);

class SatisfyPredicatePart<T> extends InputValidatorPart<T> {
  final OnValidateError<T> devError;

  // ignore: no-object-declaration, extra can be any object
  final Object? extra;

  final SatisfyPredicate<T> predicate;

  const SatisfyPredicatePart({
    required this.predicate,
    required this.devError,
    required super.dependencies,
    this.extra,
    super.key,
  });

  @override
  GladeValidatorError<T>? validate(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) {
    return predicate(value, extra, dependencies)
        ? null
        : ValueSatisfyPredicateError<T>(
            value: value,
            devError: devError,
            extra: extra,
            key: key,
          );
  }

  @override
  Future<GladeValidatorError<T>?> validateAsync(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) {
    return Future.value(validate(value, extra: extra, dependencies: dependencies));
  }
}

class SatisfyPredicatePartAsync<T> extends InputValidatorPart<T> {
  final OnValidateError<T> devError;

  // ignore: no-object-declaration, extra can be any object
  final Object? extra;

  final SatisfyPredicateAsync<T> predicate;

  const SatisfyPredicatePartAsync({
    required this.predicate,
    required this.devError,
    required super.dependencies,
    this.extra,
    super.key,
  });

  @override
  GladeValidatorError<T> validate(T value, {required Object? extra, InputDependencies dependencies = const []}) {
    throw UnsupportedError('Use [validateAsync] in SatisfyPredicatePartAsync');
  }

  @override
  Future<GladeValidatorError<T>?> validateAsync(
    T value, {
    required Object? extra,
    InputDependencies dependencies = const [],
  }) async {
    return (await predicate(value, extra, dependencies))
        ? null
        : ValueSatisfyPredicateError<T>(
            value: value,
            devError: devError,
            extra: extra,
            key: key,
          );
  }
}
