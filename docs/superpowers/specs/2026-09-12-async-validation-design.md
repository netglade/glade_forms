# Async validation design

Date: 2026-09-12
Related issue: https://github.com/netglade/glade_forms/issues/12

## Goal

Allow a `GladeInput` to declare asynchronous validators (server lookups such as
"is this username available") next to the existing synchronous ones, without
introducing new input types or new widgets. Existing integration points
(`textFormFieldInputValidator`, `formFieldValidator`, `updateValue`,
`model.isValid`) keep working and gain async awareness.

Out of scope (explicitly dropped from the issue):

- `AsyncGladeModel` with async `initialize`.
- `AsyncTextField` widget.
- Model-level async validation of the whole form (cross-field, mapping of
  HTTP 422 responses). An async part has closure access to other inputs, which
  covers the common cases.

## Core idea

Flutter's `FormField.validator` is synchronous and never awaits. Async
validation is therefore split into two halves:

1. **Running** happens in the background. It is triggered by validation
   requests (value change, `validate()`, `textFormFieldInputValidator`,
   `formFieldValidator`, explicit `validateAsync()`), debounced, and its result
   is stored on the input as state together with the value it validated.
2. **Reading** stays synchronous. `textFormFieldInputValidator`,
   `validatorResult`, `isValid` and friends return the sync result merged with
   the cached async result for the current value.

When an async run finishes, the input notifies its model, the model notifies
listeners, the `Consumer` rebuilds, and `TextFormField` (with
`AutovalidateMode.always` or `.onUserInteraction` after the first interaction)
calls the validator again, which now sees the cached result.

Getters (`isValid`, `validatorResult`, `validationErrors`, ...) never trigger
an async run. Only validation requests do. This keeps the behaviour identical
to today, where getters are pure reads.

## Decisions

| Topic | Decision |
|---|---|
| Pending semantics | Configurable per model via `AsyncValidationMode`. `strict` (default): pending means `isValid == false`. `lastKnown`: pending means sync result only (cache is empty for a changed value, so there is no stale result to fall back on). Pending splits into `debouncing` and `running` so a loading indicator can ignore the debounce window. |
| Notifications | Every change of the async state notifies listeners, deferred to a microtask because triggers run inside build. Without it a spinner would never appear on the `Form.validate()` / `autovalidateMode: always` path. |
| Cache lifetime | Only results of asynchronous parts are cached; the synchronous half is recomputed on every read so a dependency change is never masked. The cache is dropped on every real value change, so its existence implies it is for the current value. |
| Failed requests | A result produced by the error path is shown but marked retryable: passive triggers do not retry (no request per frame on a failing server), an explicit `validateAsync()` does. |
| Sync first | Async parts run only when sync validation passed, configurable per part via `runOnlyWhenSyncValid` (default `true`). |
| Trigger | Validation requests trigger async runs; getters do not. Value change is always a trigger. |
| Debounce | Per `ValidatorInstance` (one timer per input), configured in `build(asyncDebounce:)`, default 300 ms, `Duration.zero` disables. Explicit `validateAsync()` bypasses it. |
| Ordering | Async parts run sequentially in declaration order, respecting `stopOnFirstError` / `stopOnFirstErrorOrWarning` among themselves. A part with `runOnlyWhenSyncValid: false` runs and reports its result even when the synchronous half already stopped - the per-part opt-out wins over the stop flags. |
| Exceptions | Per part `onError` callback returning `GladeValidatorResult<T>?` (`null` means valid), covering both the part and its `shouldValidate`. Default produces `AsyncValidationFailedError<T>` with key `GladeValidationsKeys.asyncValidationFailed`, always with severity `error` - the part's own severity describes the value, not the infrastructure. A throw outside the parts (synchronous validation) propagates to awaiting callers and never leaves the input validating. |
| Race protection | Sequence number per input. Responses whose sequence does not match the current one are discarded. No cancellation token. |
| Validated value | Every result exposes `asyncValidatedValue`, the value the async parts were run against. |

## Behaviour matrix

Rows where `strict` and `lastKnown` differ are marked with an asterisk.

