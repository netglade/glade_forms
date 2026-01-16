import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/composed_child_model_card.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/composed_model_state_card.dart';

/// Widget to display a composed model with its child models.
class ComposedModelView extends StatelessWidget {
  final GladeModelDescription model;

  const ComposedModelView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Composed Model header
          Row(
            spacing: Constants.spacing16,
            children: [
              const Icon(Icons.account_tree, size: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      model.type,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: .bold,
                      ),
                    ),
                    Text(
                      'Composed Model',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: .w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${model.id}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Composed Model state card
          ComposedModelStateCard(model: model),
          const SizedBox(height: 16),

          // Child Models section
          Row(
            spacing: Constants.spacing8,
            children: [
              const Icon(Icons.list, size: 20),
              Text(
                'Child Models (${model.childModels.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: .bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (model.childModels.isEmpty)
            Card(
              child: Padding(
                padding: const .all(24),
                child: Center(
                  child: Column(
                    spacing: Constants.spacing8,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withAlpha((0.5 * 255).toInt()),
                      ),
                      Text(
                        'No child models',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...model.childModels.map((child) => ComposedChildModelCard(child: child)),
        ],
      ),
    );
  }
}
