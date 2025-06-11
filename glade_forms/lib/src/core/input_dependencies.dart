// ignore_for_file: avoid-dynamic, prefer-match-file-name

import 'package:collection/collection.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/utils/object_ex.dart';

typedef InputDependencies = List<GladeInput<Object?>>;
typedef InputDependenciesFactory = InputDependencies Function();

extension InputDependenciesFunctions on InputDependencies {
  /// Finds input by its key or throws.
  GladeInput<T> byKey<T>(String key) => ObjectHelper.cast(firstWhere((x) => x.inputKey == key));

  /// Finds input by its key or returns null.
  GladeInput<T>? byKeyOrNull<T>(String key) => ObjectHelper.castOrNull(firstWhereOrNull((x) => x.inputKey == key));
}