| # | Scenario | strict | lastKnown | isValidating |
|---|---|---|---|---|
| 1 | Pure input, async never ran | sync result | sync result | false |
| 2 | Sync validation fails | false | false | false (async skipped when all parts are sync-first) |
| 3* | Value changed, debounce running | false | sync result | true (`debouncing`) |
| 4* | Request in flight | false | sync result | true (`running`) |
| 5 | Async done, error | false | false | false |
| 6 | Async done, valid | true | true | false |
| 7 | Async threw, default `onError` | false | false | false |
| 8 | Response for an outdated value | discarded | discarded | unchanged |
| 9 | Submit during pending | button bound to `isValid` disabled | passes unless `await model.validateAsync()` | true |
| 10 | Dependency changed, value same | caller runs `validateAsync(force: true)` | same | true after call |
| 11 | `resetToInitialValue` / `setNewInitialValue` | cache cleared, in-flight invalidated | same | false |
| 12 | Async part with severity `warning` | does not affect `isValid`, affects `isValidWithoutWarnings`; pending affects both | same | as above |
| 13 | Composed model | aggregates children `isValid` | same | any child |
| 14 | Dispose during flight | response discarded | same | false |

Trigger of the initial value depends on the form's `autovalidateMode`:

| autovalidateMode | Async for initial value runs |
|---|---|
| `.always` | on first build, when `TextFormField` calls the validator |
| `.onUserInteraction` | after the first change |
| `.disabled` | on `formKey.currentState.validate()` or on value change |

## Public API

### `GladeValidator<T>`

```dart
typedef AsyncValidateFunctionWithKey<T> =
    Future<GladeValidatorResult<T>?> Function(T value, Object? key);
typedef AsyncSatisfyPredicate<T> = Future<bool> Function(T value);
typedef OnAsyncValidationError<T> =
    GladeValidatorResult<T>? Function(T value, Object error, StackTrace stackTrace, Object? key);

void customAsync(
  AsyncValidateFunctionWithKey<T> onValidate, {
  Object? key,
  ShouldValidateCallback<T>? shouldValidate,
  ValidationSeverity severity = .error,
  bool runOnlyWhenSyncValid = true,
  OnAsyncValidationError<T>? onError,
});

void satisfyAsync(
  AsyncSatisfyPredicate<T> predicate, {
  OnValidate<T>? devMessage,
  Object? key,
  ShouldValidateCallback<T>? shouldValidate,
  Object? metaData,
  ValidationSeverity severity = .error,
  bool runOnlyWhenSyncValid = true,
  OnAsyncValidationError<T>? onError,
});

void customAsyncPart(AsyncInputValidatorPart<T> part);

ValidatorInstance<T> build({
  bool stopOnFirstError = true,
  bool stopOnFirstErrorOrWarning = false,
  Duration asyncDebounce = const Duration(milliseconds: 300),
});
```

`GladeValidator` keeps `parts` (sync) and adds `asyncParts`. `clear()` clears
both.

### Validator parts

```dart
abstract class AsyncInputValidatorPart<T> with EquatableMixin {
  final Object? key;
  final ShouldValidateCallback<T>? shouldValidate;
  final ValidationSeverity serverity;
  final bool runOnlyWhenSyncValid;
  final OnAsyncValidationError<T>? onError;

  Future<GladeValidatorResult<T>?> validate(T value);
}

class CustomAsyncValidationPart<T> extends AsyncInputValidatorPart<T> { ... }
class SatisfyAsyncPredicatePart<T> extends AsyncInputValidatorPart<T> { ... }
```

`InputValidatorPart<T>` (sync) is unchanged. `AsyncInputValidatorPart` does not
extend it because the return type differs.

### Results

```dart
enum AsyncValidationState { notRun, pending, done }

class ValidatorResult<T> {
  // existing fields unchanged
  final AsyncValidationState asyncState;   // default .notRun
  final T? asyncValidatedValue;            // set when asyncState == .done

  bool get isValidating => asyncState == .pending;
  // isValid / isNotValid / isValidWithoutWarnings keep their meaning:
  // computed from known results only, independent of the mode.

  ValidatorResult<T> copyWith({AsyncValidationState? asyncState, T? asyncValidatedValue});
}

class AsyncValidationFailedError<T> extends GladeValidatorResult<T> {
  final Object error;
  final StackTrace stackTrace;
  // key defaults to GladeValidationsKeys.asyncValidationFailed
  // devMessage defaults to 'Async validation failed: $error'
}
```

