import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/devtools/devtools_registry.dart';

/// Main API for Glade Forms package.
// ignore: prefer-match-file-name, keep name as is
abstract final class GladeForms {
  /// Initialize the Glade Forms package.
  ///
  /// This must be called in your app's main() method before creating any GladeModel instances.
  /// It sets up DevTools integration so the Glade Forms Inspector is available immediately.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   GladeForms.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  static void initialize() {
    if (kDebugMode) GladeFormsDevToolsRegistry.initialize();
  }
}
