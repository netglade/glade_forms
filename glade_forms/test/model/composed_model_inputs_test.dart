// ignore_for_file: cascade_invocations, avoid-duplicate-test-assertions

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _MemberModel extends GladeModel {
  late GladeStringInput firstName;

  @override
  List<GladeInput<Object?>> get inputs => [firstName];

  @override
  void initialize() {
    firstName = GladeStringInput(value: '', inputKey: 'firstName', validator: (v) => (v..notEmpty()).build());

    super.initialize();
  }
}

/// Composed model with its own inputs - `teamName` and `motto`, where `motto` depends on `teamName`.
class _TeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput teamName;
  late GladeStringInput motto;

  int mottoDependencyCalls = 0;
  List<String> mottoDependencyKeys = [];

  @override
  List<GladeInput<Object?>> get inputs => [teamName, motto];

  _TeamModel([super.initialModels]);

  @override
  void initialize() {
    teamName = GladeStringInput(value: '', inputKey: 'teamName', validator: (v) => (v..notEmpty()).build());
    motto = GladeStringInput(
      initialValue: 'motto',
      inputKey: 'motto',
      dependencies: () => [teamName],
      onDependencyChange: (keys) {
        mottoDependencyCalls++;
        mottoDependencyKeys = keys;
      },
    );

    super.initialize();
  }
}

/// Composed model without own inputs - must behave exactly as before own inputs were supported.
class _PlainTeamModel extends GladeComposedModel<_MemberModel> {
  _PlainTeamModel([super.initialModels]);
}

/// Composed model with an own input which is opted out of `isUnchanged`.
class _UntrackedTeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput note;

  @override
  List<GladeInput<Object?>> get inputs => [note];

  @override
  void initialize() {
    note = GladeStringInput(value: '', inputKey: 'note', trackUnchanged: false);

    super.initialize();
  }
}

/// Composed model listing an input which belongs to one of its contained models.
class _ThievingTeamModel extends GladeComposedModel<_MemberModel> {
  final _MemberModel victim;

  @override
  List<GladeInput<Object?>> get inputs => [victim.firstName];

  _ThievingTeamModel(this.victim);
}

/// Composed model with two own inputs sharing the same key.
class _DuplicatedKeysTeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput a;
  late GladeStringInput b;

  @override
  List<GladeInput<Object?>> get inputs => [a, b];

  @override
  void initialize() {
    a = GladeStringInput(value: '', inputKey: 'same');
    b = GladeStringInput(value: '', inputKey: 'same');

    super.initialize();
  }
}

/// Contained model whose input declares a dependency on composed model's own input.
class _CrossLevelMemberModel extends GladeModel {
  final GladeInput<Object?> composedLevelInput;

  int dependencyCalls = 0;

  late GladeStringInput nickname;

  @override
  List<GladeInput<Object?>> get inputs => [nickname];

  _CrossLevelMemberModel(this.composedLevelInput);

  @override
  void initialize() {
    nickname = GladeStringInput(
      value: '',
      inputKey: 'nickname',
      dependencies: () => [composedLevelInput],
      onDependencyChange: (_) => dependencyCalls++,
    );

    super.initialize();
  }
}

/// Composed model used to verify that contained models do not observe composed-level inputs.
class _CrossLevelTeamModel extends GladeComposedModel<GladeModel> {
  late GladeStringInput teamName;

  @override
  List<GladeInput<Object?>> get inputs => [teamName];

  @override
  void initialize() {
    teamName = GladeStringInput(value: '', inputKey: 'teamName');

    super.initialize();
  }
}

/// Composed model whose own input updates a contained model from its dependency callback,
/// re-entering the composed model's notification while it is still being delivered.
class _ReentrantTeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput teamName;
  late GladeStringInput motto;

  @override
  List<GladeInput<Object?>> get inputs => [teamName, motto];

  _ReentrantTeamModel([super.initialModels]);

  @override
  void initialize() {
    teamName = GladeStringInput(value: '', inputKey: 'teamName');
    motto = GladeStringInput(
      value: '',
      inputKey: 'motto',
      dependencies: () => [teamName],
      onDependencyChange: (_) => models.firstOrNull?.firstName.value = teamName.value,
    );

    super.initialize();
  }
}

