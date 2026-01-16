import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';

/// Base class for model data with common properties and UI logic.
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

  // UI Domain Logic

  /// Label for validation state.
  String get validityLabel => isValid ? 'Valid' : 'Invalid';

  /// Color for validation state chip.
  Color get validityColor => isValid ? Constants.validColor : Constants.invalidColor;

  IconData get validityIcon => isValid ? Icons.check_circle_outline : Icons.error_outline;

  /// Label for purity state.
  String get purityLabel => isPure ? 'Pure' : 'Dirty';

  /// Color for purity state chip.
  Color get purityColor => isPure ? Constants.pureColor : Constants.dirtyColor;

  IconData get purityStateIcon => isPure ? Icons.clean_hands_outlined : Icons.warning_amber_outlined;

  /// Label for change state.
  String get changeLabel => isUnchanged ? 'Unchanged' : 'Modified';

  /// Color for change state chip.
  Color get changeColor => isUnchanged ? Constants.unchangedColor : Constants.modifiedColor;

  IconData get changeIcon => isUnchanged ? Icons.check_circle_outline : Icons.edit;

  /// Overall state description for display.
  String get stateDescription {
    final parts = [validityLabel, purityLabel, changeLabel];

    // ignore: avoid-non-ascii-symbols, for better readability
    return parts.join(' • ');
  }

  /// Returns true if the model has any errors.
  bool get hasErrors => !isValid;

  /// Returns true if the model has been modified.
  bool get isModified => !isUnchanged;

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
}
