import 'dart:io';

import 'package:flutter/material.dart';

class WidgetExample extends StatelessWidget {
  final Widget child;
  final bool supportsWebOrDesktop;

  const WidgetExample({
    required this.child,
    Key? key,
    this.supportsWebOrDesktop = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (supportsWebOrDesktop || isMobile) {
      return Padding(padding: const EdgeInsets.all(25), child: child);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.warning, color: Colors.yellow, size: 30),
        const Text('This widget does not fully support web or desktop environment.'),
        const SizedBox(height: 30),
        Padding(padding: const EdgeInsets.all(25), child: child),
      ],
    );
  }
}
