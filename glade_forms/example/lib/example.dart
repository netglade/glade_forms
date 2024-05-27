import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';

// ! When updating dont forget to update README.md quickstart as well
class _Model extends GladeModel {
  late StringInput name;
  late GladeInput<int> age;
  late StringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email];

  @override
  void initializeInputs() {
    name = GladeInput.stringInput(inputKey: 'name');
    age = GladeInput.intInput(value: 0, inputKey: 'age');
    email = GladeInput.stringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');
  }
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return GladeFormBuilder.create(
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
              const SizedBox(height: 10),
              ElevatedButton(
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
