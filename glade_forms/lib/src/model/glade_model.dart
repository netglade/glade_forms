import 'package:glade_forms/src/model/model.dart';
import 'package:meta/meta.dart';

abstract class GladeModel extends GladeModelBase {
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