`GladeValidationsKeys` gains `asyncValidationFailed`.
`DefaultValidationTranslations` gains `defaultAsyncValidationFailedMessage`.

### `ValidatorInstance<T>`

```dart
ValidatorResult<T> validate(T value);            // unchanged: sync parts only, pure
Future<ValidatorResult<T>> validateAsync(T value);
bool get hasAsyncParts;
bool shouldRunAsyncParts(ValidatorResult<T> syncResult);
AsyncInputValidatorPart<T>? tryFindAsyncValidatorPart(Object key);
AsyncInputValidatorPart<T> findAsyncValidatorPart(Object key);
// hasDeclaredValidator searches both lists; tryFindValidatorPart / findValidatorPart stay sync-only to keep their return type
```

`validateAsync(value)`:

1. Runs sync parts exactly as `validate(value)`.
2. For each async part in declaration order: skip when `shouldValidate` returns
   false; skip when `runOnlyWhenSyncValid` and the sync result has errors.
3. Awaits the part. On exception calls `onError`; when `onError` is `null`
   produces `AsyncValidationFailedError` with the part's severity.
4. Applies `stopOnFirstError` / `stopOnFirstErrorOrWarning` among the async
   results. When the sync half already stopped (an error with
   `stopOnFirstError`, or any result with `stopOnFirstErrorOrWarning`), parts
   gated by `runOnlyWhenSyncValid` are skipped; a part declared with
   `runOnlyWhenSyncValid: false` still runs and its result is reported.
5. Returns a `ValidatorResult` with combined `all` / `errors` / `warnings`,
   `asyncState: .done`, `asyncValidatedValue: value`.

Optimisation: `validateAsync` is not scheduled at all when sync fails and every
async part has `runOnlyWhenSyncValid == true`. The input then never enters
`pending` for that value.

### `GladeInput<T>`

```dart
bool get isValidating;
bool get hasAsyncValidation;                       // validatorInstance.hasAsyncParts

Future<ValidatorResult<T>> validateAsync({bool force = false});

// Triggers (schedule an async run when there is no cache and no in-flight request):
ValidatorResult<T> validate();
String? textFormFieldInputValidator(...);
String? textFormFieldInputValidatorCustom(...);
String? formFieldValidator(...);
// plus every value change through _setValue
// All triggers are no-ops while the input has a conversion error (there is no T value to validate).

// Pure reads (never trigger):
isValid, isNotValid, isValidAndWithoutWarnings, validatorResult,
validationErrors, validationWarnings, errorFormatted(), errorOrWarningFormatted(), translate()
```

Semantics:

- `validatorResult` returns the cached result when present, otherwise the sync
  result with `asyncState` set to `.pending` when a run is scheduled or in
  flight, `.notRun` otherwise.
- `isValid` = `!hasConversionError && validatorResult.isValid && !(mode == strict && validatorResult.isValidating)`.
  `isValidAndWithoutWarnings` follows the same pattern with
  `isValidWithoutWarnings`. The mode is read from the bound model; an unbound
  input behaves as `strict`.
- `textFormFieldInputValidator` returns `null` while pending in both modes. It
  schedules the async run for the input's **current value**, not for the
  `String?` argument. With a `TextEditingController` these are identical.
- `validateAsync()` cancels the debounce timer. With a cache present and
  `force == false` it returns the cache. With a request in flight it returns
  that request's future. Otherwise it starts a run immediately. `force: true`
  invalidates first. On an input without async parts it returns the sync
  result with `asyncState: .notRun`. With a conversion error it returns the
  (empty) sync result; `isValid` stays `false` through `hasConversionError`.
- `ChangesInfo.validatorResult` carries the sync result with
  `asyncState: .pending` when async parts exist.

### `GladeModelBase`, `GladeModel`, `GladeComposedModel`

