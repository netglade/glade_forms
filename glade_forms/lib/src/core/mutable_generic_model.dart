import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/core.dart';

abstract class MutableGenericModel extends ChangeNotifier with GladeFormMixin {
  // @protected
  // void updateInput<INPUT extends GladeInput<T>, T>(INPUT input, T value, void Function(INPUT v) assign) {
  //   if (input.value == value) return;

  //   assign(input.asDirty(value) as INPUT);
  //   notifyListeners();
  // }

  void stringFieldUpdateInput<INPUT extends GladeInput<Object?>>(INPUT input, String? value) {
    if (input.value == value) return;

    input.updateValueWithString(value);
    notifyListeners();
  }

  void updateInput<INPUT extends GladeInput<T>, T>(INPUT input, T value) {
    if (input.value == value) return;

    input.value = value;
    notifyListeners();
  }
}
