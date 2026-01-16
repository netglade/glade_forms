import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// View shown when an error occurs.
class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({
    required this.errorMessage,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const Icon(
            Icons.error_outline,
            size: Constants.iconSize,
            color: Colors.red,
          ),
          const SizedBox(height: Constants.spacing16),
          Text(Constants.errorTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Constants.spacing8),
          Padding(
            padding: const .symmetric(horizontal: Constants.spacing32),
            child: Text(errorMessage, textAlign: .center),
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
