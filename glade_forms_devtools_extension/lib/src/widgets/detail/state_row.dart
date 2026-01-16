import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/widgets/common/input_value.dart';

class StateRow extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;

  const StateRow({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: value ? Constants.validColor : Constants.invalidColor,
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        InputValue(value: value),
      ],
    );
  }
}
