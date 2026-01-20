import 'package:glade_forms_devtools_extension/src/models/child_glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_base_model_description.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';

/// Data model representing a GladeModel instance for DevTools display.
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
      // ignore: avoid-dynamic, can be anything
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => GladeInputDescription.fromJson(e as Map<String, dynamic>))
          .toList(),
      formattedErrors: json['formattedErrors'] as String? ?? '',
      isComposed: json['isComposed'] as bool? ?? false,
      childModels:
          // ignore: avoid-dynamic, can be anything
          (json['childModels'] as List<dynamic>?)
              ?.map(
                (e) => ChildGladeModelDescription.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childModels': childModels.map((e) => e.toJson()).toList(),
      'formattedErrors': formattedErrors,
      'id': id,
      'inputs': inputs.map((e) => e.toJson()).toList(),
      'isComposed': isComposed,
      'isDirty': isDirty,
      'isPure': isPure,
      'isUnchanged': isUnchanged,
      'isValid': isValid,
      'type': type,
    };
  }
}
