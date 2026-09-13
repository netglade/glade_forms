// ignore_for_file: avoid-async-call-in-sync-function, avoid-global-state, prefer-async-await
// ignore_for_file: avoid-passing-self-as-argument, model.updateInput(model.input, value) is the public API shape

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

  void completeAll({required bool result}) {
    for (final completer in pending) {
      if (!completer.isCompleted) completer.complete(result);
    }
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
      validator: (v) =>
          (v..satisfyAsync(server.check, key: 'taken', severity: asyncSeverity, devMessage: (_) => 'Taken')).build(
            asyncDebounce: .zero,
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

class _Composed extends GladeComposedModel<_Model> {
  _Composed(super.initialModels);
}

void main() {
  setUp(GladeForms.initialize);

  group('strict mode', () {
    test('pure model is valid, async never ran', () {
      // arrange
      final model = _Model(_Server());

      // act
      final isValid = model.isValid;

      // assert
      expect(isValid, isTrue);
      expect(model.isValidating, isFalse);
    });

    test('pending makes model invalid, done valid', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final model = _Model(server);
        var notifications = 0;
        void onNotify() => notifications++;
        model.addListener(onNotify);

        // act
        // ignore: cascade_invocations, arrange and act sections
        model.updateInput(model.username, 'free');
        async.flushMicrotasks();

        // assert
        expect(model.isValidating, isTrue);
        expect(model.isValid, isFalse);
        expect(model.debugFormattedValidationErrors, contains('username - VALIDATING'));

        server.completeAll(result: true);
        async.flushMicrotasks();

        expect(model.isValidating, isFalse);
        expect(model.isValid, isTrue, reason: 'async finished valid');
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
        server.completeAll(result: false);
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

        // assert
        expect(model.isValid, isFalse, reason: 'pending');
        expect(model.isValidWithoutWarnings, isFalse, reason: 'pending');

        server.completeAll(result: false);
        async.flushMicrotasks();

        expect(model.isValid, isTrue, reason: 'warning does not block');
        expect(model.isValidWithoutWarnings, isFalse, reason: 'warning present');
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
        server.completeAll(result: false);
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
        server.completeAll(result: false);
        async.flushMicrotasks();
        expect(model.isValid, isFalse, reason: 'precondition: error known');

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
      unawaited(model.validateAsync().then((r) => result = r));
      async.flushMicrotasks();

      // assert
      expect(result, isNull, reason: 'still waiting for server');
      expect(server.calls, equals(1), reason: 'joins the in-flight request');

      server.completeAll(result: false);
      async.flushMicrotasks();

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

      // assert
      expect(composed.isValidating, isTrue);
      expect(composed.isValid, isFalse);

      unawaited(composed.validateAsync().then((r) => result = r));
      async.flushMicrotasks();

      expect(server.pending, hasLength(2), reason: 'first joins in-flight, second starts its own request');

      server.completeAll(result: true);
      async.flushMicrotasks();

      expect(composed.isValidating, isFalse);
      expect(composed.isValid, isTrue);
      expect(result, isTrue);
    });
  });
}
