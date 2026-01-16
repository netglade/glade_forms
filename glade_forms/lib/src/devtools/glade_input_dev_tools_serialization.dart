import 'package:glade_forms/src/core/input/glade_input.dart';

/// Extension providing DevTools serialization for GladeInput.
extension GladeInputDevToolsSerialization<T> on GladeInput<T> {
  /// Serialize this input to a JSON map for DevTools.
  Map<String, dynamic> toDevToolsJson() {
    // Explicitly convert to string to ensure type safety (generics can be tricky)
    final strVal = stringValue;

    return {
      'depedencies': dependencies.map((d) => d.inputKey).toList(),
      'errors': validationErrors.map((e) => e.toString()).toList(),
      'hasConversionError': hasConversionError,
      'initialValue': initialValue,
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'isValid': isValid,
      'key': inputKey,
      'strValue': strVal,
      // ignore: no_runtimetype_tostring, keep as is.
      'type': runtimeType.toString(),
      'value': _encodeValue(value), // Smart encoding for JSON
      'warnings': validationWarnings.map((e) => e.toString()).toList(),
    };
  }

  /// Encode value for JSON - keep primitives as-is, convert complex objects to strings.
  // ignore: no-object-declaration, keep object, avoid-unnecessary-nullable-parameters
  Object? _encodeValue(T? val) {
    if (val == null) return null;

    // Keep JSON-primitive types as-is for proper UI rendering
    if (val is bool || val is int || val is double || val is String) {
      return val;
    }

    // Convert complex objects (Lists, Maps, custom classes) to strings
    return val.toString();
  }
}
