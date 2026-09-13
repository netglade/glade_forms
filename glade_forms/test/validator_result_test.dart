import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  setUp(GladeForms.initialize);

  test('ValidatorResult defaults to notRun async state', () {
    // arrange
    const result = ValidatorResult<int>(all: [], errors: [], warnings: [], associatedInput: null);

    // act
    final isValidating = result.isValidating;

    // assert
    expect(isValidating, isFalse);
    expect(result.asyncState, equals(AsyncValidationState.notRun));
    expect(result.asyncValidatedValue, isNull);
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
    final error = AsyncValidationFailedError(
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
