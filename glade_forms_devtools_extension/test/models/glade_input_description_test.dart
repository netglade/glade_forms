import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';

/// Shape produced by `GladeInput.toDevToolsJson()` in package:glade_forms.
Map<String, dynamic> _producedInputJson({
  List<String> errors = const [],
  List<String> warnings = const [],
  List<String> dependencies = const [],
}) => {
  'dependencies': dependencies,
  'errors': errors,
  'hasConversionError': false,
  'initialValue': '',
  'isPure': true,
  'isUnchanged': true,
  'isValid': true,
  'key': 'teamName',
  'strValue': 'A-team',
  'type': 'GladeStringInput<String>',
  'value': 'A-team',
  'warnings': warnings,
};

/// The extension receives the payload over the VM service, so it always parses decoded JSON,
/// where every list is a `List<dynamic>`.
Map<String, dynamic> _asReceived(Map<String, dynamic> produced) =>
    json.decode(json.encode(produced)) as Map<String, dynamic>;

void main() {
  group('GladeInputDescription.fromJson', () {
    test('Parses an input without errors, warnings and dependencies', () {
      // arrange
      final received = _asReceived(_producedInputJson());

      // act
      final description = GladeInputDescription.fromJson(received);

      // assert
      expect(description.key, equals('teamName'));
      expect(description.errors, isEmpty);
      expect(description.warnings, isEmpty);
      expect(description.dependencies, isEmpty);
    });

    test('Parses errors, warnings and dependencies of a decoded payload', () {
      // arrange
      final received = _asReceived(
        _producedInputJson(
          errors: ['Value cannot be empty'],
          warnings: ['Looks suspicious'],
          dependencies: ['motto'],
        ),
      );

      // act
      final description = GladeInputDescription.fromJson(received);

      // assert
      expect(description.errors, equals(['Value cannot be empty']));
      expect(description.warnings, equals(['Looks suspicious']));
      expect(description.dependencies, equals(['motto']));
    });

    test('Falls back to an empty list when a list is missing', () {
      // arrange
      final received = _asReceived(_producedInputJson())
        ..remove('dependencies')
        ..remove('errors')
        ..remove('warnings');

      // act
      final description = GladeInputDescription.fromJson(received);

      // assert
      expect(description.errors, isEmpty);
      expect(description.warnings, isEmpty);
      expect(description.dependencies, isEmpty);
    });
  });
}
