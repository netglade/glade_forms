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

## Structure

This follows the pattern used by other Flutter packages with DevTools extensions:
- Extension source code is in a separate package
- Built output is copied to the main package's `extension/devtools/build/` directory
- Main package includes only the built extension, not the source

## Learn More

- [Flutter DevTools Extensions](https://docs.flutter.dev/tools/devtools/extensions)
- [glade_forms package](https://pub.dev/packages/glade_forms)

