import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/glade_input_card.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/model_state_card.dart';

/// Widget to display detailed information about a GladeModel
class ModelDetailView extends StatelessWidget {
  final GladeBaseModelDescription model;

  const ModelDetailView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model header
          Text(
            model.type,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${model.id}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Model state card
          ModelStateCard(model: model),
          const SizedBox(height: GladeFormsConstants.spacing16),

          // Inputs section
          Text(
            'Inputs (${model.inputs.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: GladeFormsConstants.spacing8),
          ...model.inputs.map((input) => GladeInputCard(input: input)),
        ],
      ),
    );
  }
}
