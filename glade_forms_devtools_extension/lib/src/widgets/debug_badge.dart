import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// Badge shown in debug mode.
class DebugBadge extends StatelessWidget {
  const DebugBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(
        horizontal: Constants.spacing8,
        vertical: Constants.spacing4,
      ),
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: .all(.circular(Constants.spacing4)),
      ),
      child: const Text(
        Constants.debugBadge,
        style: TextStyle(
          fontSize: Constants.debugBadgeFontSize,
          fontWeight: .bold,
        ),
      ),
    );
  }
}
