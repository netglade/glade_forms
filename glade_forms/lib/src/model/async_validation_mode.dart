/// How a model treats inputs whose asynchronous validation is pending.
enum AsyncValidationMode {
  /// Pending async validation is ignored; `isValid` reflects synchronous results only until async finishes.
  lastKnown,

  /// Pending async validation makes the input (and the model) invalid until it finishes.
  strict,
}
