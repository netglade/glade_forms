// ignore_for_file: avoid-duplicate-test-assertions, prefer-correct-callback-field-name

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Model extends GladeModel {
  late GladeInput<int> a;
  late GladeInput<int> b;

  @override
  List<GladeInput<Object?>> get inputs => [a, b];

  @override
  void initialize() {
    a = GladeIntInput(value: 0, inputKey: 'a');
    b = GladeIntInput(value: 1, inputKey: 'b');

    super.initialize();
  }
}

class _ModeWithDependencies extends GladeModel {
  late GladeInput<int> a;
  late GladeInput<int> b;
  late GladeInput<int> c;

  int aUpdated = 0;
  int bUpdated = 0;
  int cUpdated = 0;

  int onDepenencyCalledCount = 0;

  @override
  List<GladeInput<Object?>> get inputs => [a, b, c];

  @override
  void initialize() {
    a = GladeIntInput(value: 0, inputKey: 'a');
    b = GladeIntInput(value: 1, inputKey: 'b');
    c = GladeIntInput(
      value: 1,
      inputKey: 'c',
      dependencies: () => [a, b],
      onDependencyChange: (keys) {
        if (keys.contains('a')) aUpdated++;
        if (keys.contains('b')) bUpdated++;
        if (keys.contains('c')) cUpdated++;

        onDepenencyCalledCount++;
      },
    );

    super.initialize();
  }
}

void main() {
  setUp(GladeForms.initialize);

  test('When updating [a] listener is called', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    model.a.value = 5;
    expect(model.a.value, equals(5));
    expect(model.lastUpdatedInputKeys, equals(['a']));
    expect(listenerCount, equals(1), reason: 'Should be called');
  });

  test('When updating [b] listeners is called', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    model.b.value = 5;
    expect(model.b.value, equals(5));
    expect(model.lastUpdatedInputKeys, equals(['b']));
    expect(listenerCount, equals(1), reason: 'Should be called');
  });

  test('When updating [a] and [b] listeners are called two times', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    model.a.value = 3;

    expect(model.a.value, equals(3));
    expect(model.lastUpdatedInputKeys, equals(['a']));

    model.b.value = 5;

    expect(model.b.value, equals(5));
    expect(model.lastUpdatedInputKeys, equals(['b']));
    expect(listenerCount, equals(2), reason: 'Should be called');
  });

  test('When updating [a] and [b] at once listener is called once', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    // ignore: cascade_invocations, under test ok.
    model.groupEdit(() {
      model.a.value = 3;
      model.b.value = 5;
    });

    expect(model.a.value, equals(3));
    expect(model.b.value, equals(5));

    expect(model.lastUpdatedInputKeys, equals(['a', 'b']));
    expect(listenerCount, equals(1), reason: 'Should be called');
  });

  group('notify dependencies after edit', () {
    test('When updating only [a] then [c] is notified', () {
      final model = _ModeWithDependencies();

      expect(model.aUpdated, equals(0));
      expect(model.bUpdated, equals(0));
      expect(model.cUpdated, equals(0));
      expect(model.onDepenencyCalledCount, equals(0));

      model.a.value = 1;

      expect(model.aUpdated, equals(1));
      expect(model.bUpdated, equals(0));
      expect(model.cUpdated, equals(0));
      expect(model.onDepenencyCalledCount, equals(1));
    });

    test('When updating only [b] then [c] is notified', () {
      final model = _ModeWithDependencies();

      expect(model.aUpdated, equals(0));
      expect(model.bUpdated, equals(0));
      expect(model.cUpdated, equals(0));

      model.b.value = 1;

      expect(model.aUpdated, equals(0));
      expect(model.bUpdated, equals(1));
      expect(model.cUpdated, equals(0));
      expect(model.onDepenencyCalledCount, equals(1));
    });

    test('When updating [a] and [b] individually then [c] is notified twice', () {
      final model = _ModeWithDependencies();

      expect(model.aUpdated, equals(0));
      expect(model.bUpdated, equals(0));
      expect(model.cUpdated, equals(0));
      expect(model.onDepenencyCalledCount, equals(0));

      model.a.value = 1;
      model.b.value = 1;

      expect(model.aUpdated, equals(1), reason: '[a] only once updated');
      expect(model.bUpdated, equals(1), reason: '[b] only once updated');
      expect(model.cUpdated, equals(0), reason: '[c] never updated');
      expect(model.onDepenencyCalledCount, equals(2), reason: 'Individual updates');
    });

    test('When updating [a] and [b] via groupEdit then [c] is notified once', () {
      final model = _ModeWithDependencies();

      expect(model.aUpdated, equals(0));
      expect(model.bUpdated, equals(0));
      expect(model.cUpdated, equals(0));
      expect(model.onDepenencyCalledCount, equals(0));

      model.groupEdit(() {
        model.a.value = 1;
        model.b.value = 1;
      });

      expect(model.aUpdated, equals(1), reason: '[a] only once updated');
      expect(model.bUpdated, equals(1), reason: '[b] only once updated');
      expect(model.cUpdated, equals(0), reason: '[c] never updated');
      expect(model.onDepenencyCalledCount, equals(1), reason: 'groupEdit update');
    });
  });
}
