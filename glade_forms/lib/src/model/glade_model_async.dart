import 'dart:async';

import 'package:glade_forms/src/model/model.dart';
import 'package:meta/meta.dart';

abstract class GladeModelAsync extends GladeModelBase {
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
    super.initialize();
  }
}
