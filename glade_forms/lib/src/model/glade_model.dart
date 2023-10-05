import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/model/glade_form_mixin.dart';

abstract class GladeModel extends ChangeNotifier with GladeFormMixin {
  void stringFieldUpdateInput<INPUT extends GladeInput<Object?>>(INPUT input, String? value) {
    if (input.value == value) return;

    input.updateValueWithString(value);
    notifyListeners();
  }

  void updateInput<INPUT extends GladeInput<T?>, T>(INPUT input, T value) {
    if (input.value == value) return;

    input.value = value;
    notifyListeners();
  }
}
