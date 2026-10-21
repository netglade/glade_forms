/// State of asynchronous validation carried by `ValidatorResult`.
enum AsyncValidationState {
  /// Value changed and async validation is waiting for the debounce to elapse. No request is in flight yet.
  debouncing,

  /// Async validation finished; async results are part of the result lists.
  done,

  /// No async validation was run for the current value (or the input has no async validators).
  notRun,

  /// Async validation is in flight.
  running,
}
