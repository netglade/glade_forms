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


class _TeamComposed extends GladeComposedModel<_Model> {
  final _Server server;
  final AsyncValidationMode mode;

  late GladeStringInput teamName;

  @override
  AsyncValidationMode get asyncValidationMode => mode;

  @override
  List<GladeInput<Object?>> get inputs => [teamName];

  _TeamComposed(this.server, {this.mode = .strict, List<_Model>? initialModels}) : super(initialModels);

  @override
  void initialize() {
    teamName = GladeStringInput(
      inputKey: 'team-name',
      value: 'team',
      useTextEditingController: false,
      validator: (v) =>
          (v..satisfyAsync(server.check, key: 'team-taken', devMessage: (_) => 'Team taken')).build(
            asyncDebounce: .zero,
          ),
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
        expect(notifications, equals(2), reason: 'the value update plus the async completion');
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
  group("composed model's own inputs", () {
    test('strict mode: a pending own input makes the composed model invalid', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final composed = _TeamComposed(server, initialModels: [_Model(server)]);

        // act
        composed.updateInput(composed.teamName, 'renamed');
        async.flushMicrotasks();

        // assert
        expect(composed.isValidating, isTrue);
        expect(composed.isAsyncValidationRunning, isTrue);
        expect(composed.isValid, isFalse, reason: 'own input is pending even though every model is valid');

        server.completeAll(result: true);
        async.flushMicrotasks();

        expect(composed.isValidating, isFalse);
        expect(composed.isValid, isTrue);

        composed.dispose();
      });
    });

    test('own inputs read asyncValidationMode from the composed model', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final composed = _TeamComposed(server, mode: .lastKnown);

        // act
        composed.updateInput(composed.teamName, 'renamed');
        async.flushMicrotasks();

        // assert
        expect(composed.isValidating, isTrue);
        expect(composed.teamName.isValid, isTrue, reason: 'lastKnown is taken from the owning composed model');
        expect(composed.isValid, isTrue);

        server.completeAll(result: false);
        async.flushMicrotasks();

        expect(composed.isValid, isFalse);
        expect(composed.formattedValidationErrors, equals('Team taken'));

        composed.dispose();
      });
    });

    test('the mode is per owner, it is not inherited by contained models', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final child = _Model(server);
        final composed = _TeamComposed(server, mode: .lastKnown, initialModels: [child]);

        // act
        composed.updateInput(composed.teamName, 'renamed');
        async.flushMicrotasks();

        // assert
        expect(composed.isValid, isTrue, reason: "own input follows the composed model's lastKnown");

        child.updateInput(child.username, 'pending');
        async.flushMicrotasks();

        expect(composed.isValid, isFalse, reason: 'the child keeps its own strict mode and blocks the aggregate');

        composed.dispose();
      });
    });

    test('completion of an own input notifies the composed model', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final composed = _TeamComposed(server);
        var notifications = 0;

        void onComposedChanged() => notifications++;

        composed.addListener(onComposedChanged);

        // act
        final teamName = composed.teamName;

        composed.updateInput(teamName, 'renamed');
        async.flushMicrotasks();

        final beforeCompletion = notifications;

        server.completeAll(result: true);
        async.flushMicrotasks();

        // assert
        expect(notifications, greaterThan(beforeCompletion));

        composed
          ..removeListener(onComposedChanged)
          ..dispose();
      });
    });

    test('validateAsync awaits own inputs and contained models', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final child = _Model(server);
        final composed = _TeamComposed(server, initialModels: [child]);
        bool? result;

        // act
        composed.updateInput(composed.teamName, 'renamed');
        child.updateInput(child.username, 'pending');
        async.flushMicrotasks();

        expect(server.pending, hasLength(2), reason: 'one request per level');

        unawaited(composed.validateAsync().then((r) => result = r));
        async.flushMicrotasks();

        expect(result, isNull, reason: 'still waiting for both levels');

        server.completeAll(result: true);
        async.flushMicrotasks();

        // assert
        expect(result, isTrue);
        expect(composed.isValidating, isFalse);

        composed.dispose();
      });
    });

    test('an async completion does not break an open groupEdit batch', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final child = _Model(server);
        final composed = _TeamComposed(server, initialModels: [child]);
        var notifications = 0;

        void onComposedChanged() => notifications++;

        composed.addListener(onComposedChanged);

        // act
        final teamName = composed.teamName;

        composed.groupEdit(() {
          composed.updateInput(teamName, 'renamed');
          child.updateInput(child.username, 'pending');
        });

        // assert
        expect(notifications, equals(1), reason: 'the batch notifies once, microtasks can not interleave with it');

        async.flushMicrotasks();
        server.completeAll(result: true);
        async.flushMicrotasks();

        expect(notifications, greaterThan(1), reason: 'completions notify after the batch closed');
        expect(composed.isValid, isTrue);

        composed
          ..removeListener(onComposedChanged)
          ..dispose();
      });
    });

    test('disposing the composed model while an own request is in flight is safe', () {
      FakeAsync().run((async) {
        // arrange
        final server = _Server();
        final composed = _TeamComposed(server, initialModels: [_Model(server)]);
        final ownInput = composed.teamName;

        // act
        composed.updateInput(ownInput, 'renamed');
        async.flushMicrotasks();
        composed.dispose();
        server.completeAll(result: false);
        async.flushMicrotasks();

        // assert
        expect(ownInput.isDisposed, isTrue);
        expect(ownInput.isValidating, isFalse);
      });
    });
  });
}
