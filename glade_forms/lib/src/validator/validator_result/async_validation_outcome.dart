import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';
import 'package:meta/meta.dart';

/// Results of asynchronous validator parts together with the information whether any part threw.
@internal
class AsyncValidationOutcome<T> {
  /// Results produced by asynchronous parts, in the order the parts ran.
  final List<GladeValidatorResult<T>> results;

  /// At least one part threw and its outcome comes from the error handling path.
  ///
  /// Such an outcome describes an infrastructure failure, not the value itself, so it is not cached as final.
  final bool hasFailure;

  const AsyncValidationOutcome({required this.results, required this.hasFailure});
}
