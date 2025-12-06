# DevTools Extension - Build Instructions

## Overview

The glade_forms DevTools extension is maintained as a separate package (`glade_forms_devtools_extension`) and the build output is copied to `glade_forms/extension/devtools/build/`.

## Building Locally

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Melos (for workspace management)

### Build Steps

1. From the repository root:
```bash
melos run build:extension
```

This will:
- Navigate to `glade_forms_devtools_extension`
- Run `flutter build web --wasm --release`
- Copy `build/web/` to `glade_forms/extension/devtools/build/`

2. Or manually:
```bash
cd glade_forms_devtools_extension
flutter pub get
flutter build web --wasm --release
rm -rf ../glade_forms/extension/devtools/build
cp -r build/web ../glade_forms/extension/devtools/build
```

### Development Mode

To develop the extension:
```bash
cd glade_forms_devtools_extension
flutter pub get
flutter run -d chrome
```

## CI/CD Integration

The extension should be built as part of the release process:

1. When releasing a new version of glade_forms
2. Run `melos run build:extension`
3. Commit the updated build output in `glade_forms/extension/devtools/build/`
4. Publish the package

## Testing the Extension

1. Create a Flutter app that uses glade_forms
2. Run the app in debug mode
3. Open Flutter DevTools
4. The "Glade Forms" tab should appear in DevTools
5. Interact with forms in your app to see live updates

## Structure

```
glade_forms_workspace/
├── glade_forms/
│   ├── lib/
│   ├── extension/
│   │   ├── config.yaml          # Extension configuration
│   │   └── devtools/
│   │       └── build/           # Built extension output (copied from extension package)
│   └── pubspec.yaml
└── glade_forms_devtools_extension/
    ├── lib/
    │   ├── main.dart            # Extension entry point
    │   └── src/
    │       └── glade_forms_extension.dart
    ├── web/
    │   └── index.html
    └── pubspec.yaml
```

## Updating the Extension

1. Make changes in `glade_forms_devtools_extension/`
2. Test with `flutter run -d chrome`
3. Build with `melos run build:extension`
4. Commit both source and build output changes
5. The updated extension will be included in the next package release

## Troubleshooting

**Extension doesn't appear in DevTools:**
- Ensure `glade_forms/extension/config.yaml` exists
- Verify build output exists in `glade_forms/extension/devtools/build/`
- Check that the app imports `glade_forms`

**Build fails:**
- Ensure Flutter SDK is up to date
- Run `flutter pub get` in the extension directory
- Check for dependency conflicts

**Extension shows blank page:**
- Verify `web/index.html` exists
- Check browser console for errors
- Ensure `main.dart` is compiled correctly
