// ignore_for_file: avoid-dynamic, prefer-match-file-name

import 'package:collection/collection.dart';
import 'package:glade_forms/src/core/core.dart';

typedef InputDependencies = List<GladeInput<Object?>>;
typedef InputDependenciesFactory = InputDependencies Function();

extension InputDependenciesFunctions on InputDependencies {
  GladeInput<T>? byKey<T>(String key) => firstWhereOrNull((x) => x.inputKey == key).castOrNull<GladeInput<T>>();
}

extension ObjectEx on Object? {
  T? castOrNull<T>() => this is T ? this as T : null;
}