/// Composed model with a flattened `inputs` getter - the misuse `addModel` must reject.
class _FlattenedTeamModel extends GladeComposedModel<_MemberModel> {
  @override
  List<GladeInput<Object?>> get inputs => [for (final model in models) ...model.inputs];
}

/// Model which binds an input it does not list, so the input outlives the model.
class _ExternalInputModel extends GladeModel {
  final GladeStringInput external;

  @override
  List<GladeInput<Object?>> get inputs => const [];

  _ExternalInputModel(this.external);

  @override
  void initialize() {
    super.initialize();

    bindToModel(external);
  }
}

/// Contained model which can fail while being disposed.
class _ThrowingMemberModel extends GladeModel {
  final bool throwsOnDispose;

  late GladeStringInput firstName;

  @override
  List<GladeInput<Object?>> get inputs => [firstName];

  _ThrowingMemberModel({this.throwsOnDispose = true});

  @override
  void initialize() {
    firstName = GladeStringInput(value: '', inputKey: 'firstName');

    super.initialize();
  }

  @override
  void dispose() {
    super.dispose();

    if (throwsOnDispose) throw StateError('disposal failed');
  }
}

class _ThrowingChildTeamModel extends GladeComposedModel<_ThrowingMemberModel> {
  late GladeStringInput teamName;

  @override
  List<GladeInput<Object?>> get inputs => [teamName];

  _ThrowingChildTeamModel([super.initialModels]);

  @override
  void initialize() {
    teamName = GladeStringInput(value: '', inputKey: 'teamName');

    super.initialize();
  }
}

/// Records lastUpdatedInputKeys of every notification.
class _KeysObserver {
  final GladeModelBase model;
  final List<List<String>> observedKeys;

  const _KeysObserver(this.model, this.observedKeys);

  void onNotified() => observedKeys.add(model.lastUpdatedInputKeys);
}

class _Counter {
  int count = 0;

  void increment() => count++;
}

/// Records the whole form's state on every notification, so an intermediate state - part of the
/// form already reset, the rest still holding old values - can be detected.
class _FormStateObserver {
  final _TeamModel model;

  final List<String> snapshots = [];

  _FormStateObserver(this.model);

  void onNotified() => snapshots.add('${model.teamName.value}|${model.models.map((e) => e.firstName.value).join(',')}');
}

/// Records whether composed model's own input was already disposed on every notification received.
///
/// Reading `controller.text` would not do - a disposed TextEditingController keeps returning its
/// last value, so the observation has to be `isDisposed` itself.
class _OwnInputObserver {
  final _TeamModel model;

  final List<bool> ownInputDisposedStates = [];

  _OwnInputObserver(this.model);

  void onNotified() => ownInputDisposedStates.add(model.teamName.isDisposed);
}

VoidCallback _assertNotDisposed(ChangeNotifier notifier) =>
    () => ChangeNotifier.debugAssertNotDisposed(notifier);

