import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/glade_forms_extension.dart';

void main() {
  runApp(const GladeFormsDevToolsExtension());
}

class GladeFormsDevToolsExtension extends StatelessWidget {
  const GladeFormsDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const GladeFormsExtensionScreen(),
      ),
    );
  }
}
