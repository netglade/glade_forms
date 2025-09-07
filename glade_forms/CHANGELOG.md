## 5.0.0

**Breaking change release**

In order to introduce support for warning level validations, several breaking changes were made:
- `GladeInputError` was renamed to `GladeInputValidation` to better reflect its purpose.
- `GladeErrorKeys` was renamed to `GladeValidationsKeys`
- `ErrorTranslator` was renamed to `ValidationTranslator` to align with the new naming conventions
- `devError` parameter in `GladeValidator` methods was renamed to `devMessage` to maintain consistency.
- `translateError` parameter was renamed to `validationTranslate` in both `GladeInput` and `GladeModel` to better represent its functionality.
- `DefaultTranslations` was renamed to `DefaultValidationTranslations` to clarify its role in the validation process.
- Rename `defaultErrorTranslate` to `defaultValidationTranslate` in `GladeModel` for consistency with other renamings.

New features:
- `GladeInputValidation` now includes an `errorSeverity` property, which can be either `error` or `warning`.
- The `GladeValidator` class was updated to support warning level validations.
- The `GladeInput` class was modified to handle warning level validations appropriately
- The `GladeModel` class was also updated to manage warning level validations effectively.

## 4.2.0
- Upgrade dependencies
- Upgrade to Flutter SDK 3.35.0
- Change constraint to Dart sdk: ">=3.8.0 <4.0.0"

## 4.1.2
- **[Add]**: Add `metaData` to `SatisfyPredicatePart` and `GladeValidator.satisfyPredicate()` to allow passing additional data.
- **[Add]**: Add `getMaxLength()` intto `GladeStringInput` to get maximum length of the string if `maxLength()` standard validator is used.

## 4.0.2
- **[Fix]**: Fix `ValueTransform` in nullable type does not allow null values.

## 4.0.1
- Fix `input.updateValue` `shouldTriggerOnChange` parameter, so now next updates already trigger `onChange`.
  - Add tests.
- Fix code so it is valid Dart 3.6.0 (Flutter 3.27).

## 4.0.0

**Breaking change release**

- Specialized versions of inputs such as `IntInput` or `StringInput` were renamed to `Glade*Input`.
- Removed specialized version factories. Now specialized versions are sub-classes of GladeInput
  - This removes the weird possibility to create calls such as `StringInput.intInput()` which in the end threw a runtime exception due to type mismatch.
- Renamed `valueConverter` in `create()` factory to match internal name `stringToValueConverter` which is more explicit
- Rename `resetToPure()` to `resetToInitialValue()`
- Change `setAsNewPure` to `setNewInitialValue()`
  - Updates input to new initial value
  - Optionally input's value can be reset into new initial value (`shouldResetToInitialValue` argument).
- On Model level
  - Rename `resetToPure()` to `resetToInitialValue()`
  - Change `setAsNewPure` to `setInputValuesAsNewInitialValues()`
    - Updates all inputs to new initial value
    - Optionally input's value can be reset into new initial value (`shouldResetToInitialValue` argument).
- Rename `GladeModelDebugInfo` to `GladeFormDebugInfo` to align with other widgets.
- Rename `GadeModelDebugInfoModal` to `GladeFormDebugInfoModal`.
- Rename ValidatorResult.`isInvalid` to `isNotValid` to align  with properties in GladeInput and GladeModel.
  
- **Added** `setNewInitialValueAsCurrentValue` method as shorthand for setting new initial value as current input's value.
- **Added** `GladeDateTimeInput` - specialized GladeInput for DateTime inputs.
- **Added** `inclusive` argument for `int` validations.
- `GladeIntInput` and `GladeDateTimeInput` offer *Nullable versions to support null values
  - `StringInput` does not offer a nullable version as we believe that in most cases you don't really need to differentiate between a null string and an empty string. Feel free to open an issue if you disagree.
- **Added** Add `isPositive()` and `isNegative()` to Int validator.
- **Added** Add `validationErrors` getter as shorthand for getting input's error
- **Added** Add several extension methods on List of GladeInputError such as `hasErrorKey()`.
- **Fixed** Input did not propagate initialValue into TextEditingController.
- **Fixed** Fix nullability value in `devError` callback in validator.



## 3.1.1
- Add typedefs `IntInput` and `BooleanInput`
- Fix GladeModelDebugInfo colors in DarkMode.

## 3.1.0
- updated dependencies

## 3.0.1
- **[Fix]**: GladeFormProvider is missing key property [Fix 73](https://github.com/netglade/glade_forms/issues/73)
- **[Fix]**: enable value transform with text editing controller [Fix 72](https://github.com/netglade/glade_forms/issues/72)
- **[Fix]**: Input subscribed to its own changes in onDependencyChange [Fix 76](https://github.com/netglade/glade_forms/issues/76)


## 3.0.0

**Breaking change release**

- **[Add]**: Add `allowBlank` parameter to `isEmpty` string validator.
- **[Add]**: Add `IntInput` as a specialized variant of GladeInput<int> which has additional, int related, validations such as `isBetween`, `isMin`, `isMax`
- **[Add]**: Support skipping particular validation with `shouldValidate` callback.
- **[Breaking]**: The `resetToPure` method on both GladeInput and GladeModel has been renamed to `setAsNewPure`. This change better reflects the method's behavior of setting a new pure state rather than resetting to the original state.
- **[Add]**: New `resetToPure` method added to both GladeInput and GladeModel. This method truly resets the input(s) to their initial value(s) and marks them as pure.

## 2.3.0
- RETRACTED version, should be 3.0.0

## 2.2.0
- **[Add]**: Add `resetToPure` on model level.

## 2.1.0
- **[Add]**: Add `defaultTranslateError` on model level.

## 2.0.1
- **[Fix]**: Fix `isUri()` to handle URL corectly

## 2.0.0
- **[Breaking]**: TextEditingController is no more created automatically. When TextEditingController is used, input's behavior is slightly changed. See README.md for full info.
- **[Breaking]**: GladeInput's controller is now private. Use factory constructors to create input.
- **[Breaking]**: `Extra` parameter removed
- **[Breaking]**: `dependencies` are no longer passed into `onChange` and in validator.
- **[Breaking]**: GladeInput is no longer ChangeNotifier
- **[Add]**: onDependencyChange - callback is called when any (or multiple with groupEdit()) dependency was udpated.
- **Improvement**: GladeModelDebugInfo now colorize String values to visualize whitespace.

## 1.6.0
- **Improvement**: GladeModelDebugInfo is more colorful and polished.
- **Improvement**: Support deep collection equality when comparing `value` and `initialValue`.
- **[Feat]**: `allInputs` getter to support "dynamic" model's inputs validation.

## 1.5.0
- **[Feat]**: Add `updateWhenNotNull` to support shorthand syntax for Widgets with nullable type parameter.

## 1.4.0
- **[Feat]**: Support non-data-holding inputs to enable "view" inputs.
- **[Feat]**: Add the `shouldTriggerOnChange` parameter to `updateValue` so one can opt-out from `onChange` callback being triggered.
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
