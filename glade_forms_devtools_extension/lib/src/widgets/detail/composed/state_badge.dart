import 'package:flutter/material.dart';

class StateBadge extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final Color color;

  const StateBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: .bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
