import 'package:flutter/widgets.dart';
import 'package:glade_forms/glade_forms.dart';

class ModelDebugInfo extends StatelessWidget {
  final GladeModel model;

  const ModelDebugInfo({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.formattedValidationErrors),
          Text('Model VALID? ${model.isValid}'),
        ],
      ),
    );
  }
}
