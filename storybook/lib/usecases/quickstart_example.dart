import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends GladeModel {
  late GladeStringInput name;
  late GladeIntInput age;
  late GladeStringInput email;
  late GladeIntInput income;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email, income];

  @override
  void initialize() {
    name = GladeStringInput(inputKey: 'name');
    age = GladeIntInput(value: 0, inputKey: 'age', useTextEditingController: true);
    email = GladeStringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');
    income = GladeIntInput(
      value: 10000,
      validator: (validator) => (validator..isMin(min: 1000)).build(),
      inputKey: 'income',
    );

    super.initialize();
  }
}

class QuickStartExample extends StatelessWidget {
  const QuickStartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Quick start example',
      child: GladeFormBuilder.create(
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
                  decoration: const InputDecoration(labelText: 'Income'),
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