void main() {
  setUp(GladeForms.initialize);

  group('Composed model without own inputs', () {
    test('Has no own inputs and aggregates only its contained models', () {
      // arrange
      final member = _MemberModel();

      // act
      final team = _PlainTeamModel([member]);

      // assert
      expect(team.inputs, isEmpty);
      expect(team.isNotValid, isTrue, reason: "member's firstName is empty");
      expect(team.isPure, isTrue);
      expect(team.isUnchanged, isTrue);
      expect(team.validatorResults, hasLength(1));
    });

    test('Becomes valid and dirty when its contained model is updated', () {
      // arrange
      final member = _MemberModel();
      final team = _PlainTeamModel([member]);

      // act
      member.firstName.value = 'John';

      // assert
      expect(team.isValid, isTrue);
      expect(team.isDirty, isTrue);
    });

    test('Reports no updated input keys', () {
      // arrange
      final member = _MemberModel();
      final team = _PlainTeamModel([member]);

      // act
      member.firstName.value = 'John';

      // assert
      expect(team.lastUpdatedInputKeys, isEmpty);
    });
  });

  group('Own inputs aggregation', () {
    test('Own inputs are aggregated when there is no contained model', () {
      // arrange
      const noMembers = <_MemberModel>[];

      // act
      final team = _TeamModel(noMembers);

      // assert
      expect(team.isNotValid, isTrue, reason: 'teamName is empty');
      expect(team.isPure, isTrue);
      expect(team.isUnchanged, isTrue);
      expect(team.validatorResults, hasLength(2));
    });

    test('Updating an own input makes composed model valid, dirty and changed', () {
      // arrange
      final team = _TeamModel();

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(team.isValid, isTrue);
      expect(team.isDirty, isTrue);
      expect(team.isUnchanged, isFalse);
    });

    test('Composed model stays invalid while its contained model is invalid', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(team.isNotValid, isTrue);
    });

    test('Own inputs and contained models are both folded into the model state', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      team.teamName.value = 'A-team';

      // act
      member.firstName.value = 'John';

      // assert
      expect(team.isValid, isTrue);
      expect(team.isValidWithoutWarnings, isTrue);
      expect(team.validatorResults, hasLength(3), reason: '2 own inputs + 1 member input');
    });

    test('Own input does not dirty the contained model', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(member.isPure, isTrue);
      expect(team.isPure, isFalse);
    });

    test('Own input with trackUnchanged false is excluded from isUnchanged', () {
      // arrange
      final team = _UntrackedTeamModel();

      // act
      team.note.value = 'anything';

      // assert
      expect(team.isUnchanged, isTrue);
      expect(team.isDirty, isTrue);
    });
  });

  group('lastUpdates', () {
    test('Own input update is reported in lastUpdatedInputKeys', () {
      // arrange
      final team = _TeamModel();

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(team.lastUpdatedInputKeys, equals(['teamName']));
    });

    test('Contained model update clears own lastUpdates', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      team.teamName.value = 'A-team';

      // act
      member.firstName.value = 'John';

      // assert
      expect(team.lastUpdatedInputKeys, isEmpty, reason: 'stale own keys must not be re-broadcast');
      expect(member.lastUpdatedInputKeys, equals(['firstName']));
    });

    test('Own keys survive a contained model changing during dependency propagation', () {
      // arrange
      final team = _ReentrantTeamModel([_MemberModel()]);
      final observedKeys = <List<String>>[];
      final observer = _KeysObserver(team, observedKeys);
      team.addListener(observer.onNotified);

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(team.models.firstOrNull?.firstName.value, equals('A-team'), reason: 'the callback did run');
      expect(observedKeys.lastOrNull, equals(['teamName']));
      expect(team.lastUpdatedInputKeys, equals(['teamName']));
    });

    test('addModel clears own lastUpdates', () {
      // arrange
      final team = _TeamModel();
      team.teamName.value = 'A-team';

      // act
      team.addModel(_MemberModel());

      // assert
      expect(team.lastUpdatedInputKeys, isEmpty);
    });

    test('removeModel clears own lastUpdates', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      team.teamName.value = 'A-team';

      // act
      team.removeModel(member);

      // assert
      expect(team.lastUpdatedInputKeys, isEmpty);
    });
  });

  group('groupEdit', () {
    test('When own input and contained model are updated together listener is called once', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      final counter = _Counter();
      team.addListener(counter.increment);

      // act
      team.groupEdit(() {
        team.teamName.value = 'A-team';
        member.firstName.value = 'John';
        team.motto.value = 'go go go';
      });

      // assert
      expect(counter.count, equals(1));
      expect(team.lastUpdatedInputKeys, containsAll(['teamName', 'motto']));
      expect(team.mottoDependencyCalls, equals(1), reason: 'motto depends on teamName updated in the batch');
      expect(team.mottoDependencyKeys, equals(['teamName']));
    });

    test('Nested groupEdit notifies once and keeps keys accumulated by the outer batch', () {
      // arrange
      final team = _TeamModel();
      final counter = _Counter();
      team.addListener(counter.increment);

      // act
      team.groupEdit(() {
        team.teamName.value = 'A-team';
        team.groupEdit(() => team.motto.value = 'go go go');
      });

      // assert
      expect(counter.count, equals(1), reason: 'a nested batch must not flush on its own');
      expect(team.lastUpdatedInputKeys, containsAll(['teamName', 'motto']));
    });

    test('A throwing batch still notifies about the updates which already happened', () {
      // arrange
      final team = _TeamModel();
      final counter = _Counter();
      team.addListener(counter.increment);

      // act
      void act() => team.groupEdit(() {
        team.teamName.value = 'A-team';

        throw StateError('boom');
      });

      // assert
      expect(act, throwsA(isA<StateError>()));
      expect(counter.count, equals(1));
      expect(team.lastUpdatedInputKeys, equals(['teamName']));
    });

    test('Keys of an update preceding groupEdit are not re-broadcast', () {
      // arrange
      final team = _TeamModel();
      team.teamName.value = 'A-team';

      // act
      team.groupEdit(() => team.motto.value = 'go go go');

      // assert
      expect(team.lastUpdatedInputKeys, equals(['motto']));
      expect(team.mottoDependencyCalls, equals(1), reason: 'teamName did not change within the batch');
    });
  });

  group('Dependencies', () {
    test('Own inputs notify their dependencies within composed level', () {
      // arrange
      final team = _TeamModel();

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(team.mottoDependencyCalls, equals(1));
      expect(team.mottoDependencyKeys, equals(['teamName']));
    });

    test("Contained model's input does not observe composed model's own input", () {
      // arrange
      final team = _CrossLevelTeamModel();
      final member = _CrossLevelMemberModel(team.teamName);
      team.addModel(member);

      // act
      team.teamName.value = 'A-team';

      // assert
      expect(member.dependencyCalls, isZero, reason: 'cross-level dependencies are not supported');
    });
  });

  group('Input ownership', () {
    test('Composed model listing an input of its contained model asserts', () {
      // arrange
      final member = _MemberModel();

      // act
      void act() => _ThievingTeamModel(member);

      // assert
      expect(act, throwsA(isA<AssertionError>()));
    });

    test('Binding a foreign input to composed model asserts', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);

      // act
      void act() => team.bindToModel(member.firstName);

      // assert
      expect(act, throwsA(isA<AssertionError>()));
    });

    test('Updating a foreign input through composed model asserts', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);

      // act
      void act() => team.updateInput(member.firstName, 'John');

      // assert
      expect(act, throwsA(isA<AssertionError>()));
    });

    test('A rejected model is not left attached to the composed model', () {
      // arrange
      final team = _FlattenedTeamModel();
      final member = _MemberModel();
      final counter = _Counter();
      team.addListener(counter.increment);

      // act
      void act() => team.addModel(member);

      // assert
      expect(act, throwsA(isA<AssertionError>()));
      expect(team.models, isEmpty, reason: 'the attach must be rolled back');

      member.firstName.value = 'John';
      expect(counter.count, isZero, reason: 'the rejected model must not drive the composed model');
    });

    test('A disposed input can not be binded to another model', () {
      // arrange
      final member = _MemberModel();
      final input = member.firstName;
      member.dispose();

      // act
      void act() => _TeamModel().bindToModel(input);

      // assert
      expect(input.isDisposed, isTrue);
      expect(act, throwsA(isA<AssertionError>()));
    });

    test('An input which outlived its disposed model can be binded again', () {
      // arrange
      final external = GladeStringInput(value: '', inputKey: 'external');
      final first = _ExternalInputModel(external);
      first.dispose();

      // act
      void act() => _ExternalInputModel(external);

      // assert
      expect(external.isDisposed, isFalse, reason: 'the model does not own what it does not list');
      expect(first.isDisposed, isTrue);
      expect(act, returnsNormally);
    });

    test('Duplicated own input keys assert', () {
      // arrange
      _DuplicatedKeysTeamModel? model;

      // act
      void act() => model = _DuplicatedKeysTeamModel();

      // assert
      expect(act, throwsA(isA<AssertionError>()));
      expect(model, isNull);
    });
  });

  group('Reset', () {
    test('resetToInitialValue resets own inputs and all contained models', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      team.teamName.value = 'A-team';
      member.firstName.value = 'John';

      // act
      team.resetToInitialValue();

      // assert
      expect(team.teamName.value, isEmpty);
      expect(member.firstName.value, isEmpty);
      expect(team.isUnchanged, isTrue);
      expect(team.isPure, isTrue);
    });

    test('resetToInitialValue notifies once and never exposes a half reset form', () {
      // arrange
      final members = [_MemberModel(), _MemberModel(), _MemberModel()];
      final team = _TeamModel(members);
      team.teamName.value = 'A-team';
      for (final member in members) {
        member.firstName.value = 'John';
      }

      final observer = _FormStateObserver(team);
      team.addListener(observer.onNotified);

      // act
      team.resetToInitialValue();

      // assert
      expect(observer.snapshots, equals(['|,,']), reason: 'one notification, everything already reset');
    });

    test('setInputValuesAsNewInitialValues notifies once', () {
      // arrange
      final members = [_MemberModel(), _MemberModel()];
      final team = _TeamModel(members);
      team.teamName.value = 'A-team';
      for (final member in members) {
        member.firstName.value = 'John';
      }

      final counter = _Counter();
      team.addListener(counter.increment);

      // act
      team.setInputValuesAsNewInitialValues();

      // assert
      expect(counter.count, equals(1));
      expect(team.isUnchanged, isTrue);
    });

    test('setInputValuesAsNewInitialValues applies to own inputs and all contained models', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      team.teamName.value = 'A-team';
      member.firstName.value = 'John';

      // act
      team.setInputValuesAsNewInitialValues();

      // assert
      expect(team.teamName.initialValue, equals('A-team'));
      expect(member.firstName.initialValue, equals('John'));
      expect(team.isUnchanged, isTrue);
    });
  });

  group('Dispose', () {
    test('Disposes own inputs and contained models', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      final ownController = team.teamName.controller!;

      // act
      team.dispose();

      // assert
      expect(team.teamName.isDisposed, isTrue);
      expect(member.firstName.isDisposed, isTrue);
      expect(_assertNotDisposed(ownController), throwsA(isA<FlutterError>()));
    });

    test('Own inputs are not disposed yet when listeners are notified during dispose', () {
      // arrange
      final member = _MemberModel();
      final team = _TeamModel([member]);
      team.teamName.value = 'A-team';

      final observer = _OwnInputObserver(team);
      team.addListener(observer.onNotified);

      // act
      team.dispose();

      // assert
      expect(observer.ownInputDisposedStates, isNotEmpty, reason: 'dispose must notify at least once');
      expect(observer.ownInputDisposedStates, everyElement(isFalse));
      expect(team.teamName.isDisposed, isTrue);
    });

    test('A contained model throwing while disposing does not stop the others', () {
      // arrange
      final healthy = _ThrowingMemberModel(throwsOnDispose: false);
      final team = _ThrowingChildTeamModel([_ThrowingMemberModel(), healthy]);

      // act
      void act() => team.dispose();

      // assert
      expect(act, throwsA(isA<StateError>()), reason: 'the failure is rethrown once teardown finished');
      expect(healthy.firstName.isDisposed, isTrue, reason: 'disposal must not stop at the failing model');
      expect(team.models, isEmpty);
      expect(team.teamName.isDisposed, isTrue);
    });

    test('Own inputs are disposed even when a contained model throws while disposing', () {
      // arrange
      final team = _ThrowingChildTeamModel([_ThrowingMemberModel()]);

      // act
      void act() => team.dispose();

      // assert
      expect(act, throwsA(isA<StateError>()));
      expect(team.teamName.isDisposed, isTrue, reason: 'own inputs must not leak their controllers');
    });
  });
}
