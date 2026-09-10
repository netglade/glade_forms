import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _MemberModel extends GladeModel {
  late GladeStringInput firstName;

  @override
  List<GladeInput<Object?>> get inputs => [firstName];

  @override
  void initialize() {
    firstName = GladeStringInput(value: '', inputKey: 'firstName');

    super.initialize();
  }
}

/// Model with an input whose value is not a JSON primitive.
class _DateModel extends GladeModel {
  late GladeDateTimeInput startsAt;

  @override
  List<GladeInput<Object?>> get inputs => [startsAt];

  @override
  void initialize() {
    startsAt = GladeDateTimeInput(initialValue: DateTime(2026, 9, 10), inputKey: 'startsAt');

    super.initialize();
  }
}

class _TeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput teamName;

  @override
  List<GladeInput<Object?>> get inputs => [teamName];

  _TeamModel([super.initialModels]);

  @override
  void initialize() {
    teamName = GladeStringInput(value: 'A-team', inputKey: 'teamName');

    super.initialize();
  }
}

class _PlainTeamModel extends GladeComposedModel<_MemberModel> {
  _PlainTeamModel([super.initialModels]);
}

void main() {
  setUp(GladeForms.initialize);

  test('Composed model serializes its own inputs', () {
    // arrange
    final team = _TeamModel([_MemberModel()]);

    // act
    final json = team.toDevToolsJson();

    // assert
    expect(json['inputs'], hasLength(1));
    expect((json['inputs'] as List<Object?>).firstOrNull, containsPair('key', 'teamName'));
  });

  test('Composed model without own inputs serializes an empty input list', () {
    // arrange
    final team = _PlainTeamModel([_MemberModel()]);

    // act
    final json = team.toDevToolsJson();

    // assert
    expect(json['inputs'], isEmpty);
  });

  test('Serialized model is JSON encodable even for a non-primitive input value', () {
    // arrange
    final model = _DateModel();

    // act
    String encode() => json.encode({
      'models': [model.toDevToolsJson()],
    });

    // assert
    expect(encode, returnsNormally);
  });

  test('Input dependencies are serialized under the dependencies key', () {
    // arrange
    final team = _TeamModel();

    // act
    final json = team.toDevToolsJson();
    final input = (json['inputs'] as List<Object?>).firstOrNull as Map<String, dynamic>?;

    // assert
    expect(input?.keys, contains('dependencies'));
  });
}
