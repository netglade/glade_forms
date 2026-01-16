import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class ComposedChildModelInputSummary extends StatelessWidget {
  final GladeInputDescription input;

  const ComposedChildModelInputSummary({required this.input, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const .only(bottom: 4),
      padding: const .all(8),
      decoration: BoxDecoration(
        color: input.isValid
            ? Constants.validColor.withAlpha((0.2 * 255).toInt())
            : Constants.invalidColor.withAlpha((0.2 * 255).toInt()),
        borderRadius: const .all(.circular(4)),
        border: .all(
          color: input.isValid
              ? Constants.validColor.withAlpha((0.2 * 255).toInt())
              : Constants.invalidColor.withAlpha((0.2 * 255).toInt()),
        ),
      ),
      child: Row(
        spacing: Constants.spacing8,
        children: [
          Icon(
            input.isValid ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: input.isValid ? Constants.validColor : Constants.invalidColor,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(input.key, style: theme.textTheme.bodySmall?.bold),
                InputValue(
                  value: input.value,
                  hasBackgroundWhitespaceIndicator: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
