import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/models/form_model_data.dart';

/// Widget to display detailed information about a GladeModel
class ModelDetailView extends StatelessWidget {
  final FormModelData model;

  const ModelDetailView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model header
          Text(
            model.type,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${model.id}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Model state card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form State',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StateRow(
                    label: 'Valid',
                    value: model.isValid,
                    icon: model.isValid ? Icons.check_circle : Icons.cancel,
                    color: model.isValid ? Colors.green : Colors.red,
                  ),
                  const Divider(height: 16),
                  _StateRow(
                    label: 'Pure',
                    value: model.isPure,
                    icon: model.isPure ? Icons.check_circle : Icons.cancel,
                    color: model.isPure ? Colors.blue : Colors.orange,
                  ),
                  const Divider(height: 16),
                  _StateRow(
                    label: 'Dirty',
                    value: model.isDirty,
                    icon: model.isDirty ? Icons.edit : Icons.check,
                    color: model.isDirty ? Colors.orange : Colors.grey,
                  ),
                  const Divider(height: 16),
                  _StateRow(
                    label: 'Unchanged',
                    value: model.isUnchanged,
                    icon: model.isUnchanged ? Icons.check : Icons.edit,
                    color: model.isUnchanged ? Colors.grey : Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Inputs section
          Text(
            'Inputs (${model.inputs.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...model.inputs.map((input) => _InputCard(input: input)),
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final Color color;

  const _StateRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final FormInputData input;

  const _InputCard({required this.input});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasErrors = input.errors.isNotEmpty;
    final hasWarnings = input.warnings.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: hasErrors
          ? Colors.red.withOpacity(0.05)
          : hasWarnings
              ? Colors.orange.withOpacity(0.05)
              : null,
      child: ExpansionTile(
        leading: Icon(
          input.isValid ? Icons.check_circle : Icons.error,
          color: input.isValid ? Colors.green : Colors.red,
        ),
        title: Text(
          input.key,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Type: ${input.type} • Value: ${input.value}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Type', value: input.type),
                const Divider(height: 16),
                _InfoRow(label: 'Current Value', value: input.value),
                if (input.initialValue != null) ...[
                  const Divider(height: 16),
                  _InfoRow(label: 'Initial Value', value: input.initialValue!),
                ],
                const Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        label: 'Valid',
                        value: input.isValid.toString(),
                        valueColor: input.isValid ? Colors.green : Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _InfoRow(
                        label: 'Pure',
                        value: input.isPure.toString(),
                        valueColor: input.isPure ? Colors.blue : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        label: 'Unchanged',
                        value: input.isUnchanged.toString(),
                      ),
                    ),
                    Expanded(
                      child: _InfoRow(
                        label: 'Has Conversion Error',
                        value: input.hasConversionError.toString(),
                        valueColor: input.hasConversionError
                            ? Colors.red
                            : Colors.green,
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
                          const Icon(Icons.error_outline,
                              size: 16, color: Colors.red),
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
                          const Icon(Icons.warning_amber,
                              size: 16, color: Colors.orange),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
          ),
        ),
      ],
    );
  }
}
