import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';
import 'package:glade_forms/src/validator/validator_result.dart';

/// Holds asynchronous validation state of one input: debounce, in-flight request, cached result.
///
/// The cache is always for the input's current value, because [onValueChanged] drops it.
/// Responses of runs started before the last [onValueChanged] or [invalidate] are discarded.
@internal
class AsyncValidationRunner<T> {
  final ValidatorInstance<T> _validatorInstance;

  /// Called after an accepted result was stored in the cache.
  final VoidCallback _onCompleted;

  int _sequence = 0;

  Timer? _debounceTimer;

  Completer<ValidatorResult<T>>? _inFlight;

  ValidatorResult<T>? _cache;

  bool _isPending = false;

  /// Asynchronous validation is scheduled or running.
  bool get isValidating => _isPending;

  /// Result of the last accepted asynchronous validation, or `null` when there is none.
  ValidatorResult<T>? get cachedResult => _cache;

  AsyncValidationRunner({required ValidatorInstance<T> validatorInstance, required VoidCallback onCompleted})
    : _validatorInstance = validatorInstance,
      _onCompleted = onCompleted;

  /// Value changed: cached result and any scheduled or running validation no longer apply.
  void onValueChanged() {
    _sequence++;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _inFlight = null;
    _cache = null;
    _isPending = false;
  }

  /// Requests validation of [value] after the configured debounce.
  ///
  /// No-op when a result is cached or a validation is already scheduled or running.
  void schedule(T value) {
    if (_cache != null || _inFlight != null || _debounceTimer != null) return;

    _isPending = true;

    final debounce = _validatorInstance.asyncDebounce;

    if (debounce == .zero) {
      unawaited(_run(value));

      return;
    }

    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      unawaited(_run(value));
    });
  }

  /// Validates [value] immediately, skipping the debounce.
  ///
  /// Returns the cached result when present and joins a running validation instead of starting a new one.
  Future<ValidatorResult<T>> runNow(T value) {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (_cache case final cache?) return Future.value(cache);
    if (_inFlight case final inFlight?) return inFlight.future;

    _isPending = true;

    return _run(value);
  }

  /// Drops cache and discards running validation. Used on reset and dispose.
  void invalidate() => onValueChanged();

  Future<ValidatorResult<T>> _run(T value) async {
    final sequence = _sequence;
    final completer = Completer<ValidatorResult<T>>();
    _inFlight = completer;

    final result = await _validatorInstance.validateAsync(value);

    if (sequence == _sequence) {
      _cache = result;
      _inFlight = null;
      _isPending = false;
      _onCompleted();
    }

    completer.complete(result);

    return result;
  }
}
