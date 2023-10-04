<a href="https://github.com/netglade">
    <img alt="netglade" height='120px' src="https://raw.githubusercontent.com/netglade/auto_mappr/main/packages/auto_mappr/doc/badge_dark.png">  
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
  - [Why should I use it?](#why-should-i-use-it)
- [🚀 Getting started](#-getting-started)
  - [GladeInput](#gladeinput)
    - [Defining input](#defining-input)
    - [StringInput](#stringinput)
  - [Creating own reusable ValidatorPart](#creating-own-reusable-validatorpart)
  - [:books: Adding translation support](#books-adding-translation-support)
  - [GladeFormBuilder and GladeFormProvider](#gladeformbuilder-and-gladeformprovider)
  - [:hammer: Debugging validators](#hammer-debugging-validators)
- [👏 Contributing](#-contributing)

## 👀 What is this?

**TODO reword this.**

Glade forms offer unified way to define reusable form input
with support of fluent API to define input's validators and with support of translation on top of that.

**TBA DEMO SITE**

### Why should I use it?


## 🚀 Getting started

Define you model and inputs: 

```dart
class _Model extends GladeModel {
  late StringInput name;
  late GladeInput<int> age;
  late StringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email];

  _Model() {
    name = StringInput.required();
    age = GladeInput.intInput(value: 0);
    email = StringInput.create((validator) => (validator..isEmail()).build());
  }
}

```

and wire-it up with Form

```dart
GladeFormBuilder(
  create: (context) => _Model(),
  builder: (context, model) => Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      children: [
        TextFormField(
          initialValue: model.name.value,
          validator: model.name.formFieldInputValidator,
          onChanged: (v) => model.stringFieldUpdateInput(model.name, v),
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextFormField(
          initialValue: model.age.stringValue,
          validator: model.age.formFieldInputValidator,
          onChanged: (v) => model.stringFieldUpdateInput(model.age, v),
          decoration: const InputDecoration(labelText: 'Age'),
        ),
        TextFormField(
          initialValue: model.email.value,
          validator: model.email.formFieldInputValidator,
          onChanged: (v) => model.stringFieldUpdateInput(model.email, v),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: model.isValid ? () {} : null, child: const Text('Save')),
      ],
    ),
  ),  
)
```

### GladeInput
Each form's input is represented by instance of `GladeInput<T>` where `T` is value held by input.
For simplicity we will interchange `input` and `GladeInput<T>`.

Every input is *dirty* or *pure* based on if value was updated (or not, yet). 

On each input we can defined
 - *validator* - Input's value must satistfy validation to be *valid* input.
 - *translateError* - If there are validation errors, function for error translations can be provided.
 - *inputKey* - For debug purposes and dependencies, each input can have unique name for simple identification.
 - *dependencies* - Each input can depend on another inputs for validation.
 - *valueConverter* - If input is used by TextField and `T` is not a `String`, value converter should be provided.
 - *valueComparator* - Sometimes it is handy to provied `initialValue` which will be never updated after input is mutated. `valueComparator` should be provided to compare `initialValue` and `value` if `T` is not comparable type by default. 
 - *defaultTranslation* - If error's translations are simple, the default translation settings can be set instead of custom `translateError` method.

#### Defining input
Most of the time, input is created with `.create()` factory with defined validation, translation and other properties. 

Validation is defined through part methods on ValidatorFactory such as `notNull()`, `satisfy()` and other parts. 

Each validation rule defines
  - *value validation*, e.g `notNull()` defines that value  can not be null. `satisfy()` defines predicate which has to be true to be valid etc. 
  - **devErrorMessage** - message which will be displayed if no translation is not provided. 
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
> [!IMPORTANT]
> Order of validation parts matter. By default first failing part stops validation. Pass `stopOnFirstError: false` on `.build()` to validate all parts. 


#### StringInput
StringInput is specialized variant of GladeInput<String> which has aditional, string focused, validations such as `isEmail` or `isUrl`.


### Creating own reusable ValidatorPart

### :books: Adding translation support


### GladeFormBuilder and GladeFormProvider

### :hammer: Debugging validators





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