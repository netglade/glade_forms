import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_base_model_description.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/state_chip.dart';

/// A list item that represents a GladeModel in the sidebar.
/// For composed models, this shows an expandable tree view of child models.
class ModelListItem extends StatefulWidget {
  final GladeModelDescription model;
  final bool isSelected;
  final String? selectedChildId;
  final VoidCallback onTap;
  final ValueChanged<String>? onChildTap;

  const ModelListItem({
    required this.model,
    required this.isSelected,
    required this.onTap,
    this.selectedChildId,
    this.onChildTap,
    super.key,
  });

  @override
  State<ModelListItem> createState() => _ModelListItemState();
}

class _ModelListItemState extends State<ModelListItem> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    // For non-composed models, show a simple card
    if (!widget.model.isComposed) {
      return _ModelCard(
        model: widget.model,
        isSelected: widget.isSelected,
        onTap: widget.onTap,
        modelsCount: widget.model.childModels.length,
      );
    }

    // For composed models, show an expandable tree
    return Column(
      mainAxisSize: .min,
      children: [
        // Parent model card with expand/collapse
        _ModelCard(
          model: widget.model,
          isSelected: widget.isSelected && widget.selectedChildId == null,
          onTap: widget.onTap,
          modelsCount: widget.model.childModels.length,
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
            onPressed: () => setState(() {
              _isExpanded = !_isExpanded;
            }),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),

        // Child models (shown when expanded)
        if (_isExpanded)
          for (final child in widget.model.childModels)
            Padding(
              padding: const .only(left: 24),
              child: _ModelCard(
                model: child,
                isSelected: widget.selectedChildId == child.id,
                onTap: () => widget.onChildTap?.call(child.id),
                isChild: true,
              ),
            ),
      ],
    );
  }
}

/// A card widget displaying a model with its state and selection status.
class _ModelCard extends StatelessWidget {
  final GladeBaseModelDescription model;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isChild;
  final int modelsCount;

  final Widget? trailing;

  const _ModelCard({
    required this.model,
    required this.isSelected,
    required this.onTap,
    this.isChild = false,
    this.modelsCount = 0,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const .all(Constants.spacing4),
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: const .all(.circular(12)),
        child: Padding(
          padding: const .all(12),
          child: Row(
            children: [
              Icon(
                model.isComposed ? Icons.account_tree : Icons.assignment,
                size: isChild ? 18 : 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      model.debugKey,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? .w600 : .w500,
                      ),
                      overflow: .ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        StateChip(
                          label: model.validityLabel,
                          color: model.validityColor,
                        ),
                        StateChip(
                          label: model.purityLabel,
                          color: model.purityColor,
                        ),
                        StateChip(
                          label: model.changeLabel,
                          color: model.changeColor,
                        ),
                      ],
                    ),
                    if (modelsCount > 0)
                      Padding(
                        padding: const .only(top: 4),
                        child: Text(
                          '$modelsCount models',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
