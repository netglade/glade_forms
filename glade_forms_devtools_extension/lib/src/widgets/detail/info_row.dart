import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';

class InfoRow extends StatelessWidget {
  final String label;
  // ignore: no-object-declaration, value can be of any type
  final Object? value;
  final bool hasInverseBoolColors;
  final bool hasBackgroundWhitespaceIndicator;

  const InfoRow({
    required this.label,
    required this.value,
    super.key,
    this.hasInverseBoolColors = false,
    this.hasBackgroundWhitespaceIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      spacing: Constants.spacing8,
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
          shouldInverseBoolColors: hasInverseBoolColors,
          hasBackgroundWhitespaceIndicator: hasBackgroundWhitespaceIndicator,
        ),
      ],
    );
  }
}
