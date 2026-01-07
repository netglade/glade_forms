import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms_devtools_extension/src/models/form_model_data.dart';

void main() {
  group('FormModelData', () {
    test('can be serialized to and from JSON', () {
      final model = FormModelData(
        id: 'test_model_1',
        type: 'TestModel',
        isValid: true,
        isPure: false,
        isDirty: true,
        isUnchanged: false,
        inputs: [
          FormInputData(
            key: 'email',
            type: 'GladeStringInput',
            value: 'test@example.com',
            initialValue: '',
            isValid: true,
            isPure: false,
            isUnchanged: false,
            hasConversionError: false,
            errors: [],
            warnings: [],
          ),
        ],
        formattedErrors: '',
      );

      final json = model.toJson();
      final deserialized = FormModelData.fromJson(json);

      expect(deserialized.id, model.id);
      expect(deserialized.type, model.type);
      expect(deserialized.isValid, model.isValid);
      expect(deserialized.isPure, model.isPure);
      expect(deserialized.isDirty, model.isDirty);
      expect(deserialized.isUnchanged, model.isUnchanged);
      expect(deserialized.inputs.length, model.inputs.length);
      expect(deserialized.formattedErrors, model.formattedErrors);
    });
  });

  group('FormInputData', () {
    test('can be serialized to and from JSON', () {
      final input = FormInputData(
        key: 'email',
        type: 'GladeStringInput',
        value: 'test@example.com',
        initialValue: '',
        isValid: true,
        isPure: false,
        isUnchanged: false,
        hasConversionError: false,
        errors: ['Email is required'],
        warnings: ['Email format could be better'],
      );

      final json = input.toJson();
      final deserialized = FormInputData.fromJson(json);

      expect(deserialized.key, input.key);
      expect(deserialized.type, input.type);
      expect(deserialized.value, input.value);
      expect(deserialized.initialValue, input.initialValue);
      expect(deserialized.isValid, input.isValid);
      expect(deserialized.isPure, input.isPure);
      expect(deserialized.isUnchanged, input.isUnchanged);
      expect(deserialized.hasConversionError, input.hasConversionError);
      expect(deserialized.errors, input.errors);
      expect(deserialized.warnings, input.warnings);
    });

    test('handles null initialValue', () {
      final input = FormInputData(
        key: 'email',
        type: 'GladeStringInput',
        value: 'test@example.com',
        initialValue: null,
        isValid: true,
        isPure: false,
        isUnchanged: false,
        hasConversionError: false,
        errors: [],
        warnings: [],
      );

      final json = input.toJson();
      final deserialized = FormInputData.fromJson(json);

      expect(deserialized.initialValue, null);
    });
  });
}
