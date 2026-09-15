# Async Validation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a `GladeInput` declare asynchronous validators (server lookups) next to synchronous ones, with debounce, race protection, a per-model pending policy, and unchanged `TextFormField` integration.

**Architecture:** Async parts live in the existing `ValidatorInstance` next to sync parts. `ValidatorInstance.validate()` stays a pure sync read; new `validateAsync()` runs sync parts then async parts sequentially and returns one merged `ValidatorResult`. An internal `AsyncValidationRunner` owned by `GladeInput` holds the async state (debounce timer, sequence number, cached result). Validation requests (value change, `validate()`, form field validator callbacks, explicit `validateAsync()`) trigger runs; getters only read. `GladeModel` exposes `AsyncValidationMode` (`strict` default, `lastKnown`) which the input applies in `isValid`.

**Tech Stack:** Dart 3.10 / Flutter 3.38.7 via `fvm`, `package:test`, `fake_async`, `flutter_test` (one widget test), widgetbook 3.11 storybook, docs.page (`docs/*.mdx`, `docs.json`).

**Spec:** `docs/superpowers/specs/2026-09-12-async-validation-design.md`

## Global Constraints

- All code, comments, docs, commit messages in English.
- Run Flutter/Dart through fvm: `fvm flutter test`, `fvm dart analyze`. Static analysis and DCM via the user's `checkme` alias run in `glade_forms/`; if the alias is unavailable use `fvm dart analyze . --fatal-infos && dcm analyze . --fatal-style --fatal-performance --fatal-warnings`.
- Follow existing style: Dart 3.10 dot-shorthand enum literals (`.error`, `.pending`), `// ignore:` comments with a reason, `///` doc comments on every public member, `// arrange / act / assert` comments in tests, `setUp(GladeForms.initialize)` in every test `main`.
- Git is read-only unless the user explicitly allowed commits for this run. When allowed: types `feat`/`fix`, imperative subject at most 50 chars, no trailing period, atomic commits, never mention Claude or AI in messages. When not allowed: skip every "Commit" step.
- No breaking changes. Every new constructor parameter and field has a default.
- Prefer self-documenting code over comments.
- Debounce default is `Duration(milliseconds: 300)`; `Duration.zero` disables debounce.
- The failure key is `GladeValidationsKeys.asyncValidationFailed` with string value `'async-validation-failed'`.
- Version bump: `6.1.0` to `6.2.0`.

---

## File structure

**Create**

| File | Responsibility |
|---|---|
| `glade_forms/lib/src/utils/value_equality.dart` | Shared value equality (identical / deep collection / `==`). |
| `glade_forms/lib/src/validator/validator_result/async_validation_state.dart` | `AsyncValidationState` enum. |
| `glade_forms/lib/src/validator/validator_result/async_validation_failed_error.dart` | `AsyncValidationFailedError<T>`. |
| `glade_forms/lib/src/validator/part/async_input_validator_part.dart` | Abstract async part + `OnAsyncValidationError` typedef. |
| `glade_forms/lib/src/validator/part/custom_async_validation_part.dart` | `CustomAsyncValidationPart<T>`. |
| `glade_forms/lib/src/validator/part/satisfy_async_predicate_part.dart` | `SatisfyAsyncPredicatePart<T>`. |
| `glade_forms/lib/src/core/input/async_validation_runner.dart` | Internal async state machine owned by `GladeInput`. |
| `glade_forms/lib/src/model/async_validation_mode.dart` | `AsyncValidationMode` enum. |
| `glade_forms/test/value_equality_test.dart`, `validator_result_test.dart`, `async_validator_test.dart`, `async_validation_runner_test.dart`, `async_input_test.dart`, `model/async_model_test.dart`, `widgets/async_text_form_field_test.dart` | Tests. |
| `storybook/lib/shared/fake_validation_server.dart` | Fake server shared by storybook examples. |
| `storybook/lib/usecases/async/username_availability_example.dart` | Storybook: `TextFormField` + modes + knobs. |
| `storybook/lib/usecases/async/dependency_revalidation_example.dart` | Storybook: dropdown + `validateAsync(force: true)`. |
| `docs/async-validation.mdx` | New docs page. |

**Modify**

| File | Change |
|---|---|
| `glade_forms/lib/src/validator/validator_result.dart` | `asyncState`, `asyncValidatedValue`, `isValidating`, `copyWith`. |
| `glade_forms/lib/src/validator/validator_result/validator_error.dart` | Export new files. |
| `glade_forms/lib/src/validator/part/part.dart` | Export new parts. |
| `glade_forms/lib/src/core/error/glade_validations_keys.dart` | `asyncValidationFailed`. |
| `glade_forms/lib/src/core/error/validation_translator.dart` | `defaultAsyncValidationFailedMessage`. |
| `glade_forms/lib/src/core/error/glade_input_validation.dart` | `isAsyncValidationFailedError`. |
| `glade_forms/lib/src/validator/glade_validator.dart` | `asyncParts`, `customAsync`, `satisfyAsync`, `customAsyncPart`, `build(asyncDebounce:)`. |
| `glade_forms/lib/src/validator/validator_instance.dart` | Async parts, `validateAsync`, `hasAsyncParts`, `shouldRunAsyncParts`, `asyncDebounce`, async part lookup. |
| `glade_forms/lib/src/core/input/glade_input.dart` | Runner ownership, triggers, reads, mode application, lifecycle hooks. |
| `glade_forms/lib/src/core/input/input.dart` | Export runner (internal). |
| `glade_forms/lib/src/model/model.dart`, `glade_model_base.dart`, `glade_model.dart`, `glade_composed_model.dart` | Mode, `isValidating`, `validateAsync`, `notifyInputValidationUpdated`. |
| `glade_forms/lib/src/widgets/glade_form_debug_info.dart` | `isValidating` column. |
| `glade_forms/lib/src/devtools/glade_input_dev_tools_serialization.dart`, `glade_model_devtools_serialization.dart` | `isValidating`, `asyncState`, `hasAsyncValidation`. |
| `glade_forms/pubspec.yaml`, `glade_forms/CHANGELOG.md` | Dev deps, version. |
| `storybook/lib/main.dart`, `storybook/pubspec.yaml` | New category, asset folder. |
| `docs/docs.json`, `docs/validation.mdx`, `docs/glade-model.mdx`, `docs/translations.mdx`, `docs/advanced/dependencies.mdx`, `docs/advanced/debugging.mdx`, `README.md` | Docs. |

---

### Task 1: Shared value equality helper

**Files:**
- Create: `glade_forms/lib/src/utils/value_equality.dart`
- Modify: `glade_forms/lib/src/core/input/glade_input.dart` (`_valueIsSameAsInitialValue`, around line 122)
- Test: `glade_forms/test/value_equality_test.dart`

**Interfaces:**
- Produces: `abstract final class ValueEquality { static bool equals<T>(T? a, T? b); }` in `package:glade_forms/src/utils/value_equality.dart`.

- [x] **Step 1: Write the failing test**

```dart
// glade_forms/test/value_equality_test.dart
import 'package:glade_forms/src/utils/value_equality.dart';
import 'package:test/test.dart';

void main() {
  test('identical values are equal', () {
    // arrange
    final value = Object();

    // assert
    expect(ValueEquality.equals(value, value), isTrue);
  });

  test('primitive values compare with ==', () {
    expect(ValueEquality.equals(1, 1), isTrue);
    expect(ValueEquality.equals(1, 2), isFalse);
    expect(ValueEquality.equals<String?>(null, null), isTrue);
    expect(ValueEquality.equals<String?>('a', null), isFalse);
  });

  test('collections compare deeply', () {
    expect(ValueEquality.equals([1, 2], [1, 2]), isTrue);
    expect(ValueEquality.equals([1, 2], [2, 1]), isFalse);
    expect(ValueEquality.equals({'a': 1}, {'a': 1}), isTrue);
    expect(ValueEquality.equals({1, 2}, {2, 1}), isTrue);
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd glade_forms && fvm flutter test test/value_equality_test.dart`
Expected: FAIL, `value_equality.dart` does not exist.

- [x] **Step 3: Implement helper and use it in `GladeInput`**

```dart
// glade_forms/lib/src/utils/value_equality.dart
import 'package:collection/collection.dart';

/// Equality used by inputs when comparing values (initial vs current, previous vs new).
///
/// Collections are compared deeply, everything else with `identical` and `==`.
abstract final class ValueEquality {
  static bool equals<T>(T? a, T? b) {
    if (identical(a, b)) return true;

    if (a is List || a is Map || a is Set) {
      return const DeepCollectionEquality().equals(a, b);
    }

    return a == b;
  }
}
```

In `glade_input.dart` replace the body of `_valueIsSameAsInitialValue`:

```dart
  bool get _valueIsSameAsInitialValue => ValueEquality.equals(value, initialValue);
```

Add `import 'package:glade_forms/src/utils/value_equality.dart';` and drop the now unused `package:collection/collection.dart` import if nothing else in the file uses it.

