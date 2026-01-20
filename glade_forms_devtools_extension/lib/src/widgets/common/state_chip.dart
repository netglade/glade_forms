import 'package:flutter/material.dart';

/// A universal chip widget for displaying state labels with colors.
/// Can be styled as a badge, mini chip, or bordered chip.
class StateChip extends StatelessWidget {
  final String label;
  final Color color;

  const StateChip({required this.label, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: const .all(.circular(12)),
        border: .all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: .w600,
        ),
      ),
    );
  }
}
