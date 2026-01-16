# Glade Forms DevTools Extension

This is a Flutter DevTools extension for the `glade_forms` package.

This is a separate package that gets built and copied into the `glade_forms/extension/devtools/build/` directory.

## Features

- View active GladeModel instances in your application
- Inspect input values and validation states
- Monitor form dirty/pure states
- Real-time updates as forms change

## Building

To build the extension:

```bash
# From the repository root
melos run build:extension
```

Or manually:

```bash
# From this directory
flutter build web --wasm --release
# Then copy build/web/ to ../glade_forms/extension/devtools/build/
```

The built extension will be output to `build/web/` and should be copied to the main package's extension directory.

## Development

For development, you can run:

```bash
flutter run -d chrome
```

or run devtools_extension (DEBUG MODE) launch configuration in VS Code.