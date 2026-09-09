// ignore_for_file: cascade_invocations

import 'package:flutter/widgets.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Model extends GladeModel {
  late GladeStringInput name;
  late GladeIntInput age;

  @override
  List<GladeInput<Object?>> get inputs => [name, age];

  @override
  void initialize() {
    name = GladeStringInput(value: 'John', inputKey: 'name');
    age = GladeIntInput(value: 20, inputKey: 'age');

    super.initialize();
  }
}

VoidCallback _assertNotDisposed(ChangeNotifier notifier) => () => ChangeNotifier.debugAssertNotDisposed(notifier);

void main() {
  setUp(GladeForms.initialize);

  test('Input disposes controller which it created', () {
    // arrange
    final input = GladeStringInput(value: 'A');
    final controller = input.controller!;

    expect(_assertNotDisposed(controller), returnsNormally);

    // act
    input.dispose();

    // assert
    expect(input.isDisposed, isTrue);
    expect(_assertNotDisposed(controller), throwsA(isA<FlutterError>()));
  });

  test('Input does not dispose externally provided controller', () {
    // arrange
    final controller = TextEditingController(text: 'A');
    final input = GladeStringInput(value: 'A', textEditingController: controller);

    // act
    input.dispose();
    controller.text = 'B';

    // assert
    expect(_assertNotDisposed(controller), returnsNormally);
    expect(input.value, equals('A'), reason: 'Listener must be removed on dispose');

    controller.dispose();
  });

  test('Repeated dispose is no-op', () {
    // arrange
    final input = GladeStringInput(value: 'A');

    // act
    input.dispose();

    // assert
    expect(input.dispose, returnsNormally);
    expect(input.isDisposed, isTrue);
  });

  test('Model dispose disposes its inputs', () {
    // arrange
    final model = _Model();
    final controller = model.name.controller!;

    // act
    model.dispose();

    // assert
    expect(model.name.isDisposed, isTrue);
    expect(model.age.isDisposed, isTrue);
    expect(_assertNotDisposed(controller), throwsA(isA<FlutterError>()));
  });
}
