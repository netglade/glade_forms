import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/child_glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/state_chip.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/composed_child_model_input_summary.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/state_badge.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class ComposedChildModelCard extends StatefulWidget {
  final ChildGladeModelDescription child;

  const ComposedChildModelCard({required this.child, super.key});

  @override
  State<ComposedChildModelCard> createState() => _ComposedChildModelCardState();
}

class _ComposedChildModelCardState extends State<ComposedChildModelCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = widget.child;

    return Card(
      margin: const .only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: child.isValid
                  ? Constants.validColor.withValues(alpha: 0.2)
                  : Constants.invalidColor.withValues(alpha: 0.2),
              child: Text(
                '${child.index + 1}',
                style: TextStyle(
                  color: child.isValid ? Constants.validColor : Constants.invalidColor,
                  fontWeight: .bold,
                ),
              ),
            ),
            title: Text(
              child.debugKey,
              style: theme.textTheme.bodyMedium?.bold,
            ),
            subtitle: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                StateChip(
                  label: child.validityLabel,
                  color: child.validityColor,
                ),
                StateChip(
                  label: child.purityLabel,
                  color: child.purityColor,
                ),
                StateChip(
                  label: '${child.inputs.length} inputs',
                  color: Colors.grey,
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const .all(16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  // Model state
                  Text(
                    'State',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: .bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StateBadge(
                    label: 'Valid',
                    value: child.isValid,
                    icon: child.validityIcon,
                    color: child.validityColor,
                  ),
                  const Divider(height: 16),
                  StateBadge(
                    label: 'Pure',
                    value: child.isPure,
                    icon: child.purityStateIcon,
                    color: child.purityColor,
                  ),
                  const Divider(height: 16),
                  StateBadge(
                    label: 'Unchanged',
                    value: child.isUnchanged,
                    icon: child.changeIcon,
                    color: child.changeColor,
                  ),

                  if (child.formattedErrors.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const .all(12),
                      decoration: BoxDecoration(
                        color: child.validityColor.withValues(alpha: 0.2),
                        borderRadius: const .all(.circular(8)),
                        border: .all(
                          color: child.validityColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: .start,
                        spacing: 8,
                        children: [
                          Icon(Icons.error_outline, size: 20, color: child.validityColor),
                          Expanded(
                            child: Text(
                              child.formattedErrors,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: child.validityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (child.inputs.isNotEmpty) ...[
                    const SizedBox(height: Constants.spacing16),
                    Text(
                      'Inputs (${child.inputs.length})',
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    const SizedBox(height: 8),
                    for (final input in child.inputs) ComposedChildModelInputSummary(input: input),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
