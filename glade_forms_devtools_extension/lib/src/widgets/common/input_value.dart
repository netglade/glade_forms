import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value_text.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class InputValue extends StatelessWidget {
  final Object? value;
  final bool inverseBoolColors;
  final bool hasBackgroundWhitespaceIndicator;

  const InputValue({
    super.key,
    required this.value,
    this.inverseBoolColors = false,
    this.hasBackgroundWhitespaceIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (value == null) {
      return const Text('null');
    }

    if (value is bool) {
      final color = inverseBoolColors
          ? (value == true ? GladeFormsConstants.invalidColor : GladeFormsConstants.validColor)
          : (value == true ? GladeFormsConstants.validColor : GladeFormsConstants.invalidColor);

      return Text(value.toString(), style: textTheme.bodySmall?.withColor(color));
    }

    if (value is String) {
      return InputValueText(
        stringValue: value.toString(),
        hasBackgroundWhitespaceIndicator: hasBackgroundWhitespaceIndicator,
      );
    }

    return Text(value.toString());
  }
}