- [x] **Step 4: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test test/value_equality_test.dart test/glade_input_test.dart && checkme`
Expected: PASS, no analysis issues.

- [x] **Step 5: Commit (only if allowed)**

```bash
git add glade_forms/lib/src/utils/value_equality.dart glade_forms/lib/src/core/input/glade_input.dart glade_forms/test/value_equality_test.dart
git commit -m "feat: extract shared value equality helper"
```

---

### Task 2: Result types for async validation

**Files:**
- Create: `glade_forms/lib/src/validator/validator_result/async_validation_state.dart`
- Create: `glade_forms/lib/src/validator/validator_result/async_validation_failed_error.dart`
- Modify: `glade_forms/lib/src/validator/validator_result.dart`
- Modify: `glade_forms/lib/src/validator/validator_result/validator_error.dart`
- Modify: `glade_forms/lib/src/core/error/glade_validations_keys.dart`
- Modify: `glade_forms/lib/src/core/error/validation_translator.dart`
- Modify: `glade_forms/lib/src/core/error/glade_input_validation.dart`
- Test: `glade_forms/test/validator_result_test.dart`

**Interfaces:**
- Produces: `enum AsyncValidationState { notRun, pending, done }`.
- Produces: `ValidatorResult<T>` fields `AsyncValidationState asyncState` (default `.notRun`), `T? asyncValidatedValue`, getter `bool isValidating`, method `ValidatorResult<T> copyWith({AsyncValidationState? asyncState, T? asyncValidatedValue})`.
- Produces: `AsyncValidationFailedError<T>({required T value, required Object error, required StackTrace stackTrace, Object? partKey, OnValidate<T>? devMessage, ValidationSeverity errorServerity = .error})` with key `GladeValidationsKeys.asyncValidationFailed`.
- Produces: `GladeValidationsKeys.asyncValidationFailed = 'async-validation-failed'`.
- Produces: `DefaultValidationTranslations.defaultAsyncValidationFailedMessage`.
- Produces: `GladeInputValidation.isAsyncValidationFailedError`.

- [x] **Step 1: Write the failing test**

```dart
// glade_forms/test/validator_result_test.dart
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  setUp(GladeForms.initialize);

  test('ValidatorResult defaults to notRun async state', () {
    // arrange
    const result = ValidatorResult<int>(all: [], errors: [], warnings: [], associatedInput: null);

    // assert
    expect(result.asyncState, equals(AsyncValidationState.notRun));
    expect(result.asyncValidatedValue, isNull);
    expect(result.isValidating, isFalse);
    expect(result.isValid, isTrue);
  });

  test('copyWith changes async state and keeps results', () {
    // arrange
    final error = ValueError<int>(value: 1, devMessage: (_) => 'err', key: 'k');
    final result = ValidatorResult<int>(all: [error], errors: [error], warnings: [], associatedInput: null);

    // act
    final pending = result.copyWith(asyncState: .pending);
    final done = result.copyWith(asyncState: .done, asyncValidatedValue: 1);

    // assert
    expect(pending.isValidating, isTrue);
    expect(pending.errors, equals([error]));
    expect(done.asyncState, equals(AsyncValidationState.done));
    expect(done.asyncValidatedValue, equals(1));
    expect(pending == result, isFalse);
  });

  test('AsyncValidationFailedError has failure key and dev message', () {
    // arrange
    final exception = Exception('boom');

    // act
    final error = AsyncValidationFailedError<String>(
      value: 'a',
      error: exception,
      stackTrace: StackTrace.empty,
      partKey: 'username',
    );

    // assert
    expect(error.key, equals(GladeValidationsKeys.asyncValidationFailed));
    expect(error.partKey, equals('username'));
    expect(error.error, same(exception));
    expect(error.devValidationMessage, contains('boom'));
    expect(error.isAsyncValidationFailedError, isTrue);
    expect(error.severity, equals(ValidationSeverity.error));
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd glade_forms && fvm flutter test test/validator_result_test.dart`
Expected: FAIL, `AsyncValidationState` undefined.

- [x] **Step 3: Implement**

```dart
// glade_forms/lib/src/validator/validator_result/async_validation_state.dart
/// State of asynchronous validation carried by `ValidatorResult`.
enum AsyncValidationState {
  /// No async validation was run for the current value (or the input has no async validators).
  notRun,

  /// Async validation is scheduled or in flight for the current value.
  pending,

  /// Async validation finished; async results are part of the result lists.
  done,
}
```

```dart
// glade_forms/lib/src/validator/validator_result/async_validation_failed_error.dart
import 'package:glade_forms/src/core/error/glade_validations_keys.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Produced when an async validator throws and no custom `onError` handler was provided.
///
/// Key is always [GladeValidationsKeys.asyncValidationFailed]; the failing part's own key is in [partKey].
class AsyncValidationFailedError<T> extends GladeValidatorResult<T> {
  /// Exception thrown by the async validator.
  // ignore: no-object-declaration, error can be any object
  final Object error;

  final StackTrace stackTrace;

  /// Key of the async validator part which failed.
  // ignore: no-object-declaration, key can be any object
  final Object? partKey;

  AsyncValidationFailedError({
    required super.value,
    required this.error,
    required this.stackTrace,
    this.partKey,
    OnValidate<T>? devMessage,
    super.errorServerity,
  }) : super(
         key: GladeValidationsKeys.asyncValidationFailed,
         devMessage: devMessage ?? ((_) => 'Async validation failed: $error'),
       );
}
```

Add to `validator_error.dart`:

```dart
export 'async_validation_failed_error.dart';
export 'async_validation_state.dart';
```

Add to `GladeValidationsKeys`:

```dart
  static const String asyncValidationFailed = 'async-validation-failed';
```

Add to `DefaultValidationTranslations`:

```dart
  /// Used when an async validator threw and produced `AsyncValidationFailedError`.
  final String? defaultAsyncValidationFailedMessage;

  const DefaultValidationTranslations({
    this.defaultValueIsNullOrEmptyMessage,
    this.defaultConversionMessage,
    this.defaultAsyncValidationFailedMessage,
  });
```

Add to `GladeInputValidation` (next to `isNullError`):

```dart
  bool get isAsyncValidationFailedError => this is AsyncValidationFailedError<T>;
```

Update `validator_result.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/validator/validator_result/async_validation_state.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Complete result of validation process.
///
/// Contains synchronous results and, when [asyncState] is [AsyncValidationState.done],
/// also asynchronous results produced for [asyncValidatedValue].
class ValidatorResult<T> with EquatableMixin {
  /// Input associated with this validation result.
  final GladeInput<T>? associatedInput;

  /// All results including errors and warnings.
  ///
  /// Order is preserved by the order of validators in the input.
  final List<GladeValidatorResult<T>> all;

  /// All warnings.
  final List<GladeValidatorResult<T>> warnings;

  /// All errors.
  final List<GladeValidatorResult<T>> errors;

  /// State of asynchronous validation.
  final AsyncValidationState asyncState;

  /// Value for which async results in [all] were produced. Set only when [asyncState] is `done`.
  final T? asyncValidatedValue;

  /// Returns `true` if there are no errors among known results. Does not consider [asyncState].
  bool get isValid => errors.isEmpty;

  /// Returns `true` if there are no errors or warnings among known results. Does not consider [asyncState].
  bool get isValidWithoutWarnings => all.isEmpty;

  /// Returns `true` if there are errors.
  bool get isNotValid => errors.isNotEmpty;

  /// Async validation is scheduled or running for the current value.
  bool get isValidating => asyncState == .pending;

  @override
  List<Object?> get props => [associatedInput, all, errors, warnings, asyncState, asyncValidatedValue];

  const ValidatorResult({
    required this.all,
    required this.errors,
    required this.warnings,
    required this.associatedInput,
    this.asyncState = .notRun,
    this.asyncValidatedValue,
  });

  bool isValidWithSeverity(ValidationSeverity severity) {
    return switch (severity) {
      .error => isValid,
      .warning => isValidWithoutWarnings,
    };
  }

  ValidatorResult<T> copyWith({AsyncValidationState? asyncState, T? asyncValidatedValue}) => ValidatorResult(
    all: all,
    errors: errors,
    warnings: warnings,
    associatedInput: associatedInput,
    asyncState: asyncState ?? this.asyncState,
    asyncValidatedValue: asyncValidatedValue ?? this.asyncValidatedValue,
  );
}
```

- [x] **Step 4: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test && checkme`
Expected: PASS (existing tests unaffected, `ValidatorResult` constructor defaults keep them compiling).

- [x] **Step 5: Commit (only if allowed)**

```bash
git add glade_forms/lib glade_forms/test/validator_result_test.dart
git commit -m "feat: add async state to validator result"
```

---

### Task 3: Async validator parts and `GladeValidator` API

**Files:**
- Create: `glade_forms/lib/src/validator/part/async_input_validator_part.dart`
- Create: `glade_forms/lib/src/validator/part/custom_async_validation_part.dart`
- Create: `glade_forms/lib/src/validator/part/satisfy_async_predicate_part.dart`
- Modify: `glade_forms/lib/src/validator/part/part.dart`
- Modify: `glade_forms/lib/src/validator/glade_validator.dart`
- Modify: `glade_forms/lib/src/validator/validator_instance.dart` (constructor, lookups, `hasAsyncParts`, `asyncDebounce`)
- Test: `glade_forms/test/glade_validator_test.dart` (append a group)

**Interfaces:**
- Produces:
  ```dart
  typedef OnAsyncValidationError<T> = GladeValidatorResult<T>? Function(T value, Object error, StackTrace stackTrace, Object? key);
  typedef AsyncValidateFunctionWithKey<T> = Future<GladeValidatorResult<T>?> Function(T value, Object? key);
  typedef AsyncSatisfyPredicate<T> = Future<bool> Function(T value);
  typedef CustomAsyncValidatorType<T> = Future<GladeValidatorResult<T>?> Function(T value);

  abstract class AsyncInputValidatorPart<T> { Object? key; ShouldValidateCallback<T>? shouldValidate; ValidationSeverity serverity; bool runOnlyWhenSyncValid; OnAsyncValidationError<T>? onError; Future<GladeValidatorResult<T>?> validate(T value); }

  // GladeValidator
  List<AsyncInputValidatorPart<T>> asyncParts;
  void customAsync(AsyncValidateFunctionWithKey<T> onValidate, {Object? key, ShouldValidateCallback<T>? shouldValidate, ValidationSeverity severity = .error, bool runOnlyWhenSyncValid = true, OnAsyncValidationError<T>? onError});
  void satisfyAsync(AsyncSatisfyPredicate<T> predicate, {OnValidate<T>? devMessage, Object? key, ShouldValidateCallback<T>? shouldValidate, Object? metaData, ValidationSeverity severity = .error, bool runOnlyWhenSyncValid = true, OnAsyncValidationError<T>? onError});
  void customAsyncPart(AsyncInputValidatorPart<T> part);
  ValidatorInstance<T> build({bool stopOnFirstError = true, bool stopOnFirstErrorOrWarning = false, Duration asyncDebounce = const Duration(milliseconds: 300)});

  // ValidatorInstance
  ValidatorInstance({required List<InputValidatorPart<T>> parts, required bool stopOnFirstError, required bool stopOnFirstErrorOrWarning, List<AsyncInputValidatorPart<T>> asyncParts = const [], Duration asyncDebounce = const Duration(milliseconds: 300)});
  bool get hasAsyncParts; Duration get asyncDebounce;
  AsyncInputValidatorPart<T>? tryFindAsyncValidatorPart(Object key); AsyncInputValidatorPart<T> findAsyncValidatorPart(Object key);
  bool hasDeclaredValidator(Object key);  // now searches both lists
  ```

- [x] **Step 1: Write the failing tests**

Append to `glade_forms/test/glade_validator_test.dart` inside `main()`:

```dart
  group('async parts declaration', () {
    test('customAsync and satisfyAsync are collected into asyncParts', () {
      // arrange
      final validator = GladeValidator<String>()
        ..notNull()
        ..customAsync((value, key) async => null, key: 'custom')
        ..satisfyAsync((value) async => true, key: 'satisfy', devMessage: (_) => 'nope');

      // act
      final instance = validator.build();

      // assert
      expect(validator.parts, hasLength(1));
      expect(validator.asyncParts, hasLength(2));
      expect(instance.hasAsyncParts, isTrue);
      expect(instance.hasDeclaredValidator('custom'), isTrue);
      expect(instance.hasDeclaredValidator('satisfy'), isTrue);
      expect(instance.tryFindAsyncValidatorPart('satisfy'), isA<SatisfyAsyncPredicatePart<String>>());
      expect(instance.tryFindAsyncValidatorPart('missing'), isNull);
      expect(() => instance.findAsyncValidatorPart('missing'), throwsArgumentError);
    });

    test('build stores debounce, default is 300ms', () {
      // act
      final defaultInstance = GladeValidator<int>().build();
      final customInstance = GladeValidator<int>().build(asyncDebounce: Duration.zero);

      // assert
      expect(defaultInstance.asyncDebounce, equals(const Duration(milliseconds: 300)));
      expect(customInstance.asyncDebounce, equals(Duration.zero));
      expect(defaultInstance.hasAsyncParts, isFalse);
    });

    test('clear removes async parts as well', () {
      // arrange
      final validator = GladeValidator<int>()
        ..notNull()
        ..customAsync((value, key) async => null);

      // act
      validator.clear();

      // assert
      expect(validator.parts, isEmpty);
      expect(validator.asyncParts, isEmpty);
    });

    test('async part options are stored', () {
      // arrange
      GladeValidatorResult<int>? onError(int value, Object error, StackTrace stackTrace, Object? key) => null;
      final validator = GladeValidator<int>()
        ..customAsync(
          (value, key) async => null,
          key: 'k',
          severity: .warning,
          runOnlyWhenSyncValid: false,
          onError: onError,
        );

      // act
      final part = validator.asyncParts.single;

      // assert
      expect(part.key, equals('k'));
      expect(part.serverity, equals(ValidationSeverity.warning));
      expect(part.runOnlyWhenSyncValid, isFalse);
      expect(part.onError, same(onError));
    });
  });
```

- [x] **Step 2: Run tests to verify they fail**

Run: `cd glade_forms && fvm flutter test test/glade_validator_test.dart`
Expected: FAIL, `customAsync` undefined.

- [x] **Step 3: Implement parts**

```dart
// glade_forms/lib/src/validator/part/async_input_validator_part.dart
import 'package:equatable/equatable.dart';
import 'package:glade_forms/src/core/error/validation_severity.dart';
import 'package:glade_forms/src/validator/part/input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

/// Called when an async validator throws.
///
/// Return a result to report it as validation outcome, or `null` to treat the value as valid.
typedef OnAsyncValidationError<T> =
    GladeValidatorResult<T>? Function(T value, Object error, StackTrace stackTrace, Object? key);

/// Asynchronous counterpart of [InputValidatorPart].
///
/// Async parts run after synchronous parts, sequentially in declaration order.
abstract class AsyncInputValidatorPart<T> with EquatableMixin {
  // ignore: no-object-declaration, key can be any object
  final Object? key;

  // ignore: prefer-correct-callback-field-name, name is ok.
  final ShouldValidateCallback<T>? shouldValidate;

  final ValidationSeverity serverity;

  /// When `true` (default) the part runs only if synchronous validation produced no error.
  final bool runOnlyWhenSyncValid;

  /// Custom handling of exceptions thrown by [validate]. When `null`, `AsyncValidationFailedError` is produced.
  // ignore: prefer-correct-callback-field-name, name is ok.
  final OnAsyncValidationError<T>? onError;

  @override
  // ignore: list-all-equatable-fields, on purpose
  List<Object?> get props => [key, serverity, runOnlyWhenSyncValid];

  const AsyncInputValidatorPart({
    this.key,
    this.shouldValidate,
    this.serverity = ValidationSeverity.error,
    this.runOnlyWhenSyncValid = true,
    this.onError,
  });

  Future<GladeValidatorResult<T>?> validate(T value);
}
```

```dart
// glade_forms/lib/src/validator/part/custom_async_validation_part.dart
import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/glade_validator_result.dart';

typedef CustomAsyncValidatorType<T> = Future<GladeValidatorResult<T>?> Function(T value);

class CustomAsyncValidationPart<T> extends AsyncInputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final CustomAsyncValidatorType<T> customValidator;

  const CustomAsyncValidationPart({
    required this.customValidator,
    super.key,
    super.shouldValidate,
    super.serverity,
    super.runOnlyWhenSyncValid,
    super.onError,
  });

  @override
  Future<GladeValidatorResult<T>?> validate(T value) => customValidator(value);
}
```

```dart
// glade_forms/lib/src/validator/part/satisfy_async_predicate_part.dart
import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';
import 'package:glade_forms/src/validator/validator_result/validator_error.dart';

typedef AsyncSatisfyPredicate<T> = Future<bool> Function(T value);

class SatisfyAsyncPredicatePart<T> extends AsyncInputValidatorPart<T> {
  // ignore: prefer-correct-callback-field-name, ok name
  final OnValidate<T> devMessage;

  // ignore: prefer-correct-callback-field-name, ok name
  final AsyncSatisfyPredicate<T> predicate;

  // ignore: no-object-declaration, metaData can be any object
  final Object? metaData;

  const SatisfyAsyncPredicatePart({
    required this.predicate,
    required this.devMessage,
    super.key,
    super.shouldValidate,
    this.metaData,
    super.serverity,
    super.runOnlyWhenSyncValid,
    super.onError,
  });

  @override
  Future<GladeValidatorResult<T>?> validate(T value) async {
    final satisfied = await predicate(value);

    return satisfied
        ? null
        : ValueSatisfyPredicateError<T>(value: value, devMessage: devMessage, key: key, errorServerity: serverity);
  }
}
```

`part.dart`:

```dart
export 'async_input_validator_part.dart';
export 'custom_async_validation_part.dart';
export 'custom_validation_part.dart';
export 'input_validator_part.dart';
export 'satisfy_async_predicate_part.dart';
export 'satisfy_predicate_part.dart';
```

- [x] **Step 4: Extend `GladeValidator`**

In `glade_validator.dart` add imports for the new parts and:

```dart
typedef AsyncValidateFunctionWithKey<T> = Future<GladeValidatorResult<T>?> Function(T value, Object? key);
```

Inside the class:

```dart
  List<InputValidatorPart<T>> parts = [];

  /// Asynchronous validation parts. They run after [parts], sequentially in declaration order.
  List<AsyncInputValidatorPart<T>> asyncParts = [];

  ValidatorInstance<T> build({
    /// Returns validation result on first error or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstError = true,

    /// Returns validation result on first error (or warning) or continues validation.
    ///
    /// Beware that some validators assume non-null value.
    bool stopOnFirstErrorOrWarning = false,

    /// Delay between the last validation request and the start of async validation.
    ///
    /// Use [Duration.zero] to start immediately.
    Duration asyncDebounce = const Duration(milliseconds: 300),
  }) => .new(
    parts: parts,
    asyncParts: asyncParts,
    stopOnFirstError: stopOnFirstError,
    stopOnFirstErrorOrWarning: stopOnFirstErrorOrWarning,
    asyncDebounce: asyncDebounce,
  );

  /// Clears all validation parts, synchronous and asynchronous.
  void clear() {
    parts = [];
    asyncParts = [];
  }

  /// Checks value with custom asynchronous validation function.
  ///
  /// Runs after synchronous parts. With [runOnlyWhenSyncValid] (default) it is skipped when synchronous
  /// validation produced an error. Exceptions are passed to [onError]; without it `AsyncValidationFailedError` is reported.
  void customAsync(
    AsyncValidateFunctionWithKey<T> onValidate, {
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    ValidationSeverity severity = .error,
    bool runOnlyWhenSyncValid = true,
    OnAsyncValidationError<T>? onError,
  }) => asyncParts.add(
    CustomAsyncValidationPart(
      customValidator: (v) => onValidate(v, key),
      key: key,
      shouldValidate: shouldValidate,
      serverity: severity,
      runOnlyWhenSyncValid: runOnlyWhenSyncValid,
      onError: onError,
    ),
  );

  /// Checks value through custom asynchronous validator [part].
  void customAsyncPart(AsyncInputValidatorPart<T> part) => asyncParts.add(part);

  /// Value must satisfy given asynchronous [predicate]. Returns [ValueSatisfyPredicateError].
  ///
  /// See [customAsync] for [runOnlyWhenSyncValid] and [onError] semantics.
  void satisfyAsync(
    AsyncSatisfyPredicate<T> predicate, {
    OnValidate<T>? devMessage,
    Object? key,
    ShouldValidateCallback<T>? shouldValidate,
    Object? metaData,
    ValidationSeverity severity = .error,
    bool runOnlyWhenSyncValid = true,
    OnAsyncValidationError<T>? onError,
  }) => asyncParts.add(
    SatisfyAsyncPredicatePart(
      predicate: predicate,
      devMessage: devMessage ?? (value) => 'Value ${value ?? 'NULL'} does not satisfy given async predicate.',
      key: key,
      shouldValidate: shouldValidate,
      metaData: metaData,
      serverity: severity,
      runOnlyWhenSyncValid: runOnlyWhenSyncValid,
      onError: onError,
    ),
  );
```

- [x] **Step 5: Extend `ValidatorInstance` (declaration only, `validateAsync` comes in Task 4)**

```dart
class ValidatorInstance<T> {
  /// Stops validation on first error.
  ///
  /// Continues on warning.
  final bool stopOnFirstError;

  /// Stop validation on first error or warning.
  final bool stopOnFirstErrorOrWarning;

  /// Delay between the last validation request and the start of async validation.
  final Duration asyncDebounce;

  GladeInput<T>? _input;

  final List<InputValidatorPart<T>> _parts;

  final List<AsyncInputValidatorPart<T>> _asyncParts;

  /// Whether any asynchronous part is declared.
  bool get hasAsyncParts => _asyncParts.isNotEmpty;

  ValidatorInstance({
    required List<InputValidatorPart<T>> parts,
    required this.stopOnFirstError,
    required this.stopOnFirstErrorOrWarning,
    List<AsyncInputValidatorPart<T>> asyncParts = const [],
    this.asyncDebounce = const Duration(milliseconds: 300),
  }) : _parts = parts,
       _asyncParts = asyncParts;

  // ... existing bindInput, validate unchanged ...

  InputValidatorPart<T>? tryFindValidatorPart(Object key) => _parts.firstWhereOrNull((part) => part.key == key);

  InputValidatorPart<T> findValidatorPart(Object key) => _parts.firstWhere(
    (part) => part.key == key,
    orElse: () => throw ArgumentError('No validator part found for key: $key'),
  );

  AsyncInputValidatorPart<T>? tryFindAsyncValidatorPart(Object key) =>
      _asyncParts.firstWhereOrNull((part) => part.key == key);

  AsyncInputValidatorPart<T> findAsyncValidatorPart(Object key) => _asyncParts.firstWhere(
    (part) => part.key == key,
    orElse: () => throw ArgumentError('No async validator part found for key: $key'),
  );

  /// Whether a synchronous or asynchronous part with [key] is declared.
  bool hasDeclaredValidator(Object key) => _parts.any((part) => part.key == key) || _asyncParts.any((part) => part.key == key);
```

Add `import 'package:glade_forms/src/validator/part/async_input_validator_part.dart';`.

- [x] **Step 6: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test && checkme`
Expected: PASS.

- [x] **Step 7: Commit (only if allowed)**

```bash
git add glade_forms/lib/src/validator glade_forms/test/glade_validator_test.dart
git commit -m "feat: declare async validator parts"
```

---

### Task 4: `ValidatorInstance.validateAsync`

**Files:**
- Modify: `glade_forms/lib/src/validator/validator_instance.dart`
- Test: `glade_forms/test/async_validator_test.dart`

**Interfaces:**
- Consumes: Task 2 result types, Task 3 parts.
- Produces:
  ```dart
  Future<ValidatorResult<T>> validateAsync(T value);
  bool shouldRunAsyncParts(ValidatorResult<T> syncResult);
  ```
  `validateAsync` returns sync + async results with `asyncState: .done`, `asyncValidatedValue: value`. `shouldRunAsyncParts` is `true` when there are async parts, the sync half did not stop validation, and either the sync result is valid or some part has `runOnlyWhenSyncValid == false`.

- [x] **Step 1: Write the failing tests**

```dart
// glade_forms/test/async_validator_test.dart
// ignore_for_file: cascade_invocations

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  setUp(GladeForms.initialize);

  ValidatorInstance<String> build(void Function(GladeValidator<String> v) configure, {bool stopOnFirstError = true}) {
    final validator = GladeValidator<String>();
    configure(validator);

    return validator.build(stopOnFirstError: stopOnFirstError);
  }

  test('sync valid, async valid returns done result without errors', () async {
    // arrange
    final instance = build((v) => v..satisfyAsync((value) async => true, key: 'a'));

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.isValid, isTrue);
    expect(result.asyncState, equals(AsyncValidationState.done));
    expect(result.asyncValidatedValue, equals('x'));
  });

  test('async error is reported with part key and value', () async {
    // arrange
    final instance = build((v) => v..satisfyAsync((value) async => false, key: 'taken', devMessage: (_) => 'Taken'));

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.isNotValid, isTrue);
    expect(result.errors.single.key, equals('taken'));
    expect(result.errors.single.value, equals('x'));
    expect(result.errors.single.devValidationMessage, equals('Taken'));
  });

  test('async parts run sequentially in declaration order', () async {
    // arrange
    final order = <String>[];
    final instance = build(
      (v) => v
        ..customAsync((value, key) async {
          order.add('first');
          return null;
        })
        ..customAsync((value, key) async {
          order.add('second');
          return null;
        }),
    );

    // act
    await instance.validateAsync('x');

    // assert
    expect(order, equals(['first', 'second']));
  });

  test('sync error with stopOnFirstError skips all async parts', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..customAsync((value, key) async {
          called = true;
          return null;
        }, runOnlyWhenSyncValid: false),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(called, isFalse);
    expect(result.errors.single.key, equals('sync'));
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isFalse);
  });

  test('runOnlyWhenSyncValid true skips part when sync failed and stopOnFirstError is false', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..customAsync((value, key) async {
          called = true;
          return null;
        }),
      stopOnFirstError: false,
    );

    // act
    await instance.validateAsync('x');

    // assert
    expect(called, isFalse);
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isFalse);
  });

  test('runOnlyWhenSyncValid false runs part when sync failed and stopOnFirstError is false', () async {
    // arrange
    final instance = build(
      (v) => v
        ..satisfy((value) => false, key: 'sync')
        ..satisfyAsync((value) async => false, key: 'async', runOnlyWhenSyncValid: false),
      stopOnFirstError: false,
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.map((e) => e.key), equals(['sync', 'async']));
    expect(instance.shouldRunAsyncParts(instance.validate('x')), isTrue);
  });

  test('stopOnFirstError stops after first async error', () async {
    // arrange
    var secondCalled = false;
    final instance = build(
      (v) => v
        ..satisfyAsync((value) async => false, key: 'first')
        ..customAsync((value, key) async {
          secondCalled = true;
          return null;
        }),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.single.key, equals('first'));
    expect(secondCalled, isFalse);
  });

  test('warning does not stop and lands in warnings', () async {
    // arrange
    final instance = build(
      (v) => v
        ..satisfyAsync((value) async => false, key: 'warn', severity: .warning)
        ..satisfyAsync((value) async => false, key: 'err'),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.warnings.single.key, equals('warn'));
    expect(result.errors.single.key, equals('err'));
    expect(result.all, hasLength(2));
  });

  test('shouldValidate false skips async part', () async {
    // arrange
    var called = false;
    final instance = build(
      (v) => v
        ..customAsync((value, key) async {
          called = true;
          return null;
        }, shouldValidate: (value) => value.isNotEmpty),
    );

    // act
    await instance.validateAsync('');

    // assert
    expect(called, isFalse);
  });

  test('exception without onError produces AsyncValidationFailedError', () async {
    // arrange
    final instance = build((v) => v..customAsync((value, key) async => throw Exception('boom'), key: 'k'));

    // act
    final result = await instance.validateAsync('x');

    // assert
    final error = result.errors.single;
    expect(error, isA<AsyncValidationFailedError<String>>());
    expect(error.key, equals(GladeValidationsKeys.asyncValidationFailed));
    expect((error as AsyncValidationFailedError<String>).partKey, equals('k'));
    expect(error.devValidationMessage, contains('boom'));
  });

  test('exception with onError uses its result', () async {
    // arrange
    final instance = build(
      (v) => v
        ..customAsync(
          (value, key) async => throw Exception('boom'),
          key: 'k',
          onError: (value, error, stackTrace, key) => ValueError(value: value, devMessage: (_) => 'custom', key: key),
        ),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.errors.single.key, equals('k'));
    expect(result.errors.single.devValidationMessage, equals('custom'));
  });

  test('onError returning null treats value as valid', () async {
    // arrange
    final instance = build(
      (v) => v..customAsync((value, key) async => throw Exception('boom'), onError: (_, __, ___, ____) => null),
    );

    // act
    final result = await instance.validateAsync('x');

    // assert
    expect(result.isValid, isTrue);
  });

  test('instance without async parts returns done result equal to sync', () async {
    // arrange
    final instance = build((v) => v..satisfy((value) => value.isNotEmpty, key: 'sync'));

    // act
    final result = await instance.validateAsync('');

    // assert
    expect(result.errors.single.key, equals('sync'));
    expect(result.asyncState, equals(AsyncValidationState.done));
    expect(instance.shouldRunAsyncParts(instance.validate('')), isFalse);
  });
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `cd glade_forms && fvm flutter test test/async_validator_test.dart`
Expected: FAIL, `validateAsync` undefined.

