import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  test('GladeInput with non-nullable type', () {
    final input = GladeInput<int>.create(validator: (v) => v.build(), value: 0, inputKey: 'a');

    expect(input.isValid, isTrue);
  });

  group('onChange tests', () {
    test('Setter always trigger change', () {
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        onChange: (info, _) {
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
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        onChange: (info, _) {
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
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        onChange: (info, _) {
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
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info, _) {
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
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info, _) {
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
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info, _) {
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
      final dependentInput = GladeInput.intInput(value: -1);
      final input = GladeInput.intInput(
        value: 0,
        useTextEditingController: true,
        onChange: (info, _) {
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
}
