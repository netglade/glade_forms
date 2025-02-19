import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  test('GladeInput with non-nullable type', () {
    final input = GladeInput<int>.create(validator: (v) => v.build(), value: 0, inputKey: 'a');

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
}