- [x] **Step 3: Implement**

Add to `ValidatorInstance<T>` (imports: `validator_result/validator_error.dart` for `AsyncValidationFailedError`, `core/error/glade_validations_keys.dart` not needed since the error sets its own key):

```dart
  /// Performs synchronous validation followed by asynchronous parts.
  ///
  /// Async parts run sequentially in declaration order. A part is skipped when its `shouldValidate`
  /// returns `false`, or when it has `runOnlyWhenSyncValid` and synchronous validation produced an error.
  /// No async part runs when the synchronous half already stopped validation
  /// ([stopOnFirstError] with an error, or [stopOnFirstErrorOrWarning] with any result).
  ///
  /// Exceptions thrown by a part are passed to its `onError`; without it [AsyncValidationFailedError] is reported.
  Future<ValidatorResult<T>> validateAsync(T value) async {
    final syncResult = validate(value);
    final combined = [...syncResult.all];
    final errors = [...syncResult.errors];
    final warnings = [...syncResult.warnings];

    if (!_syncStopped(syncResult)) {
      for (final part in _asyncParts) {
        final shouldValidate = part.shouldValidate?.call(value) ?? true;

        if (!shouldValidate) continue;
        if (part.runOnlyWhenSyncValid && syncResult.isNotValid) continue;

        final result = await _runAsyncPart(part, value);

        if (result == null) continue;

        final isError = result.severity == .error;

        combined.add(result);

        if (isError) {
          errors.add(result);
        } else {
          warnings.add(result);
        }

        if (stopOnFirstError && isError) break;
        if (stopOnFirstErrorOrWarning) break;
      }
    }

    return ValidatorResult(
      all: combined,
      errors: errors,
      warnings: warnings,
      associatedInput: _input,
      asyncState: .done,
      asyncValidatedValue: value,
    );
  }

  /// Whether [validateAsync] would run at least one asynchronous part given [syncResult].
  bool shouldRunAsyncParts(ValidatorResult<T> syncResult) {
    if (!hasAsyncParts || _syncStopped(syncResult)) return false;

    return syncResult.isValid || _asyncParts.any((part) => !part.runOnlyWhenSyncValid);
  }

  bool _syncStopped(ValidatorResult<T> syncResult) =>
      (stopOnFirstError && syncResult.isNotValid) || (stopOnFirstErrorOrWarning && syncResult.all.isNotEmpty);

  Future<GladeValidatorResult<T>?> _runAsyncPart(AsyncInputValidatorPart<T> part, T value) async {
    try {
      return await part.validate(value);
      // ignore: avoid_catches_without_on_clauses, any exception must be turned into a validation result
    } catch (error, stackTrace) {
      final onError = part.onError;

      if (onError != null) return onError(value, error, stackTrace, part.key);

      return AsyncValidationFailedError<T>(
        value: value,
        error: error,
        stackTrace: stackTrace,
        partKey: part.key,
        errorServerity: part.serverity,
      );
    }
  }
```

