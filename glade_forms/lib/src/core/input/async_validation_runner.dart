import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:glade_forms/src/validator/validator_result/async_validation_state.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Holds asynchronous validation state of one input: debounce, in-flight request, cached asynchronous results.
///
/// Only results of asynchronous parts are cached. The synchronous half is recomputed on every read so that
/// a change of a dependency is never masked by a cached result.
///
/// The cache is always for the input's current value, because [onValueChanged] drops it.
/// Responses of runs started before the last [onValueChanged] or [invalidate] are discarded.
@internal
class AsyncValidationRunner<T> {
  final ValidatorInstance<T> _validatorInstance;

  /// Called (in a microtask) whenever [state] changed, so listeners can react to validation starting and finishing.
  final VoidCallback _onValidationStateChanged;

  int _sequence = 0;

  Timer? _debounceTimer;

  Completer<ValidatorResult<T>>? _inFlight;

  List<GladeValidatorResult<T>>? _cachedResults;

  /// Cached results describe a failed request, so an explicit [runNow] retries instead of reusing them.
  bool _cacheIsRetryable = false;

  AsyncValidationState _state = .notRun;

  AsyncValidationState _lastNotifiedState = .notRun;

  bool _isNotificationScheduled = false;

  /// Current state of asynchronous validation.
  AsyncValidationState get state => _state;

  /// Asynchronous validation is waiting for the debounce or running.
  bool get isValidating => _state == .debouncing || _state == .running;

  /// A request is in flight. `false` while only the debounce is running.
  bool get isRunning => _state == .running;

  /// Results of asynchronous parts for the input's current value, or `null` when there are none.
  List<GladeValidatorResult<T>>? get cachedResults => _cachedResults;

  AsyncValidationRunner({
    required ValidatorInstance<T> validatorInstance,
    required VoidCallback onValidationStateChanged,
  }) : _validatorInstance = validatorInstance,
       _onValidationStateChanged = onValidationStateChanged;

  /// Value changed: cached results and any scheduled or running validation no longer apply.
  void onValueChanged() {
    _sequence++;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _inFlight = null;
    _cachedResults = null;
    _cacheIsRetryable = false;
    _setState(.notRun);
  }

  /// Requests validation of [value] after the configured debounce.
  ///
  /// No-op when results are cached or a validation is already scheduled or running. Cached results of a failed
  /// request are kept here on purpose - retrying on every rebuild would hammer a failing server.
  void schedule(T value) {
    if (_cachedResults != null || _inFlight != null || _debounceTimer != null) return;

    final debounce = _validatorInstance.asyncDebounce;

    if (debounce == .zero) {
      unawaited(_runAndIgnoreErrors(value));

      return;
    }

    _setState(.debouncing);

    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      unawaited(_runAndIgnoreErrors(value));
    });
  }

  /// Validates [value] immediately, skipping the debounce.
  ///
  /// Joins a running validation instead of starting a new one and reuses cached results, unless they come
  /// from a failed request - those are retried.
  Future<ValidatorResult<T>> runNow(T value) {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (_inFlight case final inFlight?) return inFlight.future;

    if (_cachedResults case final cached? when !_cacheIsRetryable) {
      return Future.value(
        _validatorInstance.combineWithAsyncResults(
          _validatorInstance.validate(value),
          cached,
          asyncValidatedValue: value,
        ),
      );
    }

    return _run(value);
  }

  /// Drops cached results and discards running validation. Used on reset and dispose.
  void invalidate() => onValueChanged();

  /// Marks the current state as already broadcast, so the pending notification does not repeat it.
  void markStateNotified() => _lastNotifiedState = _state;

  Future<ValidatorResult<T>> _run(T value) {
    final completer = Completer<ValidatorResult<T>>();
    _inFlight = completer;
    _setState(.running);

    unawaited(_execute(value, _sequence, completer));

    return completer.future;
  }

  Future<void> _execute(T value, int sequence, Completer<ValidatorResult<T>> completer) async {
    try {
      final syncResult = _validatorInstance.validate(value);
      final outcome = await _validatorInstance.runAsyncParts(value, syncResult);

      if (sequence == _sequence) {
        _cachedResults = outcome.results;
        _cacheIsRetryable = outcome.hasFailure;
      }

      completer.complete(
        _validatorInstance.combineWithAsyncResults(syncResult, outcome.results, asyncValidatedValue: value),
      );
      // Catching everything on purpose - the input must never stay stuck in a validating state.
    } catch (e, stackTrace) {
      completer.completeError(e, stackTrace);
    } finally {
      if (sequence == _sequence) {
        _inFlight = null;
        _setState(_cachedResults != null ? .done : .notRun);
      }
    }
  }

  Future<void> _runAndIgnoreErrors(T value) async {
    try {
      final _ = await _run(value);
    } on Object {
      // Errors are reported to callers awaiting validateAsync(). A scheduled run has nobody to report to
      // and the input's state was already restored in _execute.
    }
  }

  void _setState(AsyncValidationState state) {
    if (_state == state) return;

    _state = state;

    if (_isNotificationScheduled) return;

    _isNotificationScheduled = true;

    // Deferred - triggers reach this from within build (form field validators), where notifying is not allowed.
    scheduleMicrotask(() {
      _isNotificationScheduled = false;

      if (_state == _lastNotifiedState) return;

      _lastNotifiedState = _state;
      _onValidationStateChanged();
    });
  }
}
