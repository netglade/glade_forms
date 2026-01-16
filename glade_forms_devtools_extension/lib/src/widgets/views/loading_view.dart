import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';

/// Loading indicator shown while fetching models.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: .center,
        spacing: Constants.spacing16,
        children: [
          CircularProgressIndicator(),
          Text(Constants.loadingMessage),
        ],
      ),
    );
  }
}
