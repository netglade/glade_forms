// ignore_for_file: avoid-duplicate-test-assertions, prefer-correct-callback-field-name, avoid-global-state

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _ModeWithDependencies extends GladeModel {
  late GladeInput<int> a;
  late GladeInput<int> b;
  late GladeInput<int> c;

  int aUpdated = 0;
  int bUpdated = 0;
  int cUpdated = 0;

  int onDepenencyCalledCount = 0;

  List<String> updatedDependencyKeys = [];

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

        onDepenencyCalledCount++;

        updatedDependencyKeys = keys;
      },
    );

    super.initialize();
  }
}

void main() {
  setUp(GladeForms.initialize);

  test('When updating [a] onDependencyChange is called for a', () {
    // arrange
    final model = _ModeWithDependencies();

    // act
    model.a.value = 5;

    // assert
    expect(model.a.value, equals(5));
    expect(model.onDepenencyCalledCount, equals(1));
    expect(model.lastUpdatedInputKeys, equals(['a']));
    expect(model.updatedDependencyKeys, equals(['a']));
  });

  test('When updating [b] onDependencyChange is called for b', () {
    // arrange
    final model = _ModeWithDependencies();

    // act
    model.b.value = 5;

    // assert
    expect(model.b.value, equals(5));
    expect(model.onDepenencyCalledCount, equals(1));
    expect(model.lastUpdatedInputKeys, equals(['b']));
    expect(model.updatedDependencyKeys, equals(['b']));
  });

  test('When updating [a, b] together onDependencyChange is called for [a,b]', () {
    // arrange
    final model = _ModeWithDependencies();

    // act
    model.groupEdit(() {
      model.b.value = 5;
      model.a.value = 5;
    });

    // assert
    expect(model.a.value, equals(5));
    expect(model.b.value, equals(5));
    expect(model.onDepenencyCalledCount, equals(1));
    expect(model.lastUpdatedInputKeys.toSet().difference({'a', 'b'}), equals(<String>{}));
    expect(model.updatedDependencyKeys.toSet().difference({'a', 'b'}), equals(<String>{}));
  });

  test('When updating [c] onDependencyChange is not called', () {
    // arrange
    final model = _ModeWithDependencies();

    // act
    model.c.value = 5;

    // assert
    expect(model.c.value, equals(5));
    expect(model.lastUpdatedInputKeys.toSet().difference({'c'}), equals(<String>{}));
    expect(model.onDepenencyCalledCount, isZero);
    expect(model.updatedDependencyKeys.toSet().difference({}), equals(<String>{}));
  });
}
