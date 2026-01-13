import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// View shown when the DevTools service is not available.
class ServiceUnavailableView extends StatelessWidget {
  final VoidCallback onRetry;

  const ServiceUnavailableView({
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: GladeFormsConstants.iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: GladeFormsConstants.spacing16),
          Text(
            GladeFormsConstants.serviceUnavailableTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: GladeFormsConstants.spacing8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: GladeFormsConstants.spacing32),
            child: Text(
              GladeFormsConstants.serviceUnavailableMessage,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: GladeFormsConstants.spacing16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(GladeFormsConstants.retryButton),
          ),
        ],
      ),
    );
  }
}
