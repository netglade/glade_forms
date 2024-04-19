import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends GladeModelBase {
  GladeModel() {
    initialize();
  }

  // /// Initialize model's inputs.
  // ///
  // /// `super.initialize()` must be called in the end.
  // @mustCallSuper
  // @mustBeOverridden
  // @protected
  // void initialize() {
  //   assert(
  //     inputs.map((e) => e.inputKey).length == inputs.map((e) => e.inputKey).toSet().length,
  //     'Model contains inputs with duplicated key!',
  //   );

  //   for (final input in allInputs) {
  //     input.bindToModel(this);
  //   }
  // }
}