- [x] **Step 4: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test test/async_validator_test.dart && checkme`
Expected: PASS.

- [x] **Step 5: Commit (only if allowed)**

```bash
git add glade_forms/lib/src/validator/validator_instance.dart glade_forms/test/async_validator_test.dart
git commit -m "feat: run async validator parts in instance"
```

---

### Task 5: `AsyncValidationRunner`

**Files:**
- Create: `glade_forms/lib/src/core/input/async_validation_runner.dart`
- Modify: `glade_forms/lib/src/core/input/input.dart` (export)
- Modify: `glade_forms/pubspec.yaml` (dev dependency `fake_async: ^1.3.1`)
- Test: `glade_forms/test/async_validation_runner_test.dart`

**Interfaces:**
- Consumes: `ValidatorInstance<T>.validateAsync`, `.asyncDebounce` (Task 3, 4).
- Produces:
  ```dart
  @internal
  class AsyncValidationRunner<T> {
    AsyncValidationRunner({required ValidatorInstance<T> validatorInstance, required VoidCallback onCompleted});
    bool get isValidating;
    ValidatorResult<T>? get cachedResult;
    void onValueChanged();                       // drop cache, invalidate in-flight, stop pending
    void schedule(T value);                      // debounce trigger, no-op when cache or in-flight exists
    Future<ValidatorResult<T>> runNow(T value);  // bypass debounce, share in-flight, return cache when present
    void invalidate();                           // same as onValueChanged, semantic alias for reset/dispose
  }
  ```
  `onCompleted` is called only when an accepted (non-stale) result was stored.

- [x] **Step 1: Add dev dependency**

In `glade_forms/pubspec.yaml` under `dev_dependencies` add `fake_async: ^1.3.1`, then run `cd glade_forms && fvm flutter pub get`.

- [x] **Step 2: Write the failing tests**

```dart
// glade_forms/test/async_validation_runner_test.dart
// ignore_for_file: cascade_invocations, avoid-async-call-in-sync-function

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms/src/core/input/async_validation_runner.dart';
import 'package:test/test.dart';

