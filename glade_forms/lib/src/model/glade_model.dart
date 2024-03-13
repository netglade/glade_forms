import 'package:glade_forms/src/core/glade_input.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends GladeModelBase<GladeInput<Object?>> {
  GladeModel() {
    initialize();
  }

  /// Initialize model's inputs.
  ///
  /// `super.initialize()` must be called in the end.
  @override
  @mustCallSuper
  @mustBeOverridden
  @protected
  void initialize() {
    super.initialize();
  }
}