```dart
enum AsyncValidationMode { strict, lastKnown }

// GladeModelBase
bool get isValidating;
Future<bool> validateAsync();

// GladeModel
AsyncValidationMode get asyncValidationMode => .strict;   // override to change
bool get isValidating => inputs.any((i) => i.isValidating);
Future<bool> validateAsync() async {
  await Future.wait(inputs.map((i) => i.validateAsync()));
  return isValid;
}
@internal void notifyInputValidationUpdated(GladeInput<Object?> input) => notifyListeners();

// GladeComposedModel
bool get isValidating => models.any((m) => m.isValidating);
Future<bool> validateAsync();   // awaits all models, returns isValid
```

`isValid`, `isValidWithoutWarnings`, `validatorResults` on the model are
unchanged; the mode is applied by the inputs. `debugFormattedValidationErrors`
reports `VALIDATING` for pending inputs. `groupEdit` is not involved: an async
completion during a group edit only calls `notifyListeners()`.

`notifyInputValidationUpdated` exists because `notifyInputUpdated` sets
`lastUpdates` and calls `notifyDependencies`, which would fire
`onDependencyChange` on dependants even though no value changed.

Dependency-driven revalidation is explicit and mirrors sync dependencies:

```dart
onDependencyChange: (_) => unawaited(email.validateAsync(force: true)),
```

## Internal design

### `AsyncValidationRunner<T>`

New file `glade_forms/lib/src/core/input/async_validation_runner.dart`,
`@internal`. Owned by `GladeInput`, created only when
`validatorInstance.hasAsyncParts`. `GladeInput` delegates to it; the async
state does not live in `glade_input.dart`.

```dart
class AsyncValidationRunner<T> {
  int _sequence = 0;
  Timer? _debounceTimer;
  Completer<ValidatorResult<T>>? _inFlight;
  ValidatorResult<T>? _cache;
  bool _isPending = false;

  bool get isValidating => _isPending;
  ValidatorResult<T>? get cachedResult => _cache;

  void onValueChanged();                        // invalidate cache, ++sequence, cancel timer, pending = false
  void schedule(T value);                       // trigger with debounce
  Future<ValidatorResult<T>> runNow(T value);   // explicit, no debounce
  void invalidate();                            // reset / dispose
}
```

Lifecycle:

1. `_setValue` with a value different from the previous one calls
   `onValueChanged()` then `schedule(value)`. Value equality uses the same
   helper as `_valueIsSameAsInitialValue` (identical, `DeepCollectionEquality`
   for collections, `==` otherwise), extracted into a shared helper. This guard
   matters because `TextEditingController` fires on selection changes with an
   unchanged text.
2. `schedule(value)`: no-op when a cache exists or a request is in flight.
   Otherwise `_isPending = true` and the debounce timer starts.
   `Duration.zero` runs immediately.
3. Timer fires: `++_sequence`, remember it, call
   `validatorInstance.validateAsync(value)`.
4. Response: discard when the remembered sequence differs from the current
   one. Otherwise store the cache, `_isPending = false`, complete the shared
   completer, and the input calls `_bindedModel?.notifyInputValidationUpdated(this)`.
5. `runNow(value)`: cancel the timer; when a request with the current sequence
   is in flight return its future; otherwise start step 3 immediately.
6. `invalidate()`: `++_sequence`, cancel timer, clear cache, `_isPending = false`.
   Called by `resetToInitialValue`, `setNewInitialValue`, `dispose`.

`copyWith` on the input creates a fresh runner; async state is not copied.

### Value equality helper

`_valueIsSameAsInitialValue` logic moves to a small internal function (for
example `valuesEqual<T>(T? a, T? b)` in `utils`) used by both the unchanged
check and the runner guard.

## UI integration

No new widget. The contract with `TextFormField`:

- `validator: model.email.textFormFieldInputValidator` works unchanged. While
  pending it returns `null`; after completion it returns the translated async
  error through the existing translation pipeline, keyed by the part's key.
- After completion the model notifies, the `Consumer` rebuilds, and
  `TextFormField` with `.always` (or `.onUserInteraction` after the first
  interaction) re-runs the validator against the cache. With `.disabled` the
  message appears after `formKey.currentState.validate()`.
- Loading indicator is composed by the user from `input.isValidating`,
  typically as `suffixIcon`.
- A submit button bound to `model.isValid` disables itself in `strict`. In
  `lastKnown` the user awaits `model.validateAsync()` inside `onPressed`.