void main() {
  setUp(GladeForms.initialize);

  ValidatorInstance<String> instanceWith(
    Future<bool> Function(String value) predicate, {
    Duration debounce = const Duration(milliseconds: 300),
  }) => (GladeValidator<String>()..satisfyAsync(predicate, key: 'server', devMessage: (_) => 'Taken')).build(
    asyncDebounce: debounce,
  );

  test('schedule waits for debounce, then runs and caches', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      var completed = 0;
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) async {
          calls++;
          return value != 'taken';
        }),
        onCompleted: () => completed++,
      );

      // act
      runner.schedule('taken');

      // assert
      expect(runner.isValidating, isTrue);
      expect(calls, equals(0));

      async.elapse(const Duration(milliseconds: 299));
      expect(calls, equals(0));

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(calls, equals(1));
      expect(runner.isValidating, isFalse);
      expect(runner.cachedResult?.isNotValid, isTrue);
      expect(runner.cachedResult?.asyncValidatedValue, equals('taken'));
      expect(completed, equals(1));
    });
  });

  test('schedule is no-op while pending or cached', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) async {
          calls++;
          return true;
        }),
        onCompleted: () {},
      );

      // act
      runner.schedule('a');
      runner.schedule('a');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      runner.schedule('a');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
    });
  });

  test('Duration.zero debounce runs immediately', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) async {
          calls++;
          return true;
        }, debounce: Duration.zero),
        onCompleted: () {},
      );

      // act
      runner.schedule('a');
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
      expect(runner.cachedResult, isNotNull);
    });
  });

  test('onValueChanged cancels debounce and drops cache', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) async {
          calls++;
          return true;
        }),
        onCompleted: () {},
      );

      // act
      runner.schedule('a');
      async.elapse(const Duration(milliseconds: 200));
      runner.onValueChanged();
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(calls, equals(0));
      expect(runner.isValidating, isFalse);
      expect(runner.cachedResult, isNull);
    });
  });

  test('stale response is discarded and does not call onCompleted', () {
    FakeAsync().run((async) {
      // arrange
      final completers = <Completer<bool>>[];
      var completed = 0;
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) {
          final completer = Completer<bool>();
          completers.add(completer);
          return completer.future;
        }, debounce: Duration.zero),
        onCompleted: () => completed++,
      );

      // act
      runner.schedule('first');
      async.flushMicrotasks();
      runner.onValueChanged();
      runner.schedule('second');
      async.flushMicrotasks();

      completers[0].complete(false);
      async.flushMicrotasks();

      // assert: first response ignored
      expect(runner.cachedResult, isNull);
      expect(runner.isValidating, isTrue);
      expect(completed, equals(0));

      completers[1].complete(true);
      async.flushMicrotasks();

      expect(runner.cachedResult?.isValid, isTrue);
      expect(runner.cachedResult?.asyncValidatedValue, equals('second'));
      expect(completed, equals(1));
    });
  });

  test('runNow bypasses debounce and shares in-flight request', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final completer = Completer<bool>();
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) {
          calls++;
          return completer.future;
        }),
        onCompleted: () {},
      );
      ValidatorResult<String>? first;
      ValidatorResult<String>? second;

      // act
      runner.schedule('a');
      runner.runNow('a').then((r) => first = r);
      runner.runNow('a').then((r) => second = r);
      async.flushMicrotasks();

      expect(calls, equals(1));

      completer.complete(true);
      async.flushMicrotasks();

      // assert
      expect(first, isNotNull);
      expect(identical(first, second), isTrue);
      expect(runner.isValidating, isFalse);
    });
  });

  test('runNow returns cache when present without new request', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) async {
          calls++;
          return true;
        }, debounce: Duration.zero),
        onCompleted: () {},
      );
      ValidatorResult<String>? result;

      // act
      runner.schedule('a');
      async.flushMicrotasks();
      runner.runNow('a').then((r) => result = r);
      async.flushMicrotasks();

      // assert
      expect(calls, equals(1));
      expect(identical(result, runner.cachedResult), isTrue);
    });
  });

  test('awaiting caller of an invalidated run still receives the stale result', () {
    FakeAsync().run((async) {
      // arrange
      final completer = Completer<bool>();
      final runner = AsyncValidationRunner<String>(
        validatorInstance: instanceWith((value) => completer.future, debounce: Duration.zero),
        onCompleted: () {},
      );
      ValidatorResult<String>? result;

      // act
      runner.runNow('old').then((r) => result = r);
      async.flushMicrotasks();
      runner.invalidate();
      completer.complete(false);
      async.flushMicrotasks();

      // assert
      expect(result?.asyncValidatedValue, equals('old'));
      expect(runner.cachedResult, isNull);
    });
  });
}
```

- [x] **Step 3: Run tests to verify they fail**

Run: `cd glade_forms && fvm flutter test test/async_validation_runner_test.dart`
Expected: FAIL, file does not exist.

- [x] **Step 4: Implement**

```dart
// glade_forms/lib/src/core/input/async_validation_runner.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/validator/validator_instance.dart';
import 'package:glade_forms/src/validator/validator_result.dart';
import 'package:meta/meta.dart';

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

  bool get isValidating => _isPending;

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

    if (debounce == Duration.zero) {
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
```

Add `export 'async_validation_runner.dart';` to `glade_forms/lib/src/core/input/input.dart`.

- [x] **Step 5: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test test/async_validation_runner_test.dart && checkme`
Expected: PASS.

- [x] **Step 6: Commit (only if allowed)**

```bash
git add glade_forms/pubspec.yaml glade_forms/lib/src/core/input glade_forms/test/async_validation_runner_test.dart
git commit -m "feat: add async validation runner"
```

---

### Task 6: `GladeInput` integration and model mode hook

**Files:**
- Create: `glade_forms/lib/src/model/async_validation_mode.dart`
- Modify: `glade_forms/lib/src/model/model.dart` (export)
- Modify: `glade_forms/lib/src/model/glade_model.dart` (`asyncValidationMode`, `notifyInputValidationUpdated`)
- Modify: `glade_forms/lib/src/core/input/glade_input.dart`
- Test: `glade_forms/test/async_input_test.dart`

**Interfaces:**
- Consumes: `AsyncValidationRunner<T>` (Task 5), `ValidatorInstance.shouldRunAsyncParts` (Task 4), `ValueEquality` (Task 1), `ValidatorResult.copyWith` (Task 2).
- Produces:
  ```dart
  enum AsyncValidationMode { strict, lastKnown }

  // GladeModel
  AsyncValidationMode get asyncValidationMode => .strict;
  @internal void notifyInputValidationUpdated(GladeInput<Object?> input);

  // GladeInput
  bool get isValidating;
  bool get hasAsyncValidation;
  Future<ValidatorResult<T>> validateAsync({bool force = false});
  ```
  Triggers: `_setValue` (real change), `validate()`, `textFormFieldInputValidatorCustom`, `textFormFieldInputValidator`, `formFieldValidator`. Reads: `isValid`, `isValidAndWithoutWarnings`, `validatorResult`, `validationErrors`, `validationWarnings`, `errorFormatted`, `errorOrWarningFormatted`, `translate`.

- [x] **Step 1: Write the failing tests**

```dart
// glade_forms/test/async_input_test.dart
// ignore_for_file: cascade_invocations, avoid-async-call-in-sync-function

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Server {
  final Set<String> taken;
  final List<Completer<bool>> pending = [];
  int calls = 0;
  bool manual;

  _Server({this.taken = const {'taken'}, this.manual = false});

  Future<bool> isAvailable(String value) {
    calls++;

    if (manual) {
      final completer = Completer<bool>();
      pending.add(completer);

      return completer.future;
    }

    return Future.value(!taken.contains(value));
  }
}

GladeStringInput usernameInput(_Server server, {Duration debounce = const Duration(milliseconds: 300)}) =>
    GladeStringInput(
      inputKey: 'username',
      value: '',
      useTextEditingController: false,
      isRequired: false,
      validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken', devMessage: (_) => 'Taken')).build(
        asyncDebounce: debounce,
      ),
    );

void main() {
  setUp(GladeForms.initialize);

  test('input without async parts reports hasAsyncValidation false and notRun', () async {
    // arrange
    final input = GladeStringInput(value: 'a', useTextEditingController: false);

    // act
    final result = await input.validateAsync();

    // assert
    expect(input.hasAsyncValidation, isFalse);
    expect(input.isValidating, isFalse);
    expect(result.asyncState, equals(AsyncValidationState.notRun));
  });

  test('getters do not trigger async validation', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server);

      // act
      final _ = input.isValid;
      final __ = input.validatorResult;
      final ___ = input.validationErrors;
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(0));
      expect(input.isValidating, isFalse);
    });
  });

  test('validate() triggers async validation for current value', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server);
      input.updateValue('taken');
      // value change already scheduled; reset the counter view by elapsing
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(server.calls, equals(1));

      // act: cache exists, validate() must not re-run
      final result = input.validate();

      // assert
      expect(server.calls, equals(1));
      expect(result.asyncState, equals(AsyncValidationState.done));
      expect(result.errors.single.key, equals('taken'));
    });
  });

  test('value change schedules async and merges rapid changes into one request', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server);

      // act
      input.updateValue('t');
      async.elapse(const Duration(milliseconds: 100));
      input.updateValue('ta');
      async.elapse(const Duration(milliseconds: 100));
      input.updateValue('taken');

      expect(input.isValidating, isTrue);
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.pending));

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(1));
      expect(input.isValidating, isFalse);
      expect(input.isValid, isFalse);
      expect(input.validationErrors.single.key, equals('taken'));
      expect(input.errorFormatted(), equals('Taken'));
    });
  });

  test('unbound input applies strict mode while pending', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server);

      // act
      input.updateValue('free');

      // assert
      expect(input.validatorResult.isValid, isTrue, reason: 'known results have no error');
      expect(input.isValid, isFalse, reason: 'strict: pending is invalid');
      expect(input.isValidAndWithoutWarnings, isFalse);

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      expect(input.isValid, isTrue);
    });
  });

  test('sync error skips async and does not enter pending', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = GladeStringInput(
        value: 'x',
        useTextEditingController: false,
        validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken')).build(),
      );

      // act
      input.updateValue('');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(0));
      expect(input.isValidating, isFalse);
      expect(input.isValid, isFalse);
      expect(input.validationErrors.single.key, equals(GladeValidationsKeys.stringEmpty));
    });
  });

  test('response for outdated value is discarded, also when changing back', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server(manual: true);
      final input = usernameInput(server, debounce: Duration.zero);

      // act
      input.updateValue('first');
      async.flushMicrotasks();
      input.updateValue('second');
      async.flushMicrotasks();
      input.updateValue('first');
      async.flushMicrotasks();

      expect(server.calls, equals(3));

      server.pending[0].complete(false);
      server.pending[1].complete(false);
      async.flushMicrotasks();

      // assert: still pending, nothing cached
      expect(input.isValidating, isTrue);
      expect(input.validationErrors, isEmpty);

      server.pending[2].complete(true);
      async.flushMicrotasks();

      expect(input.isValidating, isFalse);
      expect(input.isValid, isTrue);
      expect(input.validatorResult.asyncValidatedValue, equals('first'));
    });
  });

  test('same value does not retrigger', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server, debounce: Duration.zero);

      // act
      input.updateValue('free');
      async.flushMicrotasks();
      input.updateValue('free');
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(1));
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.done));
    });
  });

  test('validateAsync bypasses debounce and returns full result', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server);
      ValidatorResult<String>? result;

      // act
      input.updateValue('taken');
      input.validateAsync().then((r) => result = r);
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(1));
      expect(result?.errors.single.key, equals('taken'));
      expect(result?.asyncValidatedValue, equals('taken'));
    });
  });

  test('validateAsync uses cache, force re-runs', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server, debounce: Duration.zero);

      // act
      input.updateValue('free');
      async.flushMicrotasks();
      input.validateAsync();
      async.flushMicrotasks();

      expect(server.calls, equals(1));

      input.validateAsync(force: true);
      async.flushMicrotasks();

      // assert
      expect(server.calls, equals(2));
    });
  });

  test('textFormFieldInputValidator triggers and reads cache, null while pending', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = usernameInput(server);

      // act
      input.updateValue('taken');
      final whilePending = input.textFormFieldInputValidator('taken');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      final afterDone = input.textFormFieldInputValidator('taken');

      // assert
      expect(whilePending, isNull);
      expect(afterDone, equals('Taken'));
      expect(server.calls, equals(1));
    });
  });

  test('textFormFieldInputValidator on pure input with initial value triggers async', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final input = GladeStringInput(
        initialValue: 'taken',
        useTextEditingController: false,
        validator: (v) => (v..satisfyAsync(server.isAvailable, key: 'taken', devMessage: (_) => 'Taken')).build(),
      );

      // act
      final first = input.textFormFieldInputValidator('taken');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();

      // assert
      expect(first, isNull);
      expect(server.calls, equals(1));
      expect(input.textFormFieldInputValidator('taken'), equals('Taken'));
    });
  });

  test('conversion error disables triggers', () {
    FakeAsync().run((async) {
      // arrange
      var calls = 0;
      final input = GladeIntInput(
        value: 1,
        useTextEditingController: false,
        validator: (v) => (v..customAsync((value, key) async {
          calls++;
          return null;
        })).build(asyncDebounce: Duration.zero),
      );

      // act
      input.updateValueWithString('not-a-number');
      final _ = input.validate();
      async.flushMicrotasks();

      // assert
      expect(input.hasConversionError, isTrue);
      expect(calls, equals(0));
      expect(input.isValidating, isFalse);
    });
  });

  test('ChangesInfo carries pending state', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      ChangesInfo<String>? info;
      final input = GladeStringInput(
        value: '',
        useTextEditingController: false,
        onChange: (i) => info = i,
        validator: (v) => (v..satisfyAsync(server.isAvailable)).build(),
      );

      // act
      input.updateValue('free');

      // assert
      expect(info?.validatorResult?.asyncState, equals(AsyncValidationState.pending));
    });
  });

  test('resetToInitialValue and dispose invalidate', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server(manual: true);
      final input = usernameInput(server, debounce: Duration.zero);

      // act
      input.updateValue('free');
      async.flushMicrotasks();
      input.resetToInitialValue();

      // assert
      expect(input.isValidating, isFalse);
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.notRun));

      server.pending[0].complete(true);
      async.flushMicrotasks();
      expect(input.validatorResult.asyncState, equals(AsyncValidationState.notRun));

      input.updateValue('other');
      async.flushMicrotasks();
      input.dispose();
      server.pending[1].complete(true);
      async.flushMicrotasks();

      expect(input.isValidating, isFalse);
    });
  });

  test('async failure uses defaultAsyncValidationFailedMessage', () {
    FakeAsync().run((async) {
      // arrange
      final input = GladeStringInput(
        value: 'a',
        useTextEditingController: false,
        defaultValidationTranslations: const DefaultValidationTranslations(
          defaultAsyncValidationFailedMessage: 'Server unavailable',
        ),
        validator: (v) => (v..customAsync((value, key) async => throw Exception('boom'))).build(
          asyncDebounce: Duration.zero,
        ),
      );

      // act
      input.updateValue('b');
      async.flushMicrotasks();

      // assert
      expect(input.validationErrors.single.isAsyncValidationFailedError, isTrue);
      expect(input.errorFormatted(), equals('Server unavailable'));
    });
  });
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `cd glade_forms && fvm flutter test test/async_input_test.dart`
Expected: FAIL, `hasAsyncValidation` undefined.

- [x] **Step 3: Add mode enum and model hooks**

```dart
// glade_forms/lib/src/model/async_validation_mode.dart
/// How a model treats inputs whose asynchronous validation is pending.
enum AsyncValidationMode {
  /// Pending async validation makes the input (and the model) invalid until it finishes.
  strict,

  /// Pending async validation is ignored; `isValid` reflects synchronous results only until async finishes.
  lastKnown,
}
```

Add `export 'async_validation_mode.dart';` to `model.dart`.

In `GladeModel` add:

```dart
  /// Determines how pending asynchronous validation affects `isValid` of inputs and the model.
  ///
  /// Override to switch to [AsyncValidationMode.lastKnown]. Default is [AsyncValidationMode.strict].
  AsyncValidationMode get asyncValidationMode => .strict;

  /// Called by inputs when their asynchronous validation finished.
  ///
  /// Only notifies listeners. Unlike [notifyInputUpdated] it does not touch [lastUpdates] nor dependencies,
  /// because no value changed.
  @internal
  void notifyInputValidationUpdated(GladeInput<Object?> input) => notifyListeners();
```

- [x] **Step 4: Integrate into `GladeInput`**

Imports to add in `glade_input.dart`:

```dart
import 'package:glade_forms/src/core/input/async_validation_runner.dart';
import 'package:glade_forms/src/model/async_validation_mode.dart';
```

New field next to `_bindedModel`:

```dart
  AsyncValidationRunner<T>? _asyncRunner;
```

At the end of the `internalCreate` constructor body (after `validatorInstance.bindInput(this);`):

```dart
    if (validatorInstance.hasAsyncParts) {
      _asyncRunner = AsyncValidationRunner(
        validatorInstance: validatorInstance,
        onCompleted: _onAsyncValidationCompleted,
      );
    }
```

Replace the validity getters:

```dart
  /// Input does not have conversion error nor validation errors but can include warnings.
  ///
  /// With [AsyncValidationMode.strict] (default) pending async validation makes the input invalid.
  /// Never triggers async validation, see [validate].
  bool get isValid {
    if (hasConversionError) return false;

    final result = validatorResult;

    return _applyAsyncMode(result, result.isValid);
  }

  /// Input does not have conversion error nor validation errors nor warnings.
  ///
  /// With [AsyncValidationMode.strict] (default) pending async validation makes the input invalid.
  bool get isValidAndWithoutWarnings {
    if (hasConversionError) return false;

    final result = validatorResult;

    return _applyAsyncMode(result, result.isValidWithoutWarnings);
  }

  /// True when asynchronous validation for the current value is scheduled or running.
  bool get isValidating => _asyncRunner?.isValidating ?? false;

  /// True when the input declares at least one asynchronous validator.
  bool get hasAsyncValidation => validatorInstance.hasAsyncParts;

  /// Synchronous result merged with the cached asynchronous result for the current value.
  ///
  /// Pure read, never triggers async validation. Use [validate] or [validateAsync] to trigger it.
  ValidatorResult<T> get validatorResult {
    final runner = _asyncRunner;

    if (runner == null) return validatorInstance.validate(value);
    if (runner.cachedResult case final cached?) return cached;

    return validatorInstance.validate(value).copyWith(asyncState: runner.isValidating ? .pending : .notRun);
  }

  AsyncValidationMode get _asyncValidationMode => _bindedModel?.asyncValidationMode ?? .strict;
```

Replace `validate()` and add `validateAsync`:

```dart
  /// Returns current validation result and triggers asynchronous validation when it did not run for the current value yet.
  ValidatorResult<T> validate() {
    _scheduleAsyncValidation();

    return validatorResult;
  }

  /// Runs asynchronous validation for the current value immediately, skipping the debounce, and awaits it.
  ///
  /// Returns the cached result when async validation already finished for the current value, unless [force] is `true`.
  /// Joins a running validation instead of starting a new one. Without async validators returns the synchronous result.
  Future<ValidatorResult<T>> validateAsync({bool force = false}) {
    final runner = _asyncRunner;

    if (runner == null || hasConversionError || _isDisposed) return Future.value(validatorResult);

    if (force) runner.invalidate();

    if (!validatorInstance.shouldRunAsyncParts(validatorInstance.validate(value))) return Future.value(validatorResult);

    return runner.runNow(value);
  }
```

Update `textFormFieldInputValidatorCustom` body:

```dart
    final converter = stringToValueConverter ?? _defaultConverter;

    try {
      final convertedValue = converter.convert(value);

      _scheduleAsyncValidation();

      final result = ValueEquality.equals(convertedValue, this.value)
          ? validatorResult
          : validatorInstance.validate(convertedValue);

      return !result.isValidWithSeverity(severity)
          ? _translate(delimiter: delimiter, customError: result, severity: severity)
          : null;
    } on ConvertError<T> catch (e) {
      return _translate(delimiter: delimiter, customError: e, severity: severity);
    }
```

Update doc comment of `textFormFieldInputValidator` and `textFormFieldInputValidatorCustom` with: `/// Triggers asynchronous validation of the input's current value. The [value] argument is only used for the synchronous message.`

Update `formFieldValidator`:

```dart
  /// Shorthand validator for Form field input.
  ///
  /// Returns translated validation message. Triggers asynchronous validation of the input's current value.
  String? formFieldValidator(
    T value, {
    ValidationSeverity severity = .error,
    String delimiter = '.',
  }) {
    _scheduleAsyncValidation();

    final result = ValueEquality.equals(value, this.value) ? validatorResult : validatorInstance.validate(value);

    return result.isNotValid ? _translate(customError: result, severity: severity, delimiter: delimiter) : null;
  }
```

Update `_setValue`:

```dart
  void _setValue(T value, {required bool shouldTriggerOnChange}) {
    _previousValue = _value;

    // ignore: prefer-conditional-expressions, keep explicit if-else
    if (_valueTransform != null) {
      _value = TypeHelper.typeIsNullable<T>() ? _valueTransform(value) : (_valueTransform(value) ?? value);
    } else {
      _value = value;
    }

    _isPure = false;
    __conversionError = null;

    if (!ValueEquality.equals(_previousValue, _value)) {
      _asyncRunner?.onValueChanged();
      _scheduleAsyncValidation();
    }

    // propagate input's changes
    if (shouldTriggerOnChange) {
      onChange?.call(
        ChangesInfo(
          inputKey: inputKey,
          previousValue: _previousValue,
          value: value,
          initialValue: initialValue,
          validatorResult: validate(),
        ),
      );
    }

    _bindedModel?.notifyInputUpdated(this);
  }
```

Add the private helpers (place near `_setValue`):

```dart
  void _scheduleAsyncValidation() {
    final runner = _asyncRunner;

    if (runner == null || hasConversionError || _isDisposed) return;
    if (!validatorInstance.shouldRunAsyncParts(validatorInstance.validate(value))) return;

    runner.schedule(value);
  }

  void _onAsyncValidationCompleted() {
    if (_isDisposed) return;

    _bindedModel?.notifyInputValidationUpdated(this);
  }
```

`resetToInitialValue`: add `_asyncRunner?.invalidate();` right before `_isPure = true;` (after the value was synced, so a schedule caused by the reset is cancelled too).

`setNewInitialValue`: add `_asyncRunner?.invalidate();` as the first statement.

`dispose()`: add `_asyncRunner?.invalidate();` after `_isDisposed = true;`.

`_translateGenericValidation`: extend the default-translations branch:

```dart
          if (defaultTranslationsTmp != null &&
              (e.isNullError || e.hasStringEmptyOrNullErrorKey || e.hasNullValueOrEmptyValueKey)) {
            return defaultTranslationsTmp.defaultValueIsNullOrEmptyMessage ?? e.toString();
          } else if (defaultTranslationsTmp?.defaultAsyncValidationFailedMessage case final message?
              when e.isAsyncValidationFailedError) {
            return message;
          } else if (_bindedModel case final model?) {
```

- [x] **Step 5: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test && checkme`
Expected: PASS, including all pre-existing tests (sync behaviour unchanged).

- [x] **Step 6: Commit (only if allowed)**

```bash
git add glade_forms/lib glade_forms/test/async_input_test.dart
git commit -m "feat: integrate async validation into GladeInput"
```

---

### Task 7: Model, composed model, behaviour matrix tests

**Files:**
- Modify: `glade_forms/lib/src/model/glade_model_base.dart`
- Modify: `glade_forms/lib/src/model/glade_model.dart`
- Modify: `glade_forms/lib/src/model/glade_composed_model.dart`
- Test: `glade_forms/test/model/async_model_test.dart`

**Interfaces:**
- Consumes: `GladeInput.isValidating`, `GladeInput.validateAsync`, `AsyncValidationMode`, `notifyInputValidationUpdated` (Task 6).
- Produces:
  ```dart
  // GladeModelBase
  bool get isValidating;
  Future<bool> validateAsync();
  // GladeModel: isValidating = inputs.any; validateAsync awaits all inputs then returns isValid
  // GladeComposedModel: isValidating = models.any; validateAsync awaits all models then returns isValid
  ```

- [x] **Step 1: Write the failing tests**

```dart
// glade_forms/test/model/async_model_test.dart
// ignore_for_file: cascade_invocations, avoid-async-call-in-sync-function, avoid-global-state

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Server {
  final List<Completer<bool>> pending = [];
  int calls = 0;

  Future<bool> check(String value) {
    calls++;
    final completer = Completer<bool>();
    pending.add(completer);

    return completer.future;
  }
}

class _Model extends GladeModel {
  final _Server server;
  final AsyncValidationMode mode;
  final ValidationSeverity asyncSeverity;

  late GladeStringInput username;
  late GladeStringInput email;

  int dependencyCalls = 0;

  @override
  AsyncValidationMode get asyncValidationMode => mode;

  @override
  List<GladeInput<Object?>> get inputs => [username, email];

  _Model(this.server, {this.mode = .strict, this.asyncSeverity = .error});

  @override
  void initialize() {
    username = GladeStringInput(
      inputKey: 'username',
      value: 'initial',
      useTextEditingController: false,
      validator: (v) => (v..satisfyAsync(server.check, key: 'taken', severity: asyncSeverity, devMessage: (_) => 'Taken')).build(
        asyncDebounce: Duration.zero,
      ),
    );
    email = GladeStringInput(
      inputKey: 'email',
      value: 'a@b.c',
      useTextEditingController: false,
      dependencies: () => [username],
      onDependencyChange: (_) => dependencyCalls++,
    );

    super.initialize();
  }
}

void main() {
  setUp(GladeForms.initialize);

  group('strict mode', () {
    test('pure model is valid, async never ran', () {
      // arrange
      final model = _Model(_Server());

      // assert
      expect(model.isValid, isTrue);
      expect(model.isValidating, isFalse);
    });

    test('pending makes model invalid, done valid', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server);
        var notifications = 0;
        model.addListener(() => notifications++);

        // act
        model.updateInput(model.username, 'free');
        async.flushMicrotasks();

        // assert
        expect(model.isValidating, isTrue);
        expect(model.isValid, isFalse);
        expect(model.debugFormattedValidationErrors, contains('username - VALIDATING'));

        server.pending.single.complete(true);
        async.flushMicrotasks();

        expect(model.isValidating, isFalse);
        expect(model.isValid, isTrue);
        expect(notifications, equals(3), reason: 'notifyInputUpdated + updateInput notifyListeners + async completion');
        expect(model.dependencyCalls, equals(1), reason: 'only the value change notifies dependencies');
      });
    });

    test('async error keeps model invalid and formats message', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server);

        // act
        model.updateInput(model.username, 'taken');
        async.flushMicrotasks();
        server.pending.single.complete(false);
        async.flushMicrotasks();

        // assert
        expect(model.isValid, isFalse);
        expect(model.formattedValidationErrors, equals('Taken'));
      });
    });

    test('async warning: pending blocks both, done blocks only isValidWithoutWarnings', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server, asyncSeverity: .warning);

        // act
        model.updateInput(model.username, 'taken');
        async.flushMicrotasks();

        expect(model.isValid, isFalse);
        expect(model.isValidWithoutWarnings, isFalse);

        server.pending.single.complete(false);
        async.flushMicrotasks();

        // assert
        expect(model.isValid, isTrue);
        expect(model.isValidWithoutWarnings, isFalse);
      });
    });
  });

  group('lastKnown mode', () {
    test('pending keeps model valid when sync is valid', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server, mode: .lastKnown);

        // act
        model.updateInput(model.username, 'free');
        async.flushMicrotasks();

        // assert
        expect(model.isValidating, isTrue);
        expect(model.isValid, isTrue);
        expect(model.username.isValid, isTrue);
      });
    });

    test('async error makes model invalid after completion', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server, mode: .lastKnown);

        // act
        model.updateInput(model.username, 'taken');
        async.flushMicrotasks();
        server.pending.single.complete(false);
        async.flushMicrotasks();

        // assert
        expect(model.isValid, isFalse);
      });
    });

    test('changing value after error drops the error immediately', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server, mode: .lastKnown);
        model.updateInput(model.username, 'taken');
        async.flushMicrotasks();
        server.pending[0].complete(false);
        async.flushMicrotasks();
        expect(model.isValid, isFalse);

        // act
        model.updateInput(model.username, 'taken2');
        async.flushMicrotasks();

        // assert
        expect(model.isValid, isTrue);
        expect(model.username.validationErrors, isEmpty);
        expect(model.isValidating, isTrue);
      });
    });
  });

  test('model.validateAsync awaits all inputs and returns final validity', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final model = _Model(server, mode: .lastKnown);
      bool? result;

      // act
      model.updateInput(model.username, 'taken');
      async.flushMicrotasks();
      model.validateAsync().then((r) => result = r);
      async.flushMicrotasks();

      expect(result, isNull);
      expect(server.calls, equals(1), reason: 'joins the in-flight request');

      server.pending.single.complete(false);
      async.flushMicrotasks();

      // assert
      expect(result, isFalse);
    });
  });

  test('composed model aggregates isValidating and validateAsync', () {
    FakeAsync().run((async) {
      // arrange
      final server = _Server();
      final first = _Model(server);
      final second = _Model(server);
      final composed = _Composed([first, second]);
      bool? result;

      // act
      first.updateInput(first.username, 'free');
      async.flushMicrotasks();

      expect(composed.isValidating, isTrue);
      expect(composed.isValid, isFalse);

      composed.validateAsync().then((r) => result = r);
      async.flushMicrotasks();

      expect(server.pending, hasLength(2), reason: 'first joins in-flight, second starts its own request');

      for (final pending in server.pending) {
        pending.complete(true);
      }
      async.flushMicrotasks();

      // assert
      expect(composed.isValidating, isFalse);
      expect(composed.isValid, isTrue);
      expect(result, isTrue);
    });
  });
}

