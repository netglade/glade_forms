import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_base_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/glade_input_card.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/model_state_card.dart';

/// Widget to display detailed information about a GladeModel.
class ModelDetailView extends StatelessWidget {
  final GladeBaseModelDescription model;

  const ModelDetailView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Model header
          Text(
            model.type,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: .bold,
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
          const SizedBox(height: Constants.spacing16),

          // Inputs section
          Text(
            'Inputs (${model.inputs.length})',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold),
          ),
          const SizedBox(height: Constants.spacing8),
          for (final input in model.inputs) GladeInputCard(input: input),
        ],
      ),
    );
  }
}