Widgets without `FormField` (dropdowns, pickers) go through
`model.updateInput` / `input.updateValue`, which is a trigger. They read
`input.errorFormatted()` or `input.validationErrors` for the message, as today.

## Translations

`AsyncValidationFailedError` flows through `validationTranslate` and
`defaultValidationTranslate` with key `asyncValidationFailed`. Its
`devMessage` includes `error.toString()`.
`DefaultValidationTranslations.defaultAsyncValidationFailedMessage` provides a
model-wide fallback.

## Debugging and DevTools

`GladeFormDebugInfo` and the DevTools extension show `validating` /
`asyncState` per input and whether the input has async validation.
`debugFormattedValidationErrors` prints `VALIDATING` for pending inputs.

## Testing

Pure Dart tests with `fake_async` (new dev dependency) for the debounce and
`Completer` for controlled server responses. One widget test covers the
`TextFormField` contract.

- `test/async_validator_test.dart` (`ValidatorInstance.validateAsync`):
  sequential order, `stopOnFirstError` across sync and async,
  `runOnlyWhenSyncValid` true and false, `shouldValidate`, default and custom
  `onError`, `satisfyAsync` vs `customAsync`, `hasDeclaredValidator` finds async
  keys, `asyncValidatedValue` is set.
- `test/async_input_test.dart` (input lifecycle): debounce merges rapid
  changes into one run, `Duration.zero`, race (response for an old value is
  discarded, including change-and-change-back), `validateAsync()` shares the
  in-flight request, `force: true`, unchanged value does not retrigger, reset
  and dispose invalidate, getters do not trigger, `validate()` and
  `textFormFieldInputValidator` trigger, cache is reused, `ChangesInfo`
  carries `.pending`, conversion error path.
- `test/model/async_model_test.dart`: `strict` vs `lastKnown` for every row
  of the behaviour matrix, `isValidating`, `model.validateAsync()` awaits all
  inputs, `notifyInputValidationUpdated` does not fire `onDependencyChange`,
  composed model aggregation, async part with severity `warning`, unbound
  input behaves as `strict`.
- `test/widgets/async_text_form_field_test.dart`: `.onUserInteraction` shows
  the async error after the response without further interaction; `.always`
  triggers async for the initial value on first build.

## Documentation

### docs.page

- New page `docs/async-validation.mdx` in Getting Started, right after
  Validations, added to `docs.json`. Sections: motivation, defining
  `customAsync` / `satisfyAsync`, `AsyncValidationMode` with the behaviour
  matrix, triggers vs reads and the relation to `autovalidateMode`, debounce,
  `runOnlyWhenSyncValid`, `onError`, `validateAsync(force:)` for dependencies,
  submitting in `lastKnown`, loading indicator, widgets without `FormField`.
- `validation.mdx`: one sentence and a link.
- `glade-model.mdx`: `asyncValidationMode`, `isValidating`, `validateAsync`.
- `translations.mdx`: `asyncValidationFailed` key and default message.
- `advanced/dependencies.mdx`: `validateAsync(force: true)`.
- `advanced/debugging.mdx`: async state in debug info.
- README: short paragraph with a link.

### Storybook

New group `Async validation` in `storybook/lib/main.dart`:

- **Username availability**: `TextFormField`, fake server with configurable
  delay and a list of taken usernames, spinner in `suffixIcon`. Knobs: mode
  (`strict` / `lastKnown`), debounce, server delay, "server failing" toggle to
  demonstrate `onError`. Submit button shows the mode difference live;
  `UsecaseContainer` description explains what to watch.
- **Dependency revalidation**: organisation dropdown plus email. Changing the
  organisation calls `validateAsync(force: true)`; demonstrates the trigger via
  `updateInput` without `FormField`.
- Shared fake server in `storybook/lib/shared/fake_validation_server.dart`.

### Doc comments

Every new public member gets a `///` comment describing behaviour and, where
relevant, the mode it depends on. Existing members whose behaviour is
extended (`isValid`, `validatorResult`, `validate`,
`textFormFieldInputValidator`, `formFieldValidator`) get an added sentence on
trigger vs read.

## Compatibility and release

No breaking change. All new fields and parameters have defaults. Minor version
bump with a changelog entry.
