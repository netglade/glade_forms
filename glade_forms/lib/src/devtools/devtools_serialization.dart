import 'package:glade_forms/src/devtools/glade_input_dev_tools_serialization.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';

/// Extension providing DevTools serialization for GladeModelBase.
extension GladeModelBaseDevToolsSerialization on GladeModelBase {
  /// Serialize this model to a JSON map for DevTools.
  Map<String, dynamic> toDevToolsJson() {
    return {
      'debugKey': debugKey,
      'formattedErrors': this is GladeModel ? (this as GladeModel).formattedValidationErrors : '',
      'inputs': this is GladeModel
          ? (this as GladeModel).inputs.map((input) => input.toDevToolsJson()).toList()
          : <Map<String, dynamic>>[],
      'isDirty': isDirty,
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'isValid': isValid,
      'type': runtimeType.toString(),
    };
  }
}
