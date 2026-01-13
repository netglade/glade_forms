# DevTools Extension Development

## Debug Mode

The extension supports a special DEBUG mode for rapid UI development without needing a running app.

### How to Enable Debug Mode

#### VS Code
Use the launch configuration **"devtools_extension (DEBUG MODE)"** from the Run and Debug panel.

#### Command Line
```bash
cd glade_forms_devtools_extension
flutter run -d chrome --dart-define=DEBUG_MODE=true --dart-define=use_simulated_environment=true
```

### Features

When DEBUG mode is enabled:

- **Mock Data**: The extension loads mock data instead of connecting to a real app
- **Scenario Switcher**: A science beaker icon appears in the AppBar allowing you to switch between different scenarios:
  - **No Models**: Empty state (no forms)
  - **Single Model**: A single `UserProfileForm` with various input types
  - **Composed Model**: An `OrderCheckoutForm` with 3 child models:
    - BillingAddressForm (valid, modified)
    - ShippingAddressForm (invalid - missing street)
    - PaymentMethodForm (valid, pristine)
  - **Multiple Models**: Mix of single and composed models
- **Visual Indicator**: Orange "DEBUG" badge in the AppBar

### Mock Data Structure

Mock data is defined in [`lib/src/debug/mock_data.dart`](lib/src/debug/mock_data.dart):

- **FormInputData**: Includes various input states (valid, invalid, dirty, pristine)
- **ChildModelData**: For testing composed model tree views
- **Different validation states**: To test error/warning display

### Development Workflow

1. Launch extension in DEBUG mode
2. Use scenario switcher to test different UI states
3. Make UI changes with hot reload enabled
4. Switch scenarios to verify changes across different states
5. Build extension when ready: `melos run build:extension`

### Testing with Real Data

To test with a real app:

1. Run the storybook app: `cd storybook && flutter run -d chrome`
2. Open DevTools from the running app
3. Navigate to the "Glade Forms" tab

Or use the simulated environment with a real app connection (remove `DEBUG_MODE` flag):

```bash
flutter run -d chrome --dart-define=use_simulated_environment=true
```

Then paste the VM service URI into the simulated environment's input field.
