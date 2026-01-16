// ignore_for_file: avoid-adjacent-strings

import 'dart:ui';

/// Constants used throughout the GladeForms DevTools extension.
abstract final class Constants {
  // Layout
  static const double sidebarWidth = 300;

  static const double iconSize = 64;
  static const double smallIconSize = 20; // Spacing
  static const double spacing4 = 4;

  static const double spacing8 = 8;
  static const double spacing16 = 16;
  static const double spacing32 = 32; // Font sizes
  static const double debugBadgeFontSize = 12;

  // Timing
  static const Duration refreshInterval = Duration(seconds: 2);

  // Colors - State indicators
  static const Color validColor = Color(0xFF4CAF50); // Green

  static const Color invalidColor = Color(0xFFF44336); // Red
  static const Color pureColor = Color(0xFF2196F3); // Blue
  static const Color dirtyColor = Color(0xFFFF9800); // Orange
  static const Color unchangedColor = Color(0xFF9E9E9E); // Grey
  static const Color modifiedColor = Color(0xFF9C27B0); // Purple
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color successColor = Color(0xFF4CAF50); // Green

  static const String appTitle = 'Glade Forms Inspector';

  static const String debugBadge = 'DEBUG';
  static const String noModelsTitle = 'No Active Forms';
  static const String noModelsMessage =
      'No GladeModel instances are currently active in your app.\n\n'
      'Navigate to a screen with forms to see them here.';
  static const String serviceUnavailableTitle = 'Service Not Available';
  static const String serviceUnavailableMessage =
      'The glade_forms DevTools service is not available.\n\n'
      'Make sure your app is running and using glade_forms.';
  static const String selectModelMessage = 'Select a model to view details';
  static const String errorTitle = 'Error';
  static const String retryButton = 'Retry';
  static const String loadingMessage = 'Loading...';
  static const String refreshTooltip = 'Refresh';
  static const String scenarioTooltip = 'Select Mock Scenario';

  const Constants._();
}
