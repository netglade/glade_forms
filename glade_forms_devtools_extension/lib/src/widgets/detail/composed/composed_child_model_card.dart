import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/state_chip.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/composed_child_model_input_summary.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/state_badge.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class ComposedChildModelCard extends StatefulWidget {
  final ChildGladeModelDescription child;

  const ComposedChildModelCard({super.key, required this.child});

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
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: child.isValid
                  ? GladeFormsConstants.validColor.withAlpha((0.2 * 255).toInt())
                  : GladeFormsConstants.invalidColor.withAlpha((0.2 * 255).toInt()),
              child: Text(
                '${child.index + 1}',
                style: TextStyle(
                  color: child.isValid ? GladeFormsConstants.validColor : GladeFormsConstants.invalidColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              child.debugKey,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model state
                  Text(
                    'State',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: child.validityColor.withAlpha((0.2 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: child.validityColor.withAlpha((0.2 * 255).toInt())),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, size: 20, color: child.validityColor),
                          const SizedBox(width: 8),
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
                    const SizedBox(height: GladeFormsConstants.spacing16),
                    Text(
                      'Inputs (${child.inputs.length})',
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    const SizedBox(height: 8),
                    ...child.inputs.map((input) => ComposedChildModelInputSummary(input: input)),
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
