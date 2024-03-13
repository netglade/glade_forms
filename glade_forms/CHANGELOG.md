## 1.4.0
- **[Feat]**: Support non-data-holding inputs to enable "view" inputs.
- **[Feat]**: Add the `shouldTriggerOnChange` paramete to `updateValue` so one can opt-out from `onChange` callback being triggered.
- **[Fix]**: Export `ChangesInfo`.

## 1.3.2
- **[Fix]**: `GladeInput` now preserves selection. (Before, a cursor jumped at the end.)

## 1.3.1
- **[Fix]**: Fixed `GladeInput.create` assert to allow null for `value` and `initialValue` when input's type is nullable.

## 1.3.0
- **[Fix]**: When using `GladeInput.create`, passing only `value` ended up in UI vs model not being synced. Now that's fixed.
- **[Breaking]**: StringInput only works with `String` now.

## 1.2.1
- **[Fix]**: Value passed to factory constructor is not reflected in TextController.

## 1.2.0
- **[Feat]**: Add `GladeFormListener` widget allowing to listen for model's changes
- **[Feat]**: Add `groupEdit()` method in GladeModel allows to update multiple inputs at once.
  - Works great with `GladeFormListener`
- **[Feat]**: Add `valueTransform` in GladeInput. Transform value before it is assigned into value.
  - Firstly `stringToTypeConverter` is called if needed, then `valueTransform`.
- **[Feat]**: Add `updateValue(T value)` as shorthand for inputs when field is not TextField.
- **[Feat]**: Add `resetToPure` method allowing to reset input into pure state.
- **[Fix]**: Conversion error does not update model's stats and formatted errors.

## 1.1.2
- Fix links in readme

## 1.1.1
- Improve Readme

## 1.1.0
- **[Feat]**: Add `onChange` 
  - support for listening changes and potentially update other inputs based on change
- **[Feat]**: GladeInput exports TextEditingController now for connecting it with FormField properly
- **[Breaking]**: StringInput is now alias. Use `GladeInput.stringInput` to create string variant

## 1.0.1

- Fix example

## 1.0.0

- Initial version.
