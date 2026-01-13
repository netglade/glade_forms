import 'package:flutter/material.dart';

class InputValueText extends StatelessWidget {
  final String stringValue;
  final bool hasBackgroundWhitespaceIndicator;

  const InputValueText({
    super.key,
    required this.stringValue,
    this.hasBackgroundWhitespaceIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: hasBackgroundWhitespaceIndicator ? Colors.yellow.withAlpha(77) : Colors.transparent,
      child: Text(stringValue, style: textTheme.bodySmall),
    );
  }
}
