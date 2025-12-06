# DevTools Extension Build Output

This directory should contain the built DevTools extension.

To build the extension, run:
```bash
melos run build:extension
```

Or see [BUILD_EXTENSION.md](../../../BUILD_EXTENSION.md) for detailed instructions.

The build process will populate this directory with:
- `index.html` - Main HTML file
- `main.dart.js` - Compiled Dart code
- `flutter.js` - Flutter web runtime
- Other assets and resources

**Note:** This directory should contain the build output from `glade_forms_devtools_extension/build/web/`
