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
- [📖 Documentation](#-documentation)

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
  late GladeStringInput name;
  late GladeIntInput age;
  late GladeStringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email];

  @override
  void initialize() {
    name = GladeStringInput();
    age = GladeIntInput(value: 0, useTextEditingController: true);
    email = GladeStringInput(validator: (validator) => (validator..isEmail()).build());

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

![quick_start_example](https://raw.githubusercontent.com/netglade/glade_forms/main/glade_forms/docs/assets/quickstart.gif)

Interactive examples can be found in [📖 Glade Forms Widgetbook][storybook_demo_link].

## 📖 Documentation
Want to learn more? 

Check out the [Glade Forms Documentation][docs_page].

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
[docs_page]: https://docs.page/netglade/glade_forms
[docs_badge]: docs/assets/icon.png