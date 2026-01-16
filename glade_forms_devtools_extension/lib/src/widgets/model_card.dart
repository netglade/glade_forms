import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

/// Widget to display a single GladeModel instance.
class ModelCard extends StatelessWidget {
  final GladeModelDescription model;
  final VoidCallback? onTap;
  final bool isSelected;

  const ModelCard({
    required this.model,
    this.onTap,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      margin: const .symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const .all(12),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Icon(
                    model.isComposed ? Icons.account_tree : Icons.assignment,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          model.type,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: .bold,
                          ),
                          overflow: .ellipsis,
                        ),
                        if (model.isComposed)
                          Text(
                            'Composed Model',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StatusChip(
                    label: model.isValid ? 'Valid' : 'Invalid',
                    color: model.isValid ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _StatusChip(
                    label: model.isPure ? 'Pure' : 'Dirty',
                    color: model.isPure ? Colors.blue : Colors.orange,
                    isSmall: true,
                  ),
                  if (model.isUnchanged)
                    const _StatusChip(
                      label: 'Unchanged',
                      color: Colors.grey,
                      isSmall: true,
                    ),
                  if (model.isComposed)
                    _StatusChip(
                      label: '${model.childModels.length} models',
                      color: theme.colorScheme.primary,
                      isSmall: true,
                    )
                  else
                    _StatusChip(
                      label: '${model.inputs.length} inputs',
                      color: Colors.grey,
                      isSmall: true,
                    ),
                ],
              ),
              if (model.formattedErrors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const .all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: const .all(.circular(4)),
                  ),
                  child: Row(
                    spacing: 4,
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Colors.red),
                      Expanded(
                        child: Text(
                          model.formattedErrors,
                          style: theme.textTheme.bodySmall?.withColor(Colors.red),
                          maxLines: 2,
                          overflow: .ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSmall;

  const _StatusChip({
    required this.label,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: const .all(.circular(12)),
        border: .all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: isSmall ? 11 : 12,
          fontWeight: .w500,
        ),
      ),
    );
  }
}
