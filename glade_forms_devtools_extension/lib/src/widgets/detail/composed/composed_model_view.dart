import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/composed_child_model_card.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/state_badge.dart';

/// Widget to display a composed model with its child models
class ComposedModelView extends StatelessWidget {
  final GladeModelDescription model;

  const ComposedModelView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Composed Model header
          Row(
            children: [
              const Icon(Icons.account_tree, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.type,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Composed Model',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
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
            children: [
              const Icon(Icons.list, size: 20),
              const SizedBox(width: 8),
              Text(
                'Child Models (${model.childModels.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (model.childModels.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withAlpha((0.5 * 255).toInt()),
                      ),
                      const SizedBox(height: 8),
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

class ComposedModelStateCard extends StatelessWidget {
  final GladeModelDescription model;

  const ComposedModelStateCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Overall State',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StateBadge(
              label: 'All Models Valid',
              value: model.isValid,
              icon: model.isValid ? Icons.check_circle : Icons.cancel,
              color: model.validityColor,
            ),
            const Divider(height: 16),
            StateBadge(
              label: 'All Models Pure',
              value: model.isPure,
              icon: model.isPure ? Icons.check_circle : Icons.cancel,
              color: model.purityColor,
            ),
            const Divider(height: 16),
            StateBadge(
              label: 'All Models Unchanged',
              value: model.isUnchanged,
              icon: model.isUnchanged ? Icons.check : Icons.edit,
              color: model.changeColor,
            ),
          ],
        ),
      ),
    );
  }
}
