import 'dart:ui';

import 'package:glade_forms_devtools_extension/src/constants.dart';

/// Data model representing a GladeInput for DevTools display
class GladeInputDescription {
  final String key;
  final String type;
  final String strValue;
  final Object? value;
  final Object? initialValue;
  final bool isValid;
  final bool isPure;
  final bool isUnchanged;
  final bool hasConversionError;
  final List<String> errors;
  final List<String> warnings;

  const GladeInputDescription({
    required this.key,
    required this.type,
    required this.strValue,
    required this.value,
    this.initialValue,
    required this.isValid,
    required this.isPure,
    required this.isUnchanged,
    required this.hasConversionError,
    required this.errors,
    required this.warnings,
  });

  // UI Domain Logic

  /// Label for validation state
  String get validityLabel => isValid ? 'Valid' : 'Invalid';

  /// Color for validation state
  Color get validityColor => isValid ? GladeFormsConstants.validColor : GladeFormsConstants.invalidColor;

  /// Label for purity state
  String get purityLabel => isPure ? 'Pure' : 'Dirty';

  /// Color for purity state
  Color get purityColor => isPure ? GladeFormsConstants.pureColor : GladeFormsConstants.dirtyColor;

  /// Label for change state
  String get changeLabel => isUnchanged ? 'Unchanged' : 'Modified';

  /// Color for change state
  Color get changeColor => isUnchanged ? GladeFormsConstants.unchangedColor : GladeFormsConstants.modifiedColor;

  /// Label for conversion error state
  String get conversionLabel => hasConversionError ? 'Conversion Error' : 'OK';

  /// Color for conversion error state
  Color get conversionColor => hasConversionError ? GladeFormsConstants.errorColor : GladeFormsConstants.successColor;

  /// Returns true if the input has any errors
  bool get hasErrors => errors.isNotEmpty || hasConversionError;

  /// Returns true if the input has any warnings
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns true if the input has been modified
  bool get isModified => !isUnchanged;

  /// Badge text for errors and warnings count
  String? get issuesBadge {
    final errorCount = errors.length;
    final warningCount = warnings.length;

    if (errorCount == 0 && warningCount == 0) return null;

    final parts = <String>[];
    if (errorCount > 0) parts.add('$errorCount error${errorCount > 1 ? 's' : ''}');
    if (warningCount > 0) parts.add('$warningCount warning${warningCount > 1 ? 's' : ''}');

    return parts.join(', ');
  }

  /// Color for issues badge
  Color get issuesBadgeColor {
    if (errors.isNotEmpty) return GladeFormsConstants.errorColor;
    if (warnings.isNotEmpty) return GladeFormsConstants.warningColor;
    return GladeFormsConstants.successColor;
  }

  factory GladeInputDescription.fromJson(Map<String, dynamic> json) {
    return GladeInputDescription(
      key: json['key'] as String,
      type: json['type'] as String,
      strValue: json['strValue'] as String,
      value: json['value'] as Object?,
      initialValue: json['initialValue'] as Object?,
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