class _Composed extends GladeComposedModel<_Model> {
  _Composed(List<_Model> models) : super(models);
}
```

- [x] **Step 2: Run tests to verify they fail**

Run: `cd glade_forms && fvm flutter test test/model/async_model_test.dart`
Expected: FAIL, `isValidating` undefined on model.

- [x] **Step 3: Implement**

`GladeModelBase`, after `isUnchanged`:

```dart
  /// True when any input's asynchronous validation is scheduled or running.
  bool get isValidating;

  /// Runs asynchronous validation of all inputs immediately, awaits it and returns [isValid].
  ///
  /// Use it before submitting when [AsyncValidationMode.lastKnown] is used, or to validate initial values.
  Future<bool> validateAsync();
```

`GladeModel`:

```dart
  @override
  bool get isValidating => inputs.any((input) => input.isValidating);

  @override
  Future<bool> validateAsync() async {
    await Future.wait(inputs.map((input) => input.validateAsync()));

    return isValid;
  }
```

And in `debugFormattedValidationErrors` add before the `isNotValid` branch:

```dart
        if (e.isValidating) return '${e.inputKey} - VALIDATING';
```

`GladeComposedModel`:

```dart
  @override
  bool get isValidating => models.any((model) => model.isValidating);

  @override
  Future<bool> validateAsync() async {
    await Future.wait(models.map((model) => model.validateAsync()));

    return isValid;
  }
```

- [x] **Step 4: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test && checkme`
Expected: PASS.

- [x] **Step 5: Commit (only if allowed)**

```bash
git add glade_forms/lib/src/model glade_forms/test/model/async_model_test.dart
git commit -m "feat: expose async validation on models"
```

---

### Task 8: Debug info widget and DevTools serialization

**Files:**
- Modify: `glade_forms/lib/src/widgets/glade_form_debug_info.dart`
- Modify: `glade_forms/lib/src/devtools/glade_input_dev_tools_serialization.dart`
- Modify: `glade_forms/lib/src/devtools/glade_model_devtools_serialization.dart`
- Test: `glade_forms/test/devtools_serialization_test.dart` (create if it does not exist; if a devtools serialization test already exists under `glade_forms/test`, append there instead)

**Interfaces:**
- Consumes: `isValidating`, `hasAsyncValidation`, `validatorResult.asyncState` (Task 6, 7).
- Produces: JSON keys `isValidating` (bool), `hasAsyncValidation` (bool), `asyncState` (string, enum name) on input JSON; `isValidating` on model JSON. `GladeFormDebugInfo.showIsValidating` (default `true`) column.

- [x] **Step 1: Write the failing test**

```dart
// glade_forms/test/devtools_serialization_test.dart
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Model extends GladeModel {
  late GladeStringInput name;

  @override
  List<GladeInput<Object?>> get inputs => [name];

  @override
  void initialize() {
    name = GladeStringInput(
      inputKey: 'name',
      value: 'a',
      useTextEditingController: false,
      validator: (v) => (v..satisfyAsync((value) async => true)).build(),
    );

    super.initialize();
  }
}

void main() {
  setUp(GladeForms.initialize);

  test('serialization contains async fields', () {
    // arrange
    final model = _Model();

    // act
    final json = model.toDevToolsJson();
    final inputJson = (json['inputs'] as List<Map<String, dynamic>>).single;

    // assert
    expect(json['isValidating'], isFalse);
    expect(inputJson['isValidating'], isFalse);
    expect(inputJson['hasAsyncValidation'], isTrue);
    expect(inputJson['asyncState'], equals('notRun'));
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd glade_forms && fvm flutter test test/devtools_serialization_test.dart`
Expected: FAIL, `isValidating` key is null.

- [x] **Step 3: Implement**

Input serialization, add to the map (keep alphabetical order):

```dart
      'asyncState': validatorResult.asyncState.name,
      'hasAsyncValidation': hasAsyncValidation,
      'isValidating': isValidating,
```

Model serialization, add:

```dart
      'isValidating': isValidating,
```

`GladeFormDebugInfo` (`glade_form_debug_info.dart`), six edits:

1. Field after `showIsValid` (line 12):
```dart
  /// Whether to show isValidating column.
  final bool showIsValidating;
```
2. Default constructor (line 40): add `this.showIsValidating = true,` after `this.showIsValid = true,`.
3. `GladeFormDebugInfo.clean` constructor (line 54): add `this.showIsValidating = false,` after `this.showIsValid = false,`.
4. `_GladeInputsTable(...)` instantiation (line 185): add `showIsValidating: widget.showIsValidating,` after `showIsValid: widget.showIsValid,`.
5. `_GladeInputsTable` class (line 217 and 230): add `final bool showIsValidating;` after `final bool showIsValid;` and `required this.showIsValidating,` after `required this.showIsValid,`.
6. Table (lines 262 and 283): add `if (showIsValidating) const _ColumnHeader('isValidating'),` after the `isValid` header and `if (showIsValidating) _RowValue(value: x.isValidating),` after the `isValid` value.

In the model summary row (around line 90) add:

```dart
                      Row(
                        children: [
                          const Text('isValidating:'),
                          _BoolIcon(value: model.isValidating),
                        ],
                      ),
```

- [x] **Step 4: DevTools extension UI**

The extension (`glade_forms_devtools_extension`) parses the JSON into `GladeInputDescription`. Add the new fields.

`glade_forms_devtools_extension/lib/src/models/glade_input_description.dart`:

```dart
  final bool isValidating;
  final bool hasAsyncValidation;
  final String asyncState;

  /// Label for async validation state.
  String get asyncLabel => isValidating ? 'Validating' : asyncState;

  /// Color for async validation state.
  Color get asyncColor => isValidating ? Constants.warningColor : Constants.successColor;
```

Constructor: `required this.isValidating, required this.hasAsyncValidation, required this.asyncState,`.
`fromJson` (tolerate older library versions):

```dart
      isValidating: json['isValidating'] as bool? ?? false,
      hasAsyncValidation: json['hasAsyncValidation'] as bool? ?? false,
      asyncState: json['asyncState'] as String? ?? 'notRun',
```

`toJson`: add `'asyncState': asyncState, 'hasAsyncValidation': hasAsyncValidation, 'isValidating': isValidating,` (alphabetical).

`glade_forms_devtools_extension/lib/src/widgets/detail/glade_input_card.dart`, after the `Unchanged` / `Pure` row add:

```dart
                if (input.hasAsyncValidation)
                  Row(
                    children: [
                      Expanded(child: InfoRow(label: 'Validating', value: input.isValidating, hasInverseBoolColors: true)),
                      Expanded(child: InfoRow(label: 'Async state', value: input.asyncState)),
                    ],
                  ),
```

