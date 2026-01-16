import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// View shown when the DevTools service is not available.
class ServiceUnavailableView extends StatelessWidget {
  final VoidCallback onRetry;

  const ServiceUnavailableView({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            Icons.cloud_off,
            size: Constants.iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: Constants.spacing16),
          Text(
            Constants.serviceUnavailableTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: Constants.spacing8),
          const Padding(
            padding: .symmetric(horizontal: Constants.spacing32),
            child: Text(
              Constants.serviceUnavailableMessage,
              textAlign: .center,
            ),
          ),
          const SizedBox(height: Constants.spacing16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(Constants.retryButton),
          ),
        ],
      ),
    );
  }
}
