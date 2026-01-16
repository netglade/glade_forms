import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/info_row.dart';

class GladeInputCard extends StatelessWidget {
  final GladeInputDescription input;

  const GladeInputCard({required this.input, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasErrors = input.errors.isNotEmpty;
    final hasWarnings = input.warnings.isNotEmpty;

    return Card(
      margin: const .only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          input.isValid ? Icons.check_circle : Icons.error,
          color: input.isValid ? Colors.green : Colors.red,
        ),
        title: Text(input.key, style: const TextStyle(fontWeight: .bold)),
        subtitle: Row(
          children: [
            const Text('Value: '),
            InputValue(
              value: input.value,
              hasBackgroundWhitespaceIndicator: true,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const .all(16),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                InfoRow(label: 'Type', value: input.type),
                InfoRow(label: 'Input key', value: input.key),
                InfoRow(
                  label: 'Dependencies',
                  value: input.dependencies.isNotEmpty ? '[${input.dependencies.join(', ')}] ' : 'None',
                ),
                const Divider(height: 16),
                InfoRow(
                  label: 'Current Value',
                  value: input.value,
                  hasBackgroundWhitespaceIndicator: true,
                ),
                InfoRow(
                  label: 'Initial Value',
                  value: input.initialValue,
                  hasBackgroundWhitespaceIndicator: true,
                ),
                const Divider(height: 16),
                InfoRow(label: 'Valid', value: input.isValid),
                Row(
                  children: [
                    Expanded(
                      child: InfoRow(
                        label: 'Has Validation error',
                        value: input.hasErrors,
                        hasInverseBoolColors: true,
                      ),
                    ),
                    Expanded(
                      child: InfoRow(
                        label: 'Has Conversion Error',
                        value: input.hasConversionError,
                        hasInverseBoolColors: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InfoRow(
                        label: 'Unchanged',
                        value: input.isUnchanged,
                      ),
                    ),
                    Expanded(
                      child: InfoRow(label: 'Pure', value: input.isPure),
                    ),
                  ],
                ),
                if (hasErrors) ...[
                  const Divider(height: 16),
                  Text(
                    'Errors:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: .bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final error in input.errors)
                    _ValidationMessage(
                      message: error,
                      icon: Icons.error_outline,
                      color: Colors.red,
                    ),
                ],
                if (hasWarnings) ...[
                  const Divider(height: 16),
                  Text(
                    'Warnings:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: .bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final warning in input.warnings)
                    _ValidationMessage(
                      message: warning,
                      icon: Icons.warning_amber,
                      color: Colors.orange,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _ValidationMessage({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const .only(bottom: 4),
      child: Row(
        crossAxisAlignment: .start,
        spacing: Constants.spacing8,
        children: [
          Icon(icon, size: 16, color: color),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
