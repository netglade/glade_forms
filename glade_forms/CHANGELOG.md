## Unreleased
- **[Add]**: `GladeComposedModel` can have inputs of its own, next to the models it contains ([#106](https://github.com/netglade/glade_forms/issues/106)).
  - Declare them as on `GladeModel` - create the inputs in `initialize()` and list them in `inputs`. Overriding `initialize()` is optional for a composed model.
  - Own inputs are aggregated **together with** the contained models into `isValid`, `isValidWithoutWarnings`, `isPure`, `isUnchanged` and `validatorResults`. A composed model without own inputs behaves exactly as before.
  - `resetToInitialValue()` and `setInputValuesAsNewInitialValues()` on a composed model reach its own inputs and every contained model.
  - Composed-level inputs and inputs of contained models do **not** observe each other - neither direction of a cross-level dependency is notified. See the docs.
  - **Beware**: `GladeComposedModel` newly inherits these members, so a same-named member in your subclass is now an override: `inputs`, `allInputs`, `initialize`, `bindToModel`, `updateInput`, `stringFieldUpdateInput`, `groupEdit`, `isGroupEditing`, `notifyDependencies`, `resetToInitialValue`, `setInputValuesAsNewInitialValues`, `fillDebugMetadata`, `hasDebugMetadata`, `formattedValidationErrors`, `formattedValidationErrorsAndWarnings`, `debugFormattedValidationErrors`, `defaultValidationTranslate`.
    - A member whose signature is not a valid override is a compile error, so you will see it. Two shapes are silent and deserve a check:
    - A method named `initialize()` (including `Future<void> initialize()`, which is a valid override) now overrides the new hook and is invoked from the constructor - rename it, or call `super.initialize()` last.
    - A getter named `inputs` returning a flattened list of contained models' inputs is now an override of the own-inputs contract, and `addModel()` will assert. List only the composed model's own inputs.
- **[Add]**: New `GladeInputsOwner` mixin carries the input ownership shared by `GladeModel` and `GladeComposedModel`. Every member remains available on both classes with an unchanged signature; only `GladeInput.bindToModel` (`@internal`) accepts the mixin instead of `GladeModel`.
  - `GladeFormDebugInfo` and `GladeFormDebugInfoModal.show` are bound to `GladeInputsOwner`, so they accept a composed model as well. `GladeFormDebugInfo` also shows how many models a composed model contains and how many of them are not valid.
- **[Add]**: DevTools extension displays composed model's own inputs and counts them next to its child models.
- **[Add]**: Export `ValidatorResult` - it is the element type of the public `validatorResults`, `GladeInput.validatorResult`, `GladeInput.validate()` and `ChangesInfo.validatorResult`, but could not be named by a consumer.
- **[Fix]**: `lastUpdates` on a composed model no longer re-broadcasts keys of the previous own-input update when a contained model changes or a model is attached or detached - it is empty for those notifications.
- **[Fix]**: `groupEdit()` no longer leaks keys of an update which preceded the batch, so dependencies of inputs which did not change within the batch are not notified anymore.
  - A notification raised by a contained model during a composed model's `groupEdit()` is folded into the single notification the batch emits at its end. Previously it broke the batch in two and dropped the accumulated keys.
  - A nested `groupEdit()` is part of the batch which is already running: it no longer flushes on its own, so one batch notifies exactly once instead of once per nesting level.
  - Group edit mode is always left and the batch is always flushed, even when the callback throws.
- **[Fix]**: DevTools serializer produced the key `depedencies`, so an input's dependencies were never displayed in the extension.
- **[Fix]**: DevTools serializer wrote `initialValue` unencoded, so a single input whose value is not a JSON primitive (e.g. `GladeDateTimeInput`) made the whole response fail to encode and **every** model disappeared from the inspector.
- **[Fix]**: `GladeFormDebugInfoModal.show()` did not pass its type argument to the `GladeFormDebugInfo` it builds, so the widget looked up its own bound instead of the model given to it and always threw `ProviderNotFoundException`.
- **[Fix]**: `lastUpdates` is no longer cleared by a nested notification raised while the model is delivering its own update - e.g. when an `onDependencyChange` callback updates a contained model.
- **[Fix]**: DevTools extension failed to parse any model which has at least one input - decoded JSON lists were cast directly to `List<String>`, which throws even for an empty list.
- **[Fix]**: Own inputs of a composed model are disposed after its contained models are detached and after it detaches from its parent composed models, because both notify synchronously and their listeners may still read those inputs. The disposal can no longer be skipped by a throw.
  - A contained model which throws while being disposed no longer stops the disposal of the remaining models - every model is disposed and the collection is cleared, then the first failure is rethrown.
- **[Fix]**: A model rejected by `addModel()` (it shares an input with the composed model) is detached again before the assert fails, so it is never left half attached and driving the composed model.
- **[Add]**: `GladeModelBase.isDisposed` tells whether the model was already disposed.
- Asserts were added for input ownership: an input can be binded to one model only, an input can not be updated through a model which does not own it, and a composed model can not share an input with a contained model.
  - An input which outlived its model - one the model never listed, so it was not disposed with it - can be binded to a new model once the previous owner is disposed.
  - A **disposed** input can not be binded at all: its `TextEditingController` is gone, so the new model would get a dead input.

## 6.1.0
- **[Add]**: `GladeComposedModel.addModel()` and `removeModel()` accept `shouldNotify` parameter ([#104](https://github.com/netglade/glade_forms/issues/104)).
  - Pass `shouldNotify: false` to attach or detach a model without notifying listeners - e.g. when a model is added during widget's build phase.
  - Models passed into `GladeComposedModel`'s constructor no longer trigger notification.
- **[Fix]**: `GladeInput` now disposes its `TextEditingController` when the input is disposed ([#102](https://github.com/netglade/glade_forms/issues/102)).
  - Externally provided controller (via `textEditingController` parameter) is **not** disposed - its owner stays responsible for it.
  - Repeated `dispose()` calls are no-op. New `GladeInput.isDisposed` getter tells whether the input was already disposed.
- **[Fix]**: `GladeModel.dispose()` now disposes all its inputs (`allInputs`).
  - Be aware that after model's disposal its inputs (and their controllers) must not be used anymore.

## 6.0.1
- **[Fix]**: `RegexPatterns.email` now accepts plus-aliases (e.g. `user+tag@gmail.com`) and TLDs longer than 4 characters (e.g. `.online`, `.software`). TLD is now restricted to letters only.

## 6.0.0
- **Breaking**: Upgrade to Flutter SDK 3.38.0
  - Change constraint to Dart sdk: ">=3.8.0"
- **Breaking**: You need to call `GladeForms.initialize()` in order to use Glade Forms DevTools extension.
  - This is required to setup DevTools extension properly.
  - Can be called only in debug mode, but does nothing in release mode.
- **[Add]**: Add **DevTools** extension!
  - Allows to inspect Glade Forms models in Flutter DevTools
- **[Add]**: Add `debugKey` property for developer friendly unique identification of models.
  - `debugKey` is a string that identifies the model in a human-readable way.

## 5.1.0
- **[Add]**: Add `GladeComposedModel` to allow multi-forms creation
- **[Add]**: Add `ComposedExample` to demonstrate `GladeComposedModel` functionality
- **[Add]**: Add `NestedComposedExample` to demonstrate nested `GladeComposedModel` functionality
- **[Add]**: Add `GladeModel.fillDebugMetadata()` method to provide debug metadata as key-value pairs.
  - This metadata is displayed in `GladeModelDebugInfo` widget.

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