and change the leading icon so a validating input shows an hourglass:

```dart
        leading: Icon(
          input.isValidating ? Icons.hourglass_top : (input.isValid ? Icons.check_circle : Icons.error),
          color: input.isValidating ? Colors.orange : (input.isValid ? Colors.green : Colors.red),
        ),
```

`glade_forms_devtools_extension/lib/src/debug/mock_data.dart`: every `GladeInputDescription(` construction gets `isValidating: false, hasAsyncValidation: false, asyncState: 'notRun',`.

Run: `cd glade_forms_devtools_extension && fvm flutter analyze`
Expected: no issues. Rebuilding the extension bundle (`melos run build:extension`) is a release step, not part of this task.

- [x] **Step 5: Run tests and analysis**

Run: `cd glade_forms && fvm flutter test && checkme`
Expected: PASS.

- [x] **Step 6: Commit (only if allowed)**

```bash
git add glade_forms/lib/src/widgets/glade_form_debug_info.dart glade_forms/lib/src/devtools glade_forms/test/devtools_serialization_test.dart glade_forms_devtools_extension/lib
git commit -m "feat: show async validation state in debug tools"
```

---

### Task 9: `TextFormField` widget test

**Files:**
- Modify: `glade_forms/pubspec.yaml` (dev dependency `flutter_test: sdk: flutter`)
- Test: `glade_forms/test/widgets/async_text_form_field_test.dart`

**Interfaces:**
- Consumes: everything from Task 6 and 7. No production code changes expected; if the test reveals a defect, fix it in `glade_input.dart` and add a matching unit test to `test/async_input_test.dart`.

- [x] **Step 1: Add dev dependency**

In `glade_forms/pubspec.yaml` under `dev_dependencies` add:

```yaml
  flutter_test:
    sdk: flutter
```

Run `cd glade_forms && fvm flutter pub get`.

- [x] **Step 2: Write the test**

```dart
// glade_forms/test/widgets/async_text_form_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms/glade_forms.dart';

class _Model extends GladeModel {
  final Set<String> taken;
  late GladeStringInput username;

  int serverCalls = 0;

  @override
  List<GladeInput<Object?>> get inputs => [username];

  _Model({required this.taken, required String initial}) : _initial = initial;

  final String _initial;

  @override
  void initialize() {
    username = GladeStringInput(
      inputKey: 'username',
      initialValue: _initial,
      validator: (v) => (v
            ..satisfyAsync(
              (value) async {
                serverCalls++;
                await Future<void>.delayed(const Duration(milliseconds: 100));
                return !taken.contains(value);
              },
              key: 'taken',
              devMessage: (_) => 'Username is taken',
            ))
          .build(asyncDebounce: const Duration(milliseconds: 300)),
    );

    super.initialize();
  }
}

Widget _app(_Model model, AutovalidateMode mode) => MaterialApp(
  home: Scaffold(
    body: GladeFormBuilder<_Model>.value(
      value: model,
      builder: (context, model, _) => Form(
        autovalidateMode: mode,
        child: TextFormField(
          controller: model.username.controller,
          validator: model.username.textFormFieldInputValidator,
          decoration: InputDecoration(
            suffixIcon: model.username.isValidating ? const Icon(Icons.hourglass_top, key: Key('spinner')) : null,
          ),
        ),
      ),
    ),
  ),
);

void main() {
  setUp(GladeForms.initialize);

  testWidgets('onUserInteraction: async error appears after response without further interaction', (tester) async {
    // arrange
    final model = _Model(taken: {'taken'}, initial: '');
    await tester.pumpWidget(_app(model, AutovalidateMode.onUserInteraction));

    // act
    await tester.enterText(find.byType(TextFormField), 'taken');
    await tester.pump();

    // assert: pending, no message, spinner shown
    expect(find.text('Username is taken'), findsNothing);
    expect(find.byKey(const Key('spinner')), findsOneWidget);
    expect(model.isValid, isFalse);

    await tester.pump(const Duration(milliseconds: 300)); // debounce
    await tester.pump(const Duration(milliseconds: 100)); // server
    await tester.pump(); // rebuild after notifyListeners

    expect(find.text('Username is taken'), findsOneWidget);
    expect(find.byKey(const Key('spinner')), findsNothing);
    expect(model.serverCalls, equals(1));

    model.dispose();
  });

  testWidgets('always: initial value is validated asynchronously on first build', (tester) async {
    // arrange
    final model = _Model(taken: {'taken'}, initial: 'taken');

    // act
    await tester.pumpWidget(_app(model, AutovalidateMode.always));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // assert
    expect(model.serverCalls, equals(1));
    expect(find.text('Username is taken'), findsOneWidget);

    model.dispose();
  });

  testWidgets('onUserInteraction: initial value is not validated until interaction', (tester) async {
    // arrange
    final model = _Model(taken: {'taken'}, initial: 'taken');

    // act
    await tester.pumpWidget(_app(model, AutovalidateMode.onUserInteraction));
    await tester.pump(const Duration(seconds: 1));

    // assert
    expect(model.serverCalls, equals(0));
    expect(model.isValid, isTrue);

    model.dispose();
  });
}
```

- [x] **Step 3: Run the test**

Run: `cd glade_forms && fvm flutter test test/widgets/async_text_form_field_test.dart`
Expected: PASS. If the first test fails on the "message appears" assertion, check that `GladeFormBuilder.value` rebuilds on `notifyListeners` (it uses `Consumer<M>`), and that `_onAsyncValidationCompleted` reaches `notifyInputValidationUpdated`.

- [x] **Step 4: Run full suite and analysis**

Run: `cd glade_forms && fvm flutter test && checkme`
Expected: PASS.

- [x] **Step 5: Commit (only if allowed)**

```bash
git add glade_forms/pubspec.yaml glade_forms/test/widgets/async_text_form_field_test.dart
git commit -m "feat: cover TextFormField async validation contract"
```

---

### Task 10: Storybook examples

**Files:**
- Create: `storybook/lib/shared/fake_validation_server.dart`
- Create: `storybook/lib/usecases/async/username_availability_example.dart`
- Create: `storybook/lib/usecases/async/dependency_revalidation_example.dart`
- Modify: `storybook/lib/main.dart` (imports + new `WidgetbookCategory`)
- Modify: `storybook/pubspec.yaml` (asset folder `lib/usecases/async/`)

**Interfaces:**
- Consumes: public API from Tasks 3, 6, 7.
- Produces: no library code. Verified by `cd storybook && fvm flutter analyze` and a manual run (`fvm flutter run -d chrome` or macOS).

- [x] **Step 1: Fake server**

```dart
// storybook/lib/shared/fake_validation_server.dart
/// Simulates a backend used by async validation examples.
class FakeValidationServer {
  final Set<String> takenUsernames = {'admin', 'glade', 'petr'};

  /// Allowed email domain per organisation.
  final Map<String, String> organisationDomains = {'netglade': 'netglade.cz', 'acme': 'acme.com'};

  Duration delay;
  bool failing;

  int requestCount = 0;

  FakeValidationServer({this.delay = const Duration(milliseconds: 800), this.failing = false});

  Future<bool> isUsernameAvailable(String username) async {
    requestCount++;
    await Future<void>.delayed(delay);

    if (failing) throw Exception('Server unavailable');

    return !takenUsernames.contains(username.trim().toLowerCase());
  }

  Future<bool> isEmailAllowedInOrganisation(String email, String organisation) async {
    requestCount++;
    await Future<void>.delayed(delay);

    if (failing) throw Exception('Server unavailable');

    final domain = organisationDomains[organisation];

    return domain == null || email.trim().toLowerCase().endsWith('@$domain');
  }
}
```

- [x] **Step 2: Username availability example**

```dart
// storybook/lib/usecases/async/username_availability_example.dart
import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/fake_validation_server.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';
import 'package:widgetbook/widgetbook.dart';

class _Model extends GladeModel {
  final FakeValidationServer server;
  final AsyncValidationMode mode;
  final Duration debounce;

  late GladeStringInput username;

  @override
  AsyncValidationMode get asyncValidationMode => mode;

  @override
  List<GladeInput<Object?>> get inputs => [username];

  _Model({required this.server, required this.mode, required this.debounce});

  @override
  void initialize() {
    username = GladeStringInput(
      inputKey: 'username',
      value: '',
      validator: (v) => (v
            ..minLength(length: 3)
            ..satisfyAsync(
              server.isUsernameAvailable,
              key: 'username-taken',
              devMessage: (value) => 'Username "$value" is already taken',
            ))
          .build(asyncDebounce: debounce),
      defaultValidationTranslations: const DefaultValidationTranslations(
        defaultAsyncValidationFailedMessage: 'Could not verify username, try again',
      ),
    );

    super.initialize();
  }
}

class UsernameAvailabilityExample extends StatelessWidget {
  const UsernameAvailabilityExample({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.knobs.list<AsyncValidationMode>(
      label: 'Async validation mode',
      options: AsyncValidationMode.values,
      labelBuilder: (mode) => mode.name,
    );
    final debounceMs = context.knobs.int.slider(label: 'Debounce (ms)', initialValue: 300, min: 0, max: 2000);
    final serverDelayMs = context.knobs.int.slider(label: 'Server delay (ms)', initialValue: 800, min: 0, max: 3000);
    final serverFailing = context.knobs.boolean(label: 'Server failing', initialValue: false);

    return UsecaseContainer(
      shortDescription: 'Async validation: username availability',
      description: '''
Type a username. Taken usernames: `admin`, `glade`, `petr`.

- Synchronous rule (min length 3) runs first; the server is asked only when it passes.
- Requests are debounced; rapid typing produces one request.
- **strict** mode: the Save button is disabled while validating.
- **lastKnown** mode: the Save button stays enabled while validating and `onPressed` awaits `model.validateAsync()` before saving.
- Toggle *Server failing* to see `onError` default handling (`AsyncValidationFailedError` with a default message).
''',
      className: 'async/username_availability_example.dart',
      child: KeyedSubtree(
        key: ValueKey('$mode-$debounceMs'),
        child: GladeFormBuilder.create(
          // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
          create: (context) => _Model(
            server: FakeValidationServer(delay: Duration(milliseconds: serverDelayMs), failing: serverFailing),
            mode: mode,
            debounce: Duration(milliseconds: debounceMs),
          ),
          builder: (context, model, _) {
            model.server
              ..delay = Duration(milliseconds: serverDelayMs)
              ..failing = serverFailing;

            return Padding(
              padding: const .all(32),
              child: Form(
                autovalidateMode: .onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: model.username.controller,
                      validator: model.username.textFormFieldInputValidator,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        suffixIcon: model.username.isValidating
                            ? const Padding(
                                padding: .all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : (model.username.isValid && !model.username.isPure ? const Icon(Icons.check) : null),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Mode: ${model.asyncValidationMode.name}, requests: ${model.server.requestCount}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: model.isValid ? () => _save(context, model) : null,
                      child: const Text('Save'),
                    ),
                    const GladeFormDebugInfo<_Model>(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, _Model model) async {
    final messenger = ScaffoldMessenger.of(context);
    final isValid = await model.validateAsync();

    messenger.showSnackBar(SnackBar(content: Text(isValid ? 'Saved' : 'Validation failed after awaiting server')));
  }
}
```

- [x] **Step 3: Dependency revalidation example**

```dart
// storybook/lib/usecases/async/dependency_revalidation_example.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/fake_validation_server.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends GladeModel {
  final FakeValidationServer server = FakeValidationServer(delay: const Duration(milliseconds: 500));

  late GladeInput<String> organisation;
  late GladeStringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [organisation, email];

  @override
  void initialize() {
    organisation = GladeInput.required(inputKey: 'organisation', value: 'netglade');
    email = GladeStringInput(
      inputKey: 'email',
      value: '',
      dependencies: () => [organisation],
      onDependencyChange: (_) => unawaited(email.validateAsync(force: true)),
      validator: (v) => (v
            ..isEmail()
            ..customAsync(
              (value, key) async {
                final allowed = await server.isEmailAllowedInOrganisation(value, organisation.value);

                return allowed
                    ? null
                    : ValueError(
                        value: value,
                        key: key,
                        devMessage: (_) => 'Email must belong to ${organisation.value} domain',
                      );
              },
              key: 'email-domain',
            ))
          .build(asyncDebounce: const Duration(milliseconds: 300)),
    );

    super.initialize();
  }
}

class DependencyRevalidationExample extends StatelessWidget {
  const DependencyRevalidationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Async validation: dependency revalidation',
      description: '''
Email is validated against the selected organisation's domain (`netglade` → `@netglade.cz`, `acme` → `@acme.com`, `other` → anything).

Changing the organisation does not change the email value, so the cached async result would stay.
`onDependencyChange` calls `email.validateAsync(force: true)` to re-run it.

The dropdown updates the input through `model.updateInput`, which is a trigger as well, no `FormField` involved.
''',
      className: 'async/dependency_revalidation_example.dart',
      child: GladeFormBuilder.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => _Model(),
        builder: (context, model, _) => Padding(
          padding: const .all(32),
          child: Form(
            autovalidateMode: .onUserInteraction,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: model.organisation.value,
                  decoration: const InputDecoration(labelText: 'Organisation'),
                  items: const [
                    DropdownMenuItem(value: 'netglade', child: Text('netglade')),
                    DropdownMenuItem(value: 'acme', child: Text('acme')),
                    DropdownMenuItem(value: 'other', child: Text('other')),
                  ],
                  onChanged: (value) => model.updateInput(model.organisation, value ?? model.organisation.value),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: model.email.controller,
                  validator: model.email.textFormFieldInputValidator,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    suffixIcon: model.email.isValidating
                        ? const Padding(
                            padding: .all(12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Requests: ${model.server.requestCount}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: model.isValid
                      ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')))
                      : null,
                  child: const Text('Save'),
                ),
                const GladeFormDebugInfo<_Model>(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

If `DropdownButtonFormField.initialValue` does not exist in the pinned Flutter version, use `value:` instead.

- [x] **Step 4: Register in `main.dart` and assets**

Imports:

```dart
import 'package:glade_forms_storybook/usecases/async/dependency_revalidation_example.dart';
import 'package:glade_forms_storybook/usecases/async/username_availability_example.dart';
```

Add a category after `'Warning input example'`:

```dart
        WidgetbookCategory(
          name: 'Async validation',
          children: [
            WidgetbookUseCase(
              name: 'Username availability (modes, debounce, failures)',
              builder: (context) => const UsernameAvailabilityExample(),
            ),
            WidgetbookUseCase(
              name: 'Dependency revalidation',
              builder: (context) => const DependencyRevalidationExample(),
            ),
          ],
        ),
