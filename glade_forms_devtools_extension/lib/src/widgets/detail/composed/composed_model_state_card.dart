import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/state_badge.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class ComposedModelStateCard extends StatelessWidget {
  final GladeModelDescription model;

  const ComposedModelStateCard({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Own inputs are aggregated together with the contained models, so the labels must not claim
    // the state describes the models alone.
    final scope = model.inputs.isEmpty ? 'All Models' : 'Own Inputs + Models';

    return Card(
      child: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              spacing: Constants.spacing8,
              children: [
                const Icon(Icons.info_outline, size: 20),
                Text(
                  'Overall State',
                  style: theme.textTheme.titleMedium?.bold,
                ),
              ],
            ),
            const SizedBox(height: 12),
            StateBadge(
              label: '$scope Valid',
              value: model.isValid,
              icon: model.isValid ? Icons.check_circle : Icons.cancel,
              color: model.validityColor,
            ),
            const Divider(height: 16),
            StateBadge(
              label: '$scope Pure',
              value: model.isPure,
              icon: model.isPure ? Icons.check_circle : Icons.cancel,
              color: model.purityColor,
            ),
            const Divider(height: 16),
            StateBadge(
              label: '$scope Unchanged',
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
