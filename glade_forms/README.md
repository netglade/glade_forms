<a href="https://github.com/netglade">
    <img alt="netglade" height='120px' src="https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/badge.png">  
</a>

Developed with 💚 by [netglade][netglade_link]

[![ci][ci_badge]][ci_badge_link]
[![glade_forms][glade_forms_pub_badge]][glade_forms_pub_badge_link]
[![license: MIT][license_badge]][license_badge_link]
[![style: netglade analysis][style_badge]][style_badge_link]
[![Discord][discord_badge]][discord_badge_link]

---

A universal way to define form validators with support of translations.

- [👀 What is this?](#-what-is-this)
- [🚀 Getting started](#-getting-started)
- [✨ Features](#-features)
  - [GladeInput](#gladeinput)
  - [String based input and TextEditingController](#string-based-input-and-texteditingcontroller)
    - [StringInput](#stringinput)
  - [Validation](#validation)
  - [Skipping Specific Validation](#skipping-specific-validation)
    - [Using validators without GladeInput](#using-validators-without-gladeinput)
  - [GladeModel](#glademodel)
    - [Inputs](#inputs)
    - [Flutter widgets](#flutter-widgets)
    - [Edit multiple inputs at once](#edit-multiple-inputs-at-once)
  - [Dependencies](#dependencies)
  - [Controlling other inputs](#controlling-other-inputs)
  - [Translation](#translation)
    - [Default translations](#default-translations)
  - [Converters](#converters)
  - [Debugging](#debugging)
- [👏 Contributing](#-contributing)

## 👀 What is this?

Glade Forms offer unified way to define reusable form inputs
with support of fluent API to define input's validators
and with support of translation on top of that.

Mannaging forms in Flutter is... hard.
With Glade Forms you create a model that holds glade inputs,
setup validation, translation, dependencies, handling of updates,
and more with ease.

[📖 Glade Forms Widgetbook][storybook_demo_link] 

## 🚀 Getting started

To start,
setup a Model class that holds glade inputs together.

```dart
class _Model extends GladeModel {
  late GladeInput<String> name;
  late GladeInput<int> age;
  late GladeInput<String> email;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email];

  @override
  void initialize() {
    name = GladeInput.stringInput();
    age = GladeInput.intInput(value: 0, useTextEditingController: true);
    email = GladeInput.stringInput(validator: (validator) => (validator..isEmail()).build());

    super.initialize();
  }
}
```

Then use `GladeFormBuilder`
and connect the model to standard Flutter form and it's inputs like this:

```dart
GladeFormBuilder(
  create: (context) => _Model(),
  builder: (context, model) => Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Name'),
          // connect a controller from glade input
          controller: model.name.controller,
          // connect a validator from glade input
          validator: model.name.textFormFieldInputValidator,
        ),
        TextFormField(
          controller: model.age.controller,
          validator: model.age.textFormFieldInputValidator,
          decoration: const InputDecoration(labelText: 'Age'),
        ),
        TextFormField(
          controller: model.email.controller,
          validator: model.email.textFormFieldInputValidator,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: model.isValid ? () {} : null, child: const Text('Save')),
      ],
    ),
  ),  
)
```

![quick_start_example](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/quickstart.gif)

Interactive examples can be found in [📖 Glade Forms Widgetbook][storybook_demo_link].

## ✨ Features

### GladeInput

Each form's input is represented by instance of `GladeInput<T>` where `T` is value held by input.
For simplicity we will interchange `input` and `GladeInput<T>`.

Every input is *dirty* or *pure* based on whether value was updated (or not, yet).

On each input we can define
 - **inputKey** - Unique identification of each input. Used inside listeners or in dependencies.
 - **value** - Current input's value
 - **initialValue** - Initial input's value. Used with valueComparator and for computing `isUnchanged`.
 - **validator** - Input's value must satisfy validation to be *valid* input.
 - **translateError** - If there are validation errors, this function is use to translate those errors.
 - **dependencies** (WIP) - Each input can depend on another inputs for listening changes.
 - **stringTovalueConverter** - If input is used by TextField and `T` is not a `String`, value converter should be provided.
 - **valueComparator** - Sometimes it is handy to provide `initialValue` which will be never updated after input is mutated. `valueComparator` should be provided to compare `initialValue` and `value` if `T` is not comparable type by default. Note that GladeForms handle deep equality of collections and assumes that complex types are comparable by values.
 - **valueTransform** - transform `T` value into different `T` value. An example of usage can be sanitazation of string input (trim(),...).
 - **defaultTranslation** - If error's translations are simple, the default translation settings can be set instead of custom `translateError` method.
 - **textEditingController** - It is possible to provide custom instance of controller instead of default one.
 - **trackUnchanged** - Setting this to false means that `GladeModel` will not include input in the `isUnchanged` property evaluation.

Most of the time, input is created with `.create()` factory with defined validation, translation and other properties.

An overview how each input's value is updated. If needed it is converted from `string` into `T`, then transformed via `valueTransform` (if provided), after that new value is set.

![input-flow-example](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/flow-input-chart.png)

### String based input and TextEditingController

NOTE: Prior to *GladeForms 2.0*, each input generated its own TextEditingController and updated this controller whenever the value changed. This approach led to inconsistencies and problems with text-to-speech features, text selection, and other functionalities.

----

With the introduction of *GladeForms 2.0*, inputs by default (excluding the StringInput variant), do not create a TextEditingController. As a result, developers are required to use `updateValue()`, `updateValueWithString()` or directly set the `value` (via setter) to update the input's value.

If your implementation involves an input paired with a TextField (or any similar widget that utilizes a TextEditingController), you should set `useTextEditingController` to true.

Activating the useTextEditingController mode for a GladeInput results in a few behavioral modifications:

- The input automatically creates a TextEditingController and incorporates its own listener.
- Whenever TextEditingController's text changes, input will automatically update its value. If StringConverter is needed it will use it.
- Consequently, developers are advised to provide only the controller property and a validator to the widget. 
- While the use of updateValue (or similar methods) and resetToPure remains possible, be aware that these actions will override the text in the controller and reset text selection and other keyboard-related features.

#### StringInput

StringInput is specialized variant of GladeInput<String> which has additional, string related, validations such as `isEmail`, `isUrl`, `maxLength` and more. 

Moreover `StringInput` by default uses TextEditingController under the hood. 

#### IntInput

IntInput is specialized variant of GladeInput<int> which has additional, int related, validations such as `isBetween`, `isMin`, `isMax` and more.

- `isBetween` - checks if value is between min and max value. It has optional parameter `inclusiveInterval` which defines if min and max values are included in range.
- `isMin` - checks if value is greater or equal to min value.
- `isMax` - checks if value is less or equal to max value.

Moreover `IntInput` by default uses TextEditingController under the hood.

```dart
final validator = (IntValidator()..isMax(max: 10)).build();
final result = validator.validate(5); // valid
```

### Validation

Validation is defined through part methods on ValidatorFactory such as `notNull()`, `satisfy()` and other parts. 

Each validation rule defines
  - **value validation**, e.g `notNull()` defines that value can not be null. `satisfy()` defines a predicate which has to be true to be valid etc. 
  - **devErrorMessage** - a message which will be displayed if no translation is not provided. 
  - **key** - Validation error's identification. Usable for translation. 

This example defines validation that `int` value has to be greater or equal to 18.

```dart
ageInput = GladeInput.create(
  validator: (v) => (v
        ..notNull()
        ..satisfy(
          (value) => value >= 18,
          devError: (_, __) => 'Value must be greater or equal to 18',
          key: _ErrorKeys.ageRestriction,
        ))
      .build(),
  value: 0,
  valueConverter: GladeTypeConverters.intConverter,
);
```

The order of each validation part matters. By default, the first failing part stops validation. Pass `stopOnFirstError: false` on `.build()` to validate all parts simultaneously.

Fields connected with `textFormFieldInputValidator` will automatically call validator and validation error (if any) is passed down to fields. By default devError is used unless translation is specified. See below. 

### Skipping Specific Validation
To conditionally skip specific validations, use the `shouldValidate` callback. If an input should be entirely excluded from validation, consider using conditional logic in the `inputs` getter.

```dart
(v
  ..minLength(length: 2, shouldValidate: (_) => false)
  ..maxLength(length: 6))
  .build();

// Omit input from validation if the condition applies
get inputs => [if (condition) input];
```

This ensures that the `minLength` validation is always skipped, while the `maxLength` validation is applied. 
If the condition is met, the input is included in the validation process.

#### Using validators without GladeInput

It is possible to use GladeValidator without associated GladeInput. 

Just create instance of `GladeValidator` (or `StringValidator`) and use it.

```dart
final validator = (StringValidator()..notEmpty()).build();
final result = validator.validate(null);
```

### GladeModel

GladeModel is base class for Form's model which holds all inputs together. 
It is useful for cases where you want to sum up validations at once, 
like disabling save button until all inputs are valid. 

GladeModel is `ChangeNotifier` so all dependant widgets will be rebuilt.

There are **several rules** how to define models

- Each input has to be **mutable** and `late` field
- Model has to override `initialize` method where each input field is created
- In the end of `initialize` method, `super.initialize()` must be called to wire-up inputs with model.
  - super.initialize() iterates over all `allInputs` property  (see below) to wire-up inputs with model.
 
For updating input call either `updateValueWithString(String?)` to update `T` value with string (will be converted if needed) or set `value` directly (via setter).

#### Inputs
Each GladeModel is comprised of a variety of inputs. There are situations where it's useful to dynamically include or exclude certain inputs from the model. This is especially relevant when an input isn't constantly visible, hence not requiring validation, and more importantly, when it shouldn't be factored into GladeModel's validation and other computational processes.

In that case override `allInputs` getter to list all inputs within GladeModel. Use `inputs`  getter for dynamic behavior. By default `allInputs` equals to `inputs`.

⚠️ Without properly wiring-up model, model will not be updated appropiately 
and properties such as `isValid` or `formattedErrors` will not work. 

#### Flutter widgets
GladeForms comes with set of predefined widget to help you build your forms.


`GladeModelProvider` provides `GladeModel` to widget's subtreee.

`GladeFormBuilder` allows to listen to model's changes and rebuilts its child. 

`GladeFormListener` allows to listen to model's changes and react to it. Useful for invoking side-effects such as showing dialogs, snackbars etc. `listener` provides `lastUpdatedKeys` which is list of last updated input keys. 

`GladeFormConsumer` combines GladeFormBuilder and GladeFormListener together.

#### Edit multiple inputs at once
With each update of input, via update or setting `.value` directly, listeners (if any) are triggered. Sometimes it is needed to edit multiple inputs at once and triggering listener in the end.

For editing multiple values use `groupEdit()`. It takes void callback to update inputs.

An example

```dart
class FormModel extends GladeModel {
  late GladeInput<int> age;
  late GladeInput<String> name;

  // ....

  groupEdit(() {
    age.value = 18;
    name.value = 'default john',
  });
}

```

After that listener will contain `lastUpdatedKeys` with keys of `age` and `name` inputs.

### Dependencies
An input can depend on other inputs to enable updates based on those dependencies. To define these dependencies, use the dependencies attribute. It's essential to specify inputKey on any inputs that are intended to serve as dependencies.

For instance, consider a scenario where we want the "VIP Content" option to be automatically selected when the 'ageInput' is updated and its value exceeds 18.

```dart
 ageInput = GladeInput.create(
      value: 0,
      valueConverter: GladeTypeConverters.intConverter,
      inputKey: 'age-input',
 );
 vipInput = GladeInput.create(
    inputKey: 'vip-input',
    dependencies: () => [ageInput],
    onDependencyChange: (keys) {
      if (keys.contains('age-input')) {
        vipInput.value = ageInput.value >= 18;
      }
    },
 );
```

![dependent-validation](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/depend-validation.gif)

### Controlling other inputs

Sometimes, it can be handy to update some input's value based on the changed value of another input. As developer you have two options.

You can listen for `onChange()` callback and update other inputs based on input's changed value. An example could be automatically updating the `Age` value based on checked `VIP Content` input (checkbox).

```dart
// In vipContent input
onChange: (info, dependencies) {
  if (info.value && ageInput.value < 18) {
    ageInput.value = 18;
  }
}
```

![two-way-inputs-example](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/two-way-dependencies.gif)

The second approach is to use `dependencies` and `onDependencyChange` callback and react when different dependencies are changed. Note that it works with groupEdit() as well. In that case, onDependencyChange is called once for every changed dependency.

In this example, when age-input update its value (dependency), checkbox's value (vipInput) is updated.

```dart
 vipInput = GladeInput.create(
    inputKey: 'vip-input',
    dependencies: () => [ageInput],
    onChange: (info) {
      if (info.value && ageInput.value < 18) {
        ageInput.value = 18;
      }
    },
    onDependencyChange: (key) {
      if (key.contains('age-input')) {
        vipInput.value = ageInput.value >= 18;
      }
    },
 );
```

### Translation

Each validation error (and conversion error if any) can be translated. Provide `translateError` function which accepts:

- `error` - Error to translate
- `key` - Error's identification if any
- `devMessage` - Provided `devError` from validator
- `dependencies` - Input's dependencies

Age example translation (LocaleKeys are generated translations from [easy_localization](https://pub.dev/packages/easy_localization) package)

```dart
translateError: (error, key, devMessage, {required dependencies}) {
  if (key == _ErrorKeys.ageRestriction) return LocaleKeys.ageRestriction_under18.tr();

  if (error.isConversionError) return LocaleKeys.ageRestriction_ageFormat.tr();

  return devMessage;
}
```

Predefined validators and GladeInput variants defines error keys. Those keys can be found in `GladeErrorKeys` as static constants. Use them within your translation function or in `defualtTranslation`. 

#### Default translations
Use `defaultTranslation` to provide default translations for common error such as `nullValue` or  `emptyValue`. 

![translation-example](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/translation.gif)

Or use `defaultErrorTranslate` on model's level.

Order of translation is as follows:

```dart
translateError -> defaultTranslation -> `Model.defaultErrorTranslate` -> `error.devMessage` 
```

### Converters

As noted before, if `T` is not a String, a converter from String to `T` has to be provided. 

GladeForms provides some predefined converters such as `IntConverter` and more. See `GladeTypeConverters` for more.

### Debugging

There are some getters and methods on GladeInput / GladeModel which can be used for debugging. 

Use `model.formattedValidationErrorsDebug` to get all input's error formatted for simple debugging. 

There is also `GladeModelDebugInfo` widget which displays table of all model's inputs 
and their properties such as `isValid`, `validation error` or current `value`. Widget is customizable, see its properties for more info.

![GladeModelDebugInfo](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/glade-model-debug.png)

## 👏 Contributing

Your contributions are always welcome! Feel free to open pull request.

[netglade_link]: https://netglade.com/en
[ci_badge]: https://github.com/netglade/glade_forms/actions/workflows/ci.yaml/badge.svg
[ci_badge_link]: https://github.com/netglade/glade_forms/actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_badge_link]: https://opensource.org/licenses/MIT
[style_badge]: https://img.shields.io/badge/style-netglade_analysis-26D07C.svg
[style_badge_link]: https://pub.dev/packages/netglade_analysis
[glade_forms_pub_badge]: https://img.shields.io/pub/v/glade_forms.svg
[glade_forms_pub_badge_link]: https://pub.dartlang.org/packages/glade_forms
[discord_badge]: https://img.shields.io/discord/1091460081054400532.svg?logo=discord&color=blue
[discord_badge_link]: https://discord.gg/sJfBBuDZy4
[storybook_demo_link]: https://netglade.github.io/glade_forms