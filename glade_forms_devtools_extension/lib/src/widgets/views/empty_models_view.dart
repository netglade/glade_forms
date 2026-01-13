import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// View shown when no models are active.
class EmptyModelsView extends StatelessWidget {
  const EmptyModelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: GladeFormsConstants.iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: GladeFormsConstants.spacing16),
          Text(
            GladeFormsConstants.noModelsTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: GladeFormsConstants.spacing8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: GladeFormsConstants.spacing32),
            child: Text(
              GladeFormsConstants.noModelsMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
