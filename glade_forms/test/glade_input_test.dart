import 'package:flutter/widgets.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:test/test.dart';

void main() {
  test('GladeInput with non-nullable type', () {
    final input = GladeInput<int>.create(validator: (v) => v.build(), value: 0, inputKey: 'a');

    expect(input.isValid, isTrue);
  });

  test('GladeInput preserves selection on value change', () {
    final input = GladeInput<String>.create(validator: (v) => v.build(), value: 'abc', inputKey: 'a');

    // Set selection
    input.controller?.selection = const TextSelection.collapsed(offset: 1);
    final before = input.controller?.selection;

    // Update text value.
    input.updateValue('abXXXc');

    // ignore: avoid-duplicate-initializers, different value
    final after = input.controller?.selection;

    // Compare their offsets.
    expect(before?.baseOffset, equals(after?.baseOffset));
    expect(before?.extentOffset, equals(after?.extentOffset));
  });
}
