import 'package:glade_forms_devtools_extension/src/models/glade_base_model_description.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';

/// Data model representing a child model within a GladeComposedModel.
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
      // ignore: avoid-dynamic, can be anything
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => GladeInputDescription.fromJson(e as Map<String, dynamic>))
          .toList(),
      formattedErrors: json['formattedErrors'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formattedErrors': formattedErrors,
      'id': id,
      'index': index,
      'inputs': inputs.map((e) => e.toJson()).toList(),
      'isDirty': isDirty,
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'isValid': isValid,
      'type': type,
    };
  }
}