```

In `storybook/pubspec.yaml` under `flutter.assets` add `- lib/usecases/async/`.

- [x] **Step 5: Analyse and run**

Run: `cd storybook && fvm flutter pub get && fvm flutter analyze && dcm analyze . --fatal-style --fatal-performance --fatal-warnings`
Expected: no issues.

Run: `cd storybook && fvm flutter run -d chrome` (or `-d macos`), open both use cases, verify: spinner while validating, message after response, Save button disabled in strict while validating and enabled in lastKnown, server failing shows the default failure message, changing organisation re-runs email validation.

- [x] **Step 6: Commit (only if allowed)**

```bash
git add storybook
git commit -m "feat: add async validation storybook examples"
```

---

### Task 11: Documentation

**Files:**
- Create: `docs/async-validation.mdx`
- Modify: `docs/docs.json`
- Modify: `docs/validation.mdx`, `docs/glade-model.mdx`, `docs/translations.mdx`, `docs/advanced/dependencies.mdx`, `docs/advanced/debugging.mdx`
- Modify: `README.md`

**Interfaces:**
- Consumes: final public API names from Tasks 2 to 7. Before writing, grep the implemented signatures (`customAsync`, `satisfyAsync`, `validateAsync`, `AsyncValidationMode`, `isValidating`, `asyncDebounce`) and use them verbatim.

- [x] **Step 1: New page**

````mdx
---
title: Async validation
description: Validate input values against a server or any other asynchronous source.
---

Asynchronous validators run next to synchronous ones. A typical case is checking whether a username is available.

```dart
username = GladeStringInput(
  inputKey: 'username',
  validator: (v) => (v
        ..minLength(length: 3)
        ..satisfyAsync(
          (value) => api.isUsernameAvailable(value),
          key: 'username-taken',
          devMessage: (value) => 'Username "$value" is already taken',
        ))
      .build(),
);
```

Two async parts are available on the validator:

- `satisfyAsync(predicate)` - asynchronous predicate. When it returns `false`, a `ValueSatisfyPredicateError` is reported.
- `customAsync((value, key) async => ...)` - returns a `GladeValidatorResult` or `null` when the value is valid.

Both accept the same `key`, `severity`, `shouldValidate` options as their synchronous counterparts, plus:

- `runOnlyWhenSyncValid` (default `true`) - the part runs only when synchronous validation produced no error. There is no point asking a server about an empty email.
- `onError` - handles exceptions thrown by the part. Return a result to report it, or `null` to treat the value as valid. Without `onError` an `AsyncValidationFailedError` with key `GladeValidationsKeys.asyncValidationFailed` is reported.

Async parts run sequentially in declaration order and respect `stopOnFirstError` and `stopOnFirstErrorOrWarning` the same way synchronous parts do.
When the synchronous half already stopped validation, no async part runs.

## How it fits Flutter forms

`TextFormField.validator` is synchronous, so async validation is split into two halves:

1. **Running** happens in the background. Validation requests (value change, `input.validate()`, `textFormFieldInputValidator`, `formFieldValidator`, `validateAsync()`) schedule a run. Rapid changes are merged by a debounce. The result is cached together with the value it was produced for.
2. **Reading** stays synchronous. `textFormFieldInputValidator`, `validatorResult`, `isValid` return synchronous results merged with the cached async result.

When a run finishes the model notifies its listeners, the form rebuilds and `TextFormField` re-runs the validator, which now sees the cached result. No special widget is needed:

```dart
TextFormField(
  controller: model.username.controller,
  validator: model.username.textFormFieldInputValidator,
  decoration: InputDecoration(
    labelText: 'Username',
    suffixIcon: model.username.isValidating ? const CircularProgressIndicator() : null,
  ),
)
```

Getters such as `isValid`, `validatorResult` or `validationErrors` never start a request. Only validation requests do.
That is why the form's `autovalidateMode` decides when the initial value is validated:

| autovalidateMode | Async validation of the initial value runs |
|---|---|
| `.always` | on the first build |
| `.onUserInteraction` | after the first change |
| `.disabled` | on `formKey.currentState.validate()` or on value change |

Widgets without `FormField` (dropdowns, pickers) go through `model.updateInput` or `input.updateValue`, which trigger async validation as well. Read the message from `input.errorFormatted()`.

## Pending state and `AsyncValidationMode`

While a run is scheduled or in flight, `input.isValidating` and `model.isValidating` are `true` and `validatorResult.asyncState` is `AsyncValidationState.pending`.
What `isValid` returns during that time is decided per model:

```dart
class MyModel extends GladeModel {
  @override
  AsyncValidationMode get asyncValidationMode => AsyncValidationMode.lastKnown;
}
```

| Scenario | `strict` (default) | `lastKnown` |
|---|---|---|
| Async never ran for the current value | synchronous result | synchronous result |
| Synchronous validation failed | `false` (async is skipped) | `false` |
| Value changed, request scheduled or in flight | `false` | synchronous result |
| Async finished with an error | `false` | `false` |
| Async finished, valid | `true` | `true` |
| Async threw (default `onError`) | `false` | `false` |

The modes differ in one situation only: the current value has not been verified yet and synchronous validation passed.
`strict` blocks a submit button bound to `model.isValid`. `lastKnown` keeps it enabled, so await the server before saving:

```dart
onPressed: () async {
  final isValid = await model.validateAsync();
  if (isValid) save();
}
```

`model.validateAsync()` runs pending validations immediately (skipping the debounce), joins requests already in flight, reuses finished results and returns `isValid` after everything completed. It works in both modes.

A response that arrives for a value the user already changed is discarded. Every finished result exposes `validatorResult.asyncValidatedValue`, the value it was produced for.

## Debounce

The debounce is configured per validator in `build()`:

```dart
validator: (v) => (v..satisfyAsync(api.isUsernameAvailable)).build(asyncDebounce: const Duration(milliseconds: 500)),
```

Default is 300 ms. `Duration.zero` starts the request immediately. `validateAsync()` always skips the debounce.

## Dependencies

An async validator may read other inputs. When such an input changes, the value of the validated input stays the same and the cached result would be kept.
Re-run it explicitly:

```dart
email = GladeStringInput(
  dependencies: () => [organisation],
  onDependencyChange: (_) => unawaited(email.validateAsync(force: true)),
  validator: (v) => (v
        ..customAsync((value, key) async {
          final allowed = await api.isEmailAllowed(value, organisation.value);
          return allowed ? null : ValueError(value: value, key: key, devMessage: (_) => 'Email not allowed');
        }))
      .build(),
);
```

`force: true` drops the cached result and any request in flight before running.

## Translations

Async results go through the same translation pipeline as synchronous ones, identified by their `key`.
Failures produced by the default `onError` use `GladeValidationsKeys.asyncValidationFailed`; the exception is available as `AsyncValidationFailedError.error`.
`DefaultValidationTranslations.defaultAsyncValidationFailedMessage` sets a fallback message for them.

## Lifecycle notes

- `resetToInitialValue()` and `setNewInitialValue()` drop the cached result and discard requests in flight. The input is back to "async never ran".
- `dispose()` discards requests in flight; late responses are ignored.
- `GladeComposedModel.isValidating` is `true` when any child model is validating, `validateAsync()` awaits all children.
````

The outer four-backtick fence only embeds the document in this plan; the file itself uses regular three-backtick fences.

- [x] **Step 2: Sidebar**

In `docs/docs.json` add after the Validations page:

```json
        {
          "title": "Async validation",
          "href": "/async-validation",
          "icon": "cloud-arrow-up"
        },
```

- [x] **Step 3: Cross references**

`docs/validation.mdx`, after the paragraph about `textFormFieldInputValidator` (line 56), add:

```mdx
Validators can also be asynchronous, for example a server lookup. See [Async validation](/async-validation).
```

`docs/glade-model.mdx`, before `## Debug metadata`, add:

```mdx
## Async validation

When inputs declare asynchronous validators, the model exposes:

- `isValidating` - `true` while any input's async validation is scheduled or running.
- `validateAsync()` - runs pending async validations immediately, awaits them and returns `isValid`.
- `asyncValidationMode` - override to choose how pending validation affects `isValid`. See [Async validation](/async-validation).
```

`docs/translations.mdx`, at the end of the default translations section, add:

```mdx
Failures of asynchronous validators (an exception without custom `onError`) are reported with key `GladeValidationsKeys.asyncValidationFailed`.
Use `defaultAsyncValidationFailedMessage` in `DefaultValidationTranslations` to provide a fallback message.
```

`docs/advanced/dependencies.mdx`, at the end, add:

````mdx
## Dependencies and async validation

Changing a dependency does not change the dependent input's value, so its cached asynchronous result stays.
Re-run it with `validateAsync(force: true)`:

```dart
emailInput = GladeStringInput(
  dependencies: () => [organisationInput],
  onDependencyChange: (_) => unawaited(emailInput.validateAsync(force: true)),
);
```
````

`docs/advanced/debugging.mdx`, in the `GladeFormDebugInfo` section, add:

```mdx
Inputs with asynchronous validators show an `isValidating` column. The DevTools extension reports `isValidating`, `hasAsyncValidation` and `asyncState` per input.
```

`README.md`, at the end of the Getting started section (before `## 🔍 DevTools Extension`), add:

```md
### Async validation

Validators can be asynchronous (`satisfyAsync`, `customAsync`), with debounce, race protection and a per-model policy for the pending state. `TextFormField` integration stays the same. See the [Async validation docs](https://glade-forms.docs.page/async-validation).
```

Check the actual docs.page base URL in the README's existing documentation link and use the same host.

- [x] **Step 4: Verify**

Run: `cd storybook && fvm flutter analyze` (no code changed, sanity). Open `docs/async-validation.mdx` and confirm every identifier exists in the library by grepping `glade_forms/lib` for `customAsync`, `satisfyAsync`, `runOnlyWhenSyncValid`, `asyncDebounce`, `validateAsync`, `AsyncValidationMode`, `isValidating`, `asyncValidatedValue`, `defaultAsyncValidationFailedMessage`, `AsyncValidationFailedError`.

- [x] **Step 5: Commit (only if allowed)**

```bash
git add docs README.md
git commit -m "feat: document async validation"
```

---

### Task 12: Version and changelog

**Files:**
- Modify: `glade_forms/pubspec.yaml` (`version: 6.2.0`)
- Modify: `glade_forms/CHANGELOG.md`

- [x] **Step 1: Bump version**

Change `version: 6.1.0` to `version: 6.2.0` in `glade_forms/pubspec.yaml`.

- [x] **Step 2: Changelog entry**

Prepend to `glade_forms/CHANGELOG.md`:

```md
## 6.2.0
- **[Add]**: Asynchronous validation ([#12](https://github.com/netglade/glade_forms/issues/12)).
  - New validator parts `satisfyAsync()` and `customAsync()` with `runOnlyWhenSyncValid` and `onError` options; `build(asyncDebounce:)` configures debounce (default 300 ms).
  - `GladeInput` gains `isValidating`, `hasAsyncValidation` and `validateAsync({force})`. Validation requests (`validate()`, `textFormFieldInputValidator`, `formFieldValidator`, value changes) trigger async validation; getters only read.
  - `ValidatorResult` gains `asyncState`, `asyncValidatedValue` and `isValidating`.
  - `GladeModel.asyncValidationMode` (`strict` default, `lastKnown`) decides how pending async validation affects `isValid`. Models expose `isValidating` and `validateAsync()`.
  - `AsyncValidationFailedError` with key `GladeValidationsKeys.asyncValidationFailed` reports exceptions from async validators; `DefaultValidationTranslations.defaultAsyncValidationFailedMessage` provides a fallback message.
  - `GladeFormDebugInfo` and the DevTools extension show async validation state.

```

- [x] **Step 3: Final verification**

Run: `cd glade_forms && fvm flutter test && checkme && cd ../storybook && fvm flutter analyze`
Expected: all PASS, no issues.

- [x] **Step 4: Commit (only if allowed)**

```bash
git add glade_forms/pubspec.yaml glade_forms/CHANGELOG.md
git commit -m "release: bump version to 6.2.0"
```
