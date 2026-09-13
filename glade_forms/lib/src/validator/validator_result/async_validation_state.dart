/// State of asynchronous validation carried by `ValidatorResult`.
enum AsyncValidationState {
  /// Async validation finished; async results are part of the result lists.
  done,

  /// No async validation was run for the current value (or the input has no async validators).
  notRun,

  /// Async validation is scheduled or in flight for the current value.
  pending,
}
