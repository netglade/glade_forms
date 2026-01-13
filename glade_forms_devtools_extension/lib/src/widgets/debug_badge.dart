import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// Badge shown in debug mode.
class DebugBadge extends StatelessWidget {
  const DebugBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GladeFormsConstants.spacing8,
        vertical: GladeFormsConstants.spacing4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(GladeFormsConstants.spacing4),
      ),
      child: const Text(
        GladeFormsConstants.debugBadge,
        style: TextStyle(
          fontSize: GladeFormsConstants.debugBadgeFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
