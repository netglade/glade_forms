import 'package:collection/collection.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Model extends GladeModel {
  late GladeStringInput name;

  @override
  List<GladeInput<Object?>> get inputs => [name];

  @override
  void initialize() {
    name = GladeStringInput(
      inputKey: 'name',
      value: 'a',
      useTextEditingController: false,
      validator: (v) => (v..satisfyAsync((value) async => true)).build(),
    );

    super.initialize();
  }
}

void main() {
  setUp(GladeForms.initialize);

  test('serialization contains async fields', () {
    // arrange
    final model = _Model();

    // act
    final json = model.toDevToolsJson();
    final inputs = json['inputs'] as List<Map<String, dynamic>>;
    final inputJson = inputs.singleOrNull!;

    // assert
    expect(json['isValidating'], isFalse);
    expect(inputJson['isValidating'], isFalse);
    expect(inputJson['hasAsyncValidation'], isTrue);
    expect(inputJson['asyncState'], equals('notRun'));
  });
}
