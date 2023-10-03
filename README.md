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
  - [Existing validators](#existing-validators)
  - [Creating own reusable ValidatorPart](#creating-own-reusable-validatorpart)
  - [📚 Adding translation support](#-adding-translation-support)
  - [GladeFormBuilder and GladeFormProvider](#gladeformbuilder-and-gladeformprovider)
  - [🛠️ Debugging validators](#️-debugging-validators)
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
    age = GladeInput.create(value: 0);
    email = StringInput.create((validator) => (validator..isEmail()).build());
  }
}

```

and wire-it up with Form

```dart

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


### Existing validators


### Creating own reusable ValidatorPart

### 📚 Adding translation support


### GladeFormBuilder and GladeFormProvider

### 🛠️ Debugging validators





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