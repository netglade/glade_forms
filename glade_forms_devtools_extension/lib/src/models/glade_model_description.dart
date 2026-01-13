import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';

/// Base class for model data with common properties and UI logic
abstract class GladeBaseModelDescription {
  final String id;
  final String debugKey;
  final String type;
  final bool isValid;
  final bool isPure;
  final bool isDirty;
  final bool isUnchanged;
  final List<GladeInputDescription> inputs;
  final String formattedErrors;

  bool get isComposed;

  const GladeBaseModelDescription({
    required this.id,
    required this.debugKey,
    required this.type,
    required this.isValid,
    required this.isPure,
    required this.isDirty,
    required this.isUnchanged,
    required this.inputs,
    required this.formattedErrors,
  });

  // UI Domain Logic

  /// Label for validation state
  String get validityLabel => isValid ? 'Valid' : 'Invalid';

  /// Color for validation state chip
  Color get validityColor => isValid ? GladeFormsConstants.validColor : GladeFormsConstants.invalidColor;

  IconData get validityIcon => isValid ? Icons.check_circle_outline : Icons.error_outline;

  /// Label for purity state
  String get purityLabel => isPure ? 'Pure' : 'Dirty';

  /// Color for purity state chip
  Color get purityColor => isPure ? GladeFormsConstants.pureColor : GladeFormsConstants.dirtyColor;

  IconData get purityStateIcon => isPure ? Icons.clean_hands_outlined : Icons.warning_amber_outlined;

  /// Label for change state
  String get changeLabel => isUnchanged ? 'Unchanged' : 'Modified';

  /// Color for change state chip
  Color get changeColor => isUnchanged ? GladeFormsConstants.unchangedColor : GladeFormsConstants.modifiedColor;

  IconData get changeIcon => isUnchanged ? Icons.check_circle_outline : Icons.edit;

  /// Overall state description for display
  String get stateDescription {
    final parts = <String>[
      validityLabel,
      purityLabel,
      changeLabel,
    ];
    return parts.join(' • ');
  }

  /// Returns true if the model has any errors
  bool get hasErrors => !isValid;

  /// Returns true if the model has been modified
  bool get isModified => !isUnchanged;
}

/// Data model representing a GladeModel instance for DevTools display
class GladeModelDescription extends GladeBaseModelDescription {
  @override
  final bool isComposed;
  final List<ChildGladeModelDescription> childModels;

  const GladeModelDescription({
    required super.id,
    required super.debugKey,
    required super.type,
    required super.isValid,
    required super.isPure,
    required super.isDirty,
    required super.isUnchanged,
    required super.inputs,
    required super.formattedErrors,
    this.isComposed = false,
    this.childModels = const [],
  });

  factory GladeModelDescription.fromJson(Map<String, dynamic> json) {
    return GladeModelDescription(
      id: json['id'] as String,
      debugKey: json['debugKey'] as String,
      type: json['type'] as String,
      isValid: json['isValid'] as bool,
      isPure: json['isPure'] as bool,
      isDirty: json['isDirty'] as bool,
      isUnchanged: json['isUnchanged'] as bool,
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => GladeInputDescription.fromJson(e as Map<String, dynamic>))
          .toList(),
      formattedErrors: json['formattedErrors'] as String? ?? '',
      isComposed: json['isComposed'] as bool? ?? false,
      childModels: (json['childModels'] as List<dynamic>?)
              ?.map((e) => ChildGladeModelDescription.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      'isComposed': isComposed,
      'childModels': childModels.map((e) => e.toJson()).toList(),
    };
  }
}

/// Data model representing a child model within a GladeComposedModel
class ChildGladeModelDescription extends GladeBaseModelDescription {
  final int index;

  @override
  bool get isComposed => false;

  const ChildGladeModelDescription({
    required super.id,
    required this.index,
    required super.debugKey,
    required super.type,
    required super.isValid,
    required super.isPure,
    required super.isDirty,
    required super.isUnchanged,
    required super.inputs,
    required super.formattedErrors,
  });

  factory ChildGladeModelDescription.fromJson(Map<String, dynamic> json) {
    return ChildGladeModelDescription(
      id: json['id'] as String,
      debugKey: json['debugKey'] as String,
      index: json['index'] as int,
      type: json['type'] as String,
      isValid: json['isValid'] as bool,
      isPure: json['isPure'] as bool,
      isDirty: json['isDirty'] as bool,
      isUnchanged: json['isUnchanged'] as bool,
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => GladeInputDescription.fromJson(e as Map<String, dynamic>))
          .toList(),
      formattedErrors: json['formattedErrors'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
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
