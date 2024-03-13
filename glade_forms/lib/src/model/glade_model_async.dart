import 'dart:async';

import 'package:glade_forms/src/core/glade_input_base.dart';
import 'package:glade_forms/src/model/model.dart';
import 'package:meta/meta.dart';

/// Async version of GladeModel.
abstract class GladeModelAsync extends GladeModelBase<GladeInputBase<Object?>> {
  GladeModelAsync() {
    unawaited(initializeAsync());
  }

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @mustCallSuper
  @mustBeOverridden
  @protected
  Future<void> initializeAsync() {
    super.initialize();

    return Future.value();
  }
}
