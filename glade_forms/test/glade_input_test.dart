import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  test('GladeInput with non-nullable type', () {
    final input = GladeInput<int>.create(validator: (v) => v.build(), value: 0);

    expect(input.isValid, isTrue);
  });
}
