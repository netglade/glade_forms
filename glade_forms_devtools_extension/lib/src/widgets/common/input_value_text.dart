import 'package:flutter/material.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

class InputValueText extends StatelessWidget {
  final String stringValue;
  final bool hasBackgroundWhitespaceIndicator;

  const InputValueText({
    required this.stringValue,
    super.key,
    this.hasBackgroundWhitespaceIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (stringValue.isEmpty) {
      return Row(
        mainAxisSize: .min,
        children: [
          ColoredBox(
            color: hasBackgroundWhitespaceIndicator ? Colors.yellow.withAlpha(77) : Colors.transparent,
            child: Text('""', style: textTheme.bodySmall),
          ),
          Text(' (string is empty)', style: textTheme.bodySmall?.italic),
        ],
      );
    }

    return ColoredBox(
      color: hasBackgroundWhitespaceIndicator ? Colors.yellow.withAlpha(77) : Colors.transparent,
      child: Text(stringValue, style: textTheme.bodySmall),
    );
  }
}
