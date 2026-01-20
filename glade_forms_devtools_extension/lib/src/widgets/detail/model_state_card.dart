import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_base_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/state_chip.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/state_row.dart';

class ModelStateCard extends StatelessWidget {
  final GladeBaseModelDescription model;

  const ModelStateCard({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          spacing: Constants.spacing16,
          children: [
            Text(
              'Model State',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: .bold,
              ),
            ),
            Wrap(
              spacing: 4,
              children: [
                StateChip(
                  label: model.validityLabel,
                  color: model.validityColor,
                ),
                StateChip(label: model.purityLabel, color: model.purityColor),
                StateChip(label: model.changeLabel, color: model.changeColor),
              ],
            ),
            StateRow(
              label: 'Is Valid',
              value: model.isValid,
              icon: model.validityIcon,
            ),
            StateRow(
              label: 'Is Pure',
              value: model.isPure,
              icon: Icons.clean_hands_outlined,
            ),
            StateRow(
              label: 'Is Unchanged',
              value: model.isUnchanged,
              icon: model.changeIcon,
            ),
          ],
        ),
      ),
    );
  }
}
