<a href="https://github.com/netglade">
  <picture >
    <source media="(prefers-color-scheme: dark)" height='120px' srcset="https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/badge_light.png">
    <source media="(prefers-color-scheme: light)" height='120px' srcset="https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/badge_dark.png">
    <img alt="netglade" height='120px' src="https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/doc/badge_dark.png">
  </picture>
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
  - [GladeModel](#glademodel)
  - [Dependencies](#dependencies)
  - [Controlling other inputs](#controling-other-inputs)
  - [Validation](#validation)
  - [Translation](#translation)
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
    age = GladeInput.intInput(value: 0);
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
          // connect an on change method
          onChanged: model.name.updateValueWithString,
        ),
        TextFormField(
          controller: model.age.controller,
          validator: model.age.textFormFieldInputValidator,
          onChanged: model.age.updateValueWithString,
          decoration: const InputDecoration(labelText: 'Age'),
        ),
        TextFormField(
          controller: model.email.controller,
          validator: model.email.textFormFieldInputValidator,
          onChanged: model.email.updateValueWithString,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: model.isValid ? () {} : null, child: const Text('Save')),
      ],
    ),
  ),  
)
```

See [📖 Glade Forms Widgetbook][storybook_demo_link], complex, examples.

## ✨ Features

### GladeInput

Each form's input is represented by instance of `GladeInput<T>` where `T` is value held by input.
For simplicity we will interchange `input` and `GladeInput<T>`.

Every input is *dirty* or *pure* based on whether value was updated (or not, yet).

On each input we can define
 - **validator** - Input's value must satisfy validation to be *valid* input.
 - **translateError** - If there are validation errors, function for error translations can be provided.
 - **inputKey** - For debug purposes and dependencies, each input can have unique name for simple identification.
 - **dependencies** - Each input can depend on another inputs for validation.
 - **valueConverter** - If input is used by TextField and `T` is not a `String`, value converter should be provided.
 - **valueComparator** - Sometimes it is handy to provied `initialValue` which will be never updated after input is mutated. `valueComparator` should be provided to compare `initialValue` and `value` if `T` is not comparable type by default. 
 - **defaultTranslation** - If error's translations are simple, the default translation settings can be set instead of custom `translateError` method.
 - **textEditingController** - It is possible to provide custom instance of controller instead of default one.

Most of the time, input is created with `.create()` factory with defined validation, translation and other properties.

#### StringInput

StringInput is specialized variant of GladeInput<String> which has additional, string related, validations such as `isEmail`, `isUrl`, `maxLength` and more.

### GladeModel

GladeModel is base class for Form's model which holds all inputs together. 
It is useful for cases where you want to sum up validations at once, 
like disabling save button until all inputs are valid. 

GladeModel is `ChangeNotifier` so all dependant widgets will be rebuilt.

There are **several rules** how to define models

- Each input has to be **mutable** and `late` field
- Model has to override `initialize` method where each input field is created
- In the end of `initialize` method, `super.initialize()` must be called to wire-up inputs with model.

⚠️ Without wiring-up model, model will not be updated appropiately 
and properties such as `isValid` or `formattedErrors` will not work. 
 
For updating input call either `updateValueWithString(String?)` to update `T` value with string (will be converted if needed) or set `value` directly (via setter).

#### `GladeFormBuilder` and `GladeFormProvider`

`GladeModelProvider` is predefined widget to provide `GladeModel` to widget's subtreee.
Similarly `GladeFormBuilder` allows to listen to model's changes and rebuilts its child. 

### Dependencies

Input can have dependencies on other inputs to allow dependent validation. 
`inputKey` should be assigned for each input to allow dependency work. 

In validation, translation or in `onChange()`, just call `dependencies.byKey()` to get dependent input. 

Note that `byKey()` will throw if no input is found. This is by design to provide immediate indication of error.

### Controlling other inputs

Sometimes, it can be handy to update some input *B* value based on the changed value of input *A*.

Each input has `onChange()` callback where these reactions can be created. For example, automatically update `Age` value based on checked `VIP Content` input (checkbox).

```dart
// In vipContent input
onChange: (info, dependencies) {
  final age = dependencies.byKey<int>('age-input');

  if (info.value && age.value < 18) {
    age.value = 18;
  }
}
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
              (value, extra, dependencies) {
                return value >= 18;
              },
              devError: (_, __) => 'Value must be greater or equal to 18',
              key: _ErrorKeys.ageRestriction,
            ))
          .build(),
      value: 0,
      valueConverter: GladeTypeConverters.intConverter,
);
```

The order of each validation part matters. By default, the first failing part stops validation. Pass `stopOnFirstError: false` on `.build()` to validate all parts simultaneously.

#### Using validators without GladeInput

It is possible to use GladeValidator without associated GladeInputs. 

Just create instance of `GladeValidator` (or `StringValidator`) and use it.

```dart
final validator = (StringValidator()..notEmpty()).build();
final result = validator.validate(null);
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

### Converters

As noted before, if `T` is not a String, a converter from String to `T` has to be provided. 

GladeForms provides some predefined converters such as `IntConverter` and more. See `GladeTypeConverters` for more.

### Debugging

There are some getters and methods on GladeInput / GladeModel which can be used for debugging. 

Use `model.formattedValidationErrors` to get all input's error formatted for simple debugging. 

There is also `GladeModelDebugInfo` widget which displays table of all model's inputs 
and their properties such as `isValid` or `validation error`.

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