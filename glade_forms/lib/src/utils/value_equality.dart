import 'package:collection/collection.dart';

/// Equality used by inputs when comparing values (initial vs current, previous vs new).
///
/// Collections are compared deeply, everything else with `identical` and `==`.
abstract final class ValueEquality {
  static bool equals<T>(T? a, T? b) {
    if (identical(a, b)) return true;

    if (a is List || a is Map || a is Set) {
      return const DeepCollectionEquality().equals(a, b);
    }

    return a == b;
  }
}
