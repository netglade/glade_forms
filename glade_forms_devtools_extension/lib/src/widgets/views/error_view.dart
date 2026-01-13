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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: GladeFormsConstants.iconSize,
            color: Colors.red,
          ),
          const SizedBox(height: GladeFormsConstants.spacing16),
          Text(
            GladeFormsConstants.errorTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: GladeFormsConstants.spacing8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GladeFormsConstants.spacing32),
            child: Text(
              errorMessage,
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
