# DevTools Extension Tests

This directory contains tests for the DevTools extension integration.

## Test Coverage

### Configuration Tests (`devtools_extension_test.dart`)
Tests the configuration files and directory structure:
- Verifies `devtools_options.yaml` exists and is valid
- Validates `extension/config.yaml` structure and required fields
- Checks that extension paths are correctly configured
- Ensures directory structure is in place
- Validates documentation exists

### Widget Tests (`extension_widget_test.dart`) - Extension Package
Tests the extension UI:
- Verifies the extension app builds successfully
- Tests that feature descriptions are displayed
- Validates branding and messaging

### Package Configuration Tests (`package_config_test.dart`) - Extension Package
Tests the extension package setup:
- Validates pubspec.yaml configuration
- Checks required dependencies are present
- Verifies SDK constraints are correct
- Ensures entry points exist (main.dart, index.html)
- Validates documentation

## Running Tests

### Main Package Tests
```bash
cd glade_forms
flutter test test/devtools_extension_test.dart
```

### Extension Package Tests
```bash
cd glade_forms_devtools_extension
flutter test
```

### All Tests (via Melos)
```bash
# From repository root
melos run test
```

## Test Philosophy

These tests focus on:
1. **Configuration validation** - Ensuring all config files are correct
2. **Structure validation** - Verifying directory structure is as expected
3. **Basic UI tests** - Ensuring the extension app builds and displays correctly

Note: Full integration testing of the extension with DevTools and a running app requires manual testing in a real Flutter development environment.

## Adding New Tests

When adding features to the extension:
1. Add widget tests for new UI components
2. Update configuration tests if structure changes
3. Document test coverage in this file
