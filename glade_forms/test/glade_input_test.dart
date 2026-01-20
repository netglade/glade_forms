// ignore_for_file: cascade_invocations

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  setUp(GladeForms.initialize);

  test('GladeInput with non-nullable type', () {
    // arrange
    final input = GladeInput<int>.create(
      validator: (v) => v.build(),
      value: 0,
      inputKey: 'a',
    );

    // act

    // assert
    expect(input.isValid, isTrue);
  });

  group('onChange tests', () {
    test('Setter always trigger change', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.value = 100;

      // assert
      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue by default trigger change', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.updateValue(100);

      // assert
      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue disables trigger onChange', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.updateValue(100, shouldTriggerOnChange: false);

      // assert
      // ignore: avoid-duplicate-test-assertions, it controlls that onChange wasnt called.
      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(100));
    });
  });

  group('onChange with Controller tests', () {
    test('Controller always trigger change', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.controller?.text = '100';

      // assert
      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('Setter always trigger change', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.value = 100;

      // assert
      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue by default trigger change', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.updateValue(100);

      // assert
      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue disables trigger onChange', () {
      // arrange
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      // act
      input.updateValue(100, shouldTriggerOnChange: false);

      // assert
      // ignore: avoid-duplicate-test-assertions, it controlls that onChange wasnt called.
      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(100));
    });
  });

  group('input with controller triggers onChange correctly', () {
    test('when controller text changes then onChange is called', () {
      // arrange
      final changes = <String>[];
      final input = GladeInput<String>.create(
        value: 'a',
        useTextEditingController: true,
        onChange: (info) => changes.add(info.value),
      );

      // act
      input.controller?.text = 'b';

      // assert
      expect(input.value, equals('b'));
      expect(changes, equals(['b']));
    });

    test('when updateValue is called then onChange is called', () {
      // arrange
      final changes = <String>[];
      final input = GladeInput<String>.create(
        value: 'a',
        useTextEditingController: true,
        onChange: (info) => changes.add(info.value),
      );

      // act
      input.updateValue('b');

      // assert
      expect(input.value, equals('b'));
      expect(changes, equals(['b']));
    });

    test(
      'when updateValue is called with shouldTriggerOnChange: false then onChange is not called',
      () {
        // arrange
        final changes = <String>[];
        final input = GladeInput<String>.create(
          value: 'a',
          useTextEditingController: true,
          onChange: (info) => changes.add(info.value),
        );

        // act
        input.updateValue('b', shouldTriggerOnChange: false);

        // assert
        expect(input.value, equals('b'));
        expect(changes, equals([]));
      },
    );

    test(
      'when updateValue is called with shouldTriggerOnChange: false and second updateValue is called without it then only the second call triggers onChange',
      () {
        // arrange
        final changes = <String>[];
        final input = GladeInput<String>.create(
          value: 'a',
          useTextEditingController: true,
          onChange: (info) => changes.add(info.value),
        );

        // act

        // Won't trigger onChange.
        input.updateValue('b', shouldTriggerOnChange: false);
        // Should trigger onChange.
        input.updateValue('c');

        // assert
        expect(input.value, equals('c'));
        expect(changes, equals(['c']));
      },
    );
  });

  group('Pure test', () {
    test('ResetToPure', () {
      // arrange
      final input = GladeIntInput(
        value: 100,
        initialValue: 10,
        useTextEditingController: true,
      );

      expect(input.value, equals(100));
      expect(input.initialValue, equals(10));

      // act
      input.updateValue(0, shouldTriggerOnChange: true);

      expect(input.value, equals(0));

      input.resetToInitialValue();

      // assert
      expect(input.isPure, isTrue);
      expect(input.value, equals(input.initialValue));
    });

    test('SetAsNewPure', () {
      // arrange
      final input = GladeIntInput(
        initialValue: 20,
        value: 100,
        useTextEditingController: true,
      );

      // Initial state
      expect(input.value, equals(100));
      expect(input.initialValue, equals(20));
      expect(input.isPure, isTrue);

      // act
      // Set as new pure with a new value
      input.setNewInitialValue(
        initialValue: () => 10,
        shouldResetToInitialValue: false,
      );

      // assert
      // Check the new state
      // ignore: avoid-duplicate-test-assertions, check again
      expect(input.value, equals(100));
      expect(input.initialValue, equals(10));
      // ignore: avoid-duplicate-test-assertions, the state changed, its not the same as before, its after setAsNewPure, to test if the new value is set.
      expect(input.isPure, isTrue);
    });
  });

  group('TransformValue', () {
    test('No transformValue sets updated value', () {
      // arrange
      final input = GladeInput.create(value: 0);

      // act
      input.updateValue(5);

      // assert
      expect(input.value, equals(5));
    });

    test('No transformValue in nullable type sets updated value to null', () {
      // arrange
      final input = GladeInput<int?>.create(value: 2);

      // act
      input.updateValue(null);

      // assert
      expect(input.value, isNull);
    });

    test('With non-nullable type returns transformed value', () {
      // arrange
      final input = GladeInput<int>.create(
        value: 0,
        valueTransform: (value) => value * 2,
      );

      // act
      input.updateValue(5);

      // assert
      expect(input.value, equals(10));
    });

    test('With nullable type and passed null return null', () {
      // arrange
      final input = GladeInput<int?>.create(
        value: 2,
        valueTransform: (value) => value == 4 ? null : 20,
      );

      // act
      input.updateValue(4);

      // assert
      expect(input.value, equals(null));
    });

    test('With nullable type and passed value returns transformed value', () {
      // arrange
      final input = GladeInput<int?>.create(
        value: 2,
        valueTransform: (value) => value == 4 ? null : 20,
      );

      // act
      input.updateValue(10);

      // assert
      expect(input.value, equals(20));
    });
  });
}
