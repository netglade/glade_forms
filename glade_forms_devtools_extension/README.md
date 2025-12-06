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

This follows the pattern used by other Flutter packages with DevTools extensions (like `drift` and `provider`):
- Extension source code is in a separate package
- Built output is copied to the main package's `extension/devtools/build/` directory
- Main package includes only the built extension, not the source

### Why a Separate Package?

**Pros:**
1. **Independent versioning** - Extension can be updated without releasing the main package
2. **Smaller package size** - Main package doesn't include extension source code, only build output
3. **Cleaner separation** - Extension dependencies (like `devtools_extensions`) don't affect main package users
4. **Independent development** - Extension has its own CI/CD, testing, and release cycle
5. **Better workspace management** - Clear separation in monorepo structure

**Cons:**
1. **Build step required** - Must run build script to update extension in main package
2. **More files to maintain** - Two packages instead of one

The separate package approach is the standard pattern for DevTools extensions and provides better maintainability.

## Learn More

- [Flutter DevTools Extensions](https://docs.flutter.dev/tools/devtools/extensions)
- [glade_forms package](https://pub.dev/packages/glade_forms)

