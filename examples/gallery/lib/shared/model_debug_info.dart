import 'package:flutter/widgets.dart';
import 'package:glade_forms/glade_forms.dart';

class ModelDebugInfo extends StatelessWidget {
  final MutableGenericModel model;

  const ModelDebugInfo({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(model.formattedValidationErrors),
        Text('Model VALID? ${model.isValid}'),
      ],
    );
  }
}
