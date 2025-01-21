import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';

// ! When updating dont forget to update README.md quickstart as well
class _Model extends GladeModel {
  late StringInput name;
  late IntInput age;
  late StringInput email;
  late IntInput income;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email, income];

  @override
  void initialize() {
    name = GladeInput.stringInput(inputKey: 'name');
    age = GladeInput.intInput(value: 0, inputKey: 'age');
    email = GladeInput.stringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');
    income = GladeInput.intInput(
      value: 10000,
      validator: (validator) => (validator..isMin(min: 1000)).build(),
      inputKey: 'income',
    );

    super.initialize();
  }
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return GladeFormBuilder.create(
      // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
      create: (context) => _Model(),
      builder: (context, model, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: model.name.controller,
                validator: model.name.textFormFieldInputValidator,
                decoration: const InputDecoration(labelText: 'Name'),
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
              TextFormField(
                controller: model.income.controller,
                validator: model.income.textFormFieldInputValidator,
                decoration: const InputDecoration(labelText: 'income'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                // ignore: no-empty-block, empty function, just for example
                onPressed: model.isValid ? () {} : null,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
