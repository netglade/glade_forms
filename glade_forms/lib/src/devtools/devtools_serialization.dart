import 'package:glade_forms/src/core/input/glade_input.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';

/// Extension providing DevTools serialization for GladeInput.
extension DevToolsSerialization<T> on GladeInput<T> {
  /// Serialize this input to a JSON map for DevTools.
  Map<String, dynamic> toDevToolsJson() {
    return {
      'errors': validationErrors.map((e) => e.toString()).toList(),
      'hasConversionError': hasConversionError,
      'initialValue': initialValue?.toString(),
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'isValid': isValid,
      'key': inputKey,
      'strValue': stringValue,
      'type': runtimeType,
      'value': value,
      'warnings': validationWarnings.map((e) => e.toString()).toList(),
    };
  }
}

/// Extension providing DevTools serialization for GladeModelBase.
// ignore: prefer-single-declaration-per-file, keep in same file.
extension GladeModelBaseDevToolsSerialization on GladeModelBase {
  /// Serialize this model to a JSON map for DevTools.
  Map<String, dynamic> toDevToolsJson() {
    return {
      'formattedErrors': this is GladeModel ? (this as GladeModel).formattedValidationErrors : '',
      'inputs': this is GladeModel
          ? (this as GladeModel).inputs.map((input) => input.toDevToolsJson()).toList()
          : <Map<String, dynamic>>[],
      'isDirty': isDirty,
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'isValid': isValid,
      'name': debugKey,
      'type': runtimeType.toString(),
    };
  }
}
