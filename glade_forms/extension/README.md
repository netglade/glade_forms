# DevTools Extension

This directory contains the configuration and build output for the glade_forms DevTools extension.

## Structure

- `devtools/config.yaml` - Extension configuration for Flutter DevTools
- `devtools/build/` - Built extension output (copied from glade_forms_devtools_extension package)
- `devtools/.pubignore` - Ensures build directory is included when publishing despite being gitignored

## Building the Extension

The extension source code is maintained in the separate `glade_forms_devtools_extension` package at the root of this repository.

To build the extension:

```bash
# From the repository root
melos run build:extension
```

This will:
1. Build the extension package
2. Copy the build output to `extension/devtools/build/`

## Development

For development of the extension itself, work in the `glade_forms_devtools_extension` package.

See the [glade_forms_devtools_extension README](../../glade_forms_devtools_extension/README.md) for more information.
