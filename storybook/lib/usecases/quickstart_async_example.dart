import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

Future<String> _fetchName() async {
  await Future.delayed(const Duration(seconds: 2));

  return 'John Doe';
}

class _Model extends GladeModelAsync {
  late StringInput name;
  late GladeInput<int> age;
  late StringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email];

  _Model();

  @override
  Future<void> initializeAsync() async {
    final nameValue = await _fetchName();

    name = GladeInput.stringInput(inputKey: 'name', value: nameValue);
    age = GladeInput.intInput(value: 0, inputKey: 'age');
    email = GladeInput.stringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');

    await super.initializeAsync();
  }
}

class QuickStartAsyncExample extends StatelessWidget {
  const QuickStartAsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Quick start example',
      child: GladeFormBuilder.create(
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
                  onChanged: model.name.updateValueWithString,
                  decoration: const InputDecoration(labelText: 'Name'),
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
                ElevatedButton(
                  onPressed: model.isValid
                      ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')))
                      : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
