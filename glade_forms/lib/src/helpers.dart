import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

const DeepCollectionEquality _equality = DeepCollectionEquality();

/// Copied from https://github.dev/felangel/equatable.

/// Determines whether [list1] and [list2] are equal.
bool listEquals(List<Object?>? list1, List<Object?>? list2) {
  if (identical(list1, list2)) return true;
  if (list1 == null || list2 == null) return false;
  final length = list1.length;
  if (length != list2.length) return false;

  for (var i = 0; i < length; i++) {
    final unit1 = list1[i];
    final unit2 = list2[i];

    if (_isEquatable(unit1) && _isEquatable(unit2)) {
      if (unit1 != unit2) return false;
    } else if (unit1 is Iterable || unit1 is Map) {
      if (!_equality.equals(unit1, unit2)) return false;
    } else if (unit1?.runtimeType != unit2?.runtimeType) {
      return false;
    } else if (unit1 != unit2) {
      return false;
    }
  }

  return true;
}

bool _isEquatable(Object? object) {
  return object is Equatable || object is EquatableMixin;
}
