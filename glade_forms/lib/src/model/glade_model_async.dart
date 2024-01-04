import 'dart:async';

import 'package:glade_forms/src/model/model.dart';
import 'package:meta/meta.dart';

abstract class GladeModelAsync extends GladeModelBase {
  bool _initialized = false;

  bool get initialized => _initialized;

  GladeModelAsync() {
    unawaited(initializeAsync());
  }

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @mustBeOverridden
  @protected
  Future<void> initializeAsync() async {
    assert(
      inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
      'Model contains inputs with duplicated key!',
    );

    for (final input in inputs) {
      input.bindToModel(this);
    }

    _initialized = true;
    notifyListeners();
  }
}
