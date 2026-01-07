/// Data model representing a GladeModel instance for DevTools display
class FormModelData {
  final String id;
  final String type;
  final bool isValid;
  final bool isPure;
  final bool isDirty;
  final bool isUnchanged;
  final List<FormInputData> inputs;
  final String formattedErrors;

  const FormModelData({
    required this.id,
    required this.type,
    required this.isValid,
    required this.isPure,
    required this.isDirty,
    required this.isUnchanged,
    required this.inputs,
    required this.formattedErrors,
  });

  factory FormModelData.fromJson(Map<String, dynamic> json) {
    return FormModelData(
      id: json['id'] as String,
      type: json['type'] as String,
      isValid: json['isValid'] as bool,
      isPure: json['isPure'] as bool,
      isDirty: json['isDirty'] as bool,
      isUnchanged: json['isUnchanged'] as bool,
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => FormInputData.fromJson(e as Map<String, dynamic>))
          .toList(),
      formattedErrors: json['formattedErrors'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'isValid': isValid,
      'isPure': isPure,
      'isDirty': isDirty,
      'isUnchanged': isUnchanged,
      'inputs': inputs.map((e) => e.toJson()).toList(),
      'formattedErrors': formattedErrors,
    };
  }
}

/// Data model representing a GladeInput for DevTools display
class FormInputData {
  final String key;
  final String type;
  final String value;
  final String? initialValue;
  final bool isValid;
  final bool isPure;
  final bool isUnchanged;
  final bool hasConversionError;
  final List<String> errors;
  final List<String> warnings;

  const FormInputData({
    required this.key,
    required this.type,
    required this.value,
    this.initialValue,
    required this.isValid,
    required this.isPure,
    required this.isUnchanged,
    required this.hasConversionError,
    required this.errors,
    required this.warnings,
  });

  factory FormInputData.fromJson(Map<String, dynamic> json) {
    return FormInputData(
      key: json['key'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      initialValue: json['initialValue'] as String?,
      isValid: json['isValid'] as bool,
      isPure: json['isPure'] as bool,
      isUnchanged: json['isUnchanged'] as bool,
      hasConversionError: json['hasConversionError'] as bool,
      errors: (json['errors'] as List<dynamic>).cast<String>(),
      warnings: (json['warnings'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'type': type,
      'value': value,
      'initialValue': initialValue,
      'isValid': isValid,
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'hasConversionError': hasConversionError,
      'errors': errors,
      'warnings': warnings,
    };
  }
}
