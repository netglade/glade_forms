import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_input_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';

class ComposedChildModelInputSummary extends StatelessWidget {
  final GladeInputDescription input;

  const ComposedChildModelInputSummary({required this.input});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: input.isValid
            ? GladeFormsConstants.validColor.withAlpha((0.2 * 255).toInt())
            : GladeFormsConstants.invalidColor.withAlpha((0.2 * 255).toInt()),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: input.isValid
              ? GladeFormsConstants.validColor.withAlpha((0.2 * 255).toInt())
              : GladeFormsConstants.invalidColor.withAlpha((0.2 * 255).toInt()),
        ),
      ),
      child: Row(
        children: [
          Icon(
            input.isValid ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: input.isValid ? GladeFormsConstants.validColor : GladeFormsConstants.invalidColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  input.key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InputValue(value: input.value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
