import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final Object? value;
  final bool inverseBoolColors;
  final bool hasBackgroundWhitespaceIndicator;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.inverseBoolColors = false,
    this.hasBackgroundWhitespaceIndicator = false,
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
        InputValue(
          value: value,
          inverseBoolColors: inverseBoolColors,
          hasBackgroundWhitespaceIndicator: hasBackgroundWhitespaceIndicator,
        ),
      ],
    );
  }
}
