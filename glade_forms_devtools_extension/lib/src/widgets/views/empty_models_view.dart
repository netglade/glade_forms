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
        mainAxisAlignment: .center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: Constants.iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: Constants.spacing16),
          Text(
            Constants.noModelsTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: Constants.spacing8),
          const Padding(
            padding: .symmetric(horizontal: Constants.spacing32),
            child: Text(Constants.noModelsMessage, textAlign: .center),
          ),
        ],
      ),
    );
  }
}
