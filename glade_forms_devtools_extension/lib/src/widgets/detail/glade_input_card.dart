import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/info_row.dart';

class GladeInputCard extends StatelessWidget {
  final GladeInputDescription input;

  const GladeInputCard({super.key, required this.input});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasErrors = input.errors.isNotEmpty;
    final hasWarnings = input.warnings.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          input.isValid ? Icons.check_circle : Icons.error,
          color: input.isValid ? Colors.green : Colors.red,
        ),
        title: Text(
          input.key,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text('Value: '),
            InputValue(
              value: input.value,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'Type', value: input.type),
                InfoRow(label: 'Input key', value: input.key),
                const Divider(height: 16),
                InfoRow(
                  label: 'Current Value',
                  value: input.value,
                  hasBackgroundWhitespaceIndicator: true,
                ),
                if (input.initialValue != null)
                  InfoRow(
                    label: 'Initial Value',
                    value: input.initialValue!,
                    hasBackgroundWhitespaceIndicator: true,
                  ),
                const Divider(height: 16),
                InfoRow(
                  label: 'Valid',
                  value: input.isValid,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InfoRow(
                        label: 'Has Validation error',
                        value: input.hasErrors,
                        inverseBoolColors: true,
                      ),
                    ),
                    Expanded(
                      child: InfoRow(
                        label: 'Has Conversion Error',
                        value: input.hasConversionError,
                        inverseBoolColors: true,
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
                      child: InfoRow(
                        label: 'Pure',
                        value: input.isPure,
                      ),
                    ),
                  ],
                ),
                if (hasErrors) ...[
                  const Divider(height: 16),
                  Text(
                    'Errors:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...input.errors.map(
                    (error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (hasWarnings) ...[
                  const Divider(height: 16),
                  Text(
                    'Warnings:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...input.warnings.map(
                    (warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warning,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
