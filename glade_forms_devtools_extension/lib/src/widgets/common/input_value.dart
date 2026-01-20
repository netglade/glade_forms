import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value_text.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class InputValue extends StatelessWidget {
  // ignore: no-object-declaration, value can be of any type
  final Object? value;
  final bool shouldInverseBoolColors;
  final bool hasBackgroundWhitespaceIndicator;

  const InputValue({
    required this.value,
    super.key,
    this.shouldInverseBoolColors = false,
    this.hasBackgroundWhitespaceIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (value == null) {
      return Text('null', style: textTheme.bodySmall?.semiBold);
    }

    // ignore: prefer-boolean-prefixes, ok naming
    if (value case final bool boolValue) {
      final color = shouldInverseBoolColors
          ? (boolValue ? Constants.invalidColor : Constants.validColor)
          : (boolValue ? Constants.validColor : Constants.invalidColor);

      return Text(
        boolValue.toString(),
        style: textTheme.bodySmall?.withColor(color),
      );
    }

    if (value case final String stringValue) {
      return InputValueText(
        stringValue: stringValue,
        hasBackgroundWhitespaceIndicator: hasBackgroundWhitespaceIndicator,
      );
    }

    // ignore: avoid-non-null-assertion, checked above
    return Text(value!.toString());
  }
}
