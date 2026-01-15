// ignore_for_file: cascade_invocations

import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  setUp(GladeForms.initialize);

  test('GladeInput with non-nullable type', () {
    final input = GladeInput<int>.create(
      validator: (v) => v.build(),
      value: 0,
      inputKey: 'a',
    );

    expect(input.isValid, isTrue);
  });

  group('onChange tests', () {
    test('Setter always trigger change', () {
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      input.value = 100;

      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue by default trigger change', () {
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      input.updateValue(100);

      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue disables trigger onChange', () {
      final dependentInput = GladeIntInput(value: -1);
      final input = GladeIntInput(
        value: 0,
        onChange: (info) {
          dependentInput.value = info.value;
        },
      );

      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(0));

      input.updateValue(100, shouldTriggerOnChange: false);

      // ignore: avoid-duplicate-test-assertions, it controlls that onChange wasnt called.
      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(100));
    });
  });

  group('onChange with Controller tests', () {
    test('Controller always trigger change', () {
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

      input.controller?.text = '100';

      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('Setter always trigger change', () {
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

      input.value = 100;

      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue by default trigger change', () {
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

      input.updateValue(100);

      expect(dependentInput.value, equals(100));
      expect(input.value, equals(100));
    });

    test('updateValue disables trigger onChange', () {
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

      input.updateValue(100, shouldTriggerOnChange: false);

      // ignore: avoid-duplicate-test-assertions, it controlls that onChange wasnt called.
      expect(dependentInput.value, equals(-1));
      expect(input.value, equals(100));
    });
  });

  group('input with controller triggers onChange correctly', () {
    test('when controller text changes then onChange is called', () {
      // Arrange
      final changes = <String>[];
      final input = GladeInput<String>.create(
        value: 'a',
        useTextEditingController: true,
        onChange: (info) => changes.add(info.value),
      );

      // Act
      input.controller?.text = 'b';

      // Assert
      expect(input.value, equals('b'));
      expect(changes, equals(['b']));
    });

    test('when updateValue is called then onChange is called', () {
      // Arrange
      final changes = <String>[];
      final input = GladeInput<String>.create(
        value: 'a',
        useTextEditingController: true,
        onChange: (info) => changes.add(info.value),
      );

      // Act
      input.updateValue('b');

      // Assert
      expect(input.value, equals('b'));
      expect(changes, equals(['b']));
    });

    test(
      'when updateValue is called with shouldTriggerOnChange: false then onChange is not called',
      () {
        // Arrange
        final changes = <String>[];
        final input = GladeInput<String>.create(
          value: 'a',
          useTextEditingController: true,
          onChange: (info) => changes.add(info.value),
        );

        // Act
        input.updateValue('b', shouldTriggerOnChange: false);

        // Assert
        expect(input.value, equals('b'));
        expect(changes, equals([]));
      },
    );

    test(
      'when updateValue is called with shouldTriggerOnChange: false and second updateValue is called without it then only the second call triggers onChange',
      () {
        // Arrange
        final changes = <String>[];
        final input = GladeInput<String>.create(
          value: 'a',
          useTextEditingController: true,
          onChange: (info) => changes.add(info.value),
        );

        // Act
        // Won't trigger onChange.
        input.updateValue('b', shouldTriggerOnChange: false);
        // Should trigger onChange.
        input.updateValue('c');

        // Assert
        expect(input.value, equals('c'));
        expect(changes, equals(['c']));
      },
    );
  });

  group('Pure test', () {
    test('ResetToPure', () {
      final input = GladeIntInput(
        value: 100,
        initialValue: 10,
        useTextEditingController: true,
      );

      expect(input.value, equals(100));
      expect(input.initialValue, equals(10));

      input.updateValue(0, shouldTriggerOnChange: true);

      expect(input.value, equals(0));

      input.resetToInitialValue();

      expect(input.isPure, isTrue);
      expect(input.value, equals(input.initialValue));
    });

    test('SetAsNewPure', () {
      final input = GladeIntInput(
        initialValue: 20,
        value: 100,
        useTextEditingController: true,
      );

      // Initial state
      expect(input.value, equals(100));
      expect(input.initialValue, equals(20));
      expect(input.isPure, isTrue);

      // Set as new pure with a new value
      input.setNewInitialValue(
        initialValue: () => 10,
        shouldResetToInitialValue: false,
      );

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
      final input = GladeInput<int>.create(value: 0);

      // Act
      input.updateValue(5);

      expect(input.value, equals(5));
    });

    test('No transformValue in nullable type sets updated value to null', () {
      final input = GladeInput<int?>.create(value: 2);

      // Act
      input.updateValue(null);

      expect(input.value, isNull);
    });

    test('With non-nullable type returns transformed value', () {
      final input = GladeInput<int>.create(
        value: 0,
        valueTransform: (value) => value * 2,
      );

      // Act
      input.updateValue(5);

      expect(input.value, equals(10));
    });

    test('With nullable type and passed null return null', () {
      final input = GladeInput<int?>.create(
        value: 2,
        valueTransform: (value) => value == 4 ? null : 20,
      );

      // Act
      input.updateValue(4);

      expect(input.value, equals(null));
    });

    test('With nullable type and passed value returns transformed value', () {
      final input = GladeInput<int?>.create(
        value: 2,
        valueTransform: (value) => value == 4 ? null : 20,
      );

      // Act
      input.updateValue(10);

      expect(input.value, equals(20));
    });
  });
}
