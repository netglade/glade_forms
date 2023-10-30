import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

class _Model extends GladeModel {
  late GladeInput<int> a;
  late GladeInput<int> b;

  @override
  List<GladeInput<Object?>> get inputs => [a, b];

  @override
  void initialize() {
    a = GladeInput.intInput(value: 0, inputKey: 'a');
    b = GladeInput.intInput(value: 1, inputKey: 'b');

    super.initialize();
  }
}

void main() {
  test('When updating [a] listeners is called', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    model.a.value = 5;
    expect(model.a.value, equals(5));
    expect(model.lastUpdatedInputKeys, equals(['a']));
    expect(listenerCount, equals(1), reason: 'Should be called');
  });

  test('When updating [a] listeners is called', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    model.b.value = 5;
    expect(model.b.value, equals(5));
    expect(model.lastUpdatedInputKeys, equals(['b']));
    expect(listenerCount, equals(1), reason: 'Should be called');
  });

  test('When updating [a] and [b] listeners are called two times', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    model.a.value = 3;

    expect(model.a.value, equals(3));
    expect(model.lastUpdatedInputKeys, equals(['a']));

    model.b.value = 5;

    expect(model.b.value, equals(5));
    expect(model.lastUpdatedInputKeys, equals(['b']));
    expect(listenerCount, equals(2), reason: 'Should be called');
  });

  test('When updating [a] and [b] at once listener is called once', () {
    final model = _Model();
    var listenerCount = 0;
    model.addListener(() {
      listenerCount++;
    });

    // ignore: cascade_invocations, under test ok.
    model.groupEdit(() {
      model.a.value = 3;
      model.b.value = 5;
    });

    expect(model.a.value, equals(3));
    expect(model.b.value, equals(5));

    expect(model.lastUpdatedInputKeys, equals(['a', 'b']));
    expect(listenerCount, equals(1), reason: 'Should be called');
  });
}
