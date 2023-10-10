import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends GladeModel {
  late StringInput name;
  late GladeInput<int> age;
  late StringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email];

  _Model();

  @override
  void initialize() {
    name = StringInput.required();
    age = GladeInput.intInput(value: 0);
    email = StringInput.create(validator: (validator) => (validator..isEmail()).build());

    super.initialize();
  }
}

class QuickStartExample extends StatelessWidget {
  const QuickStartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Quick start example',
      child: GladeFormBuilder(
        create: (context) => _Model(),
        builder: (context, model, _) => Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  initialValue: model.name.value,
                  validator: model.name.textFormFieldInputValidator,
                  onChanged: model.name.updateValueWithString,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  initialValue: model.age.stringValue,
                  validator: model.age.textFormFieldInputValidator,
                  onChanged: model.age.updateValueWithString,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                TextFormField(
                  initialValue: model.email.value,
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
