import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

Future<String> _fetchName() {
  return Future.delayed(const Duration(seconds: 2), () => 'John Doe');
}

class _Model extends GladeModelAsync {
  late StringInput name;
  late GladeInput<int> age;
  late StringInput email;
  late GladeInput<bool> vip;

  @override
  List<GladeInput<Object?>> get inputs => [name, age, email, vip];

  _Model();

  @override
  Future<void> initializeAsync() async {
    final nameValue = await _fetchName();

    name = GladeInput.stringInput(inputKey: 'name', value: nameValue);
    age = GladeInput.intInput(value: 0, inputKey: 'age');
    email = GladeInput.stringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');
    vip = GladeInput.create(
      validator: (v) => (v..notNull()).build(),
      value: false,
      inputKey: 'vip',
      dependencies: () => [name],
      onChangeAsync: (info, dependencies) async {
        final nameInput = dependencies.byKey<String?>('name');

        final fetchedName = await _fetchName();

        groupEdit(() {
          nameInput.value = fetchedName;
        });
      },
    );

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
                  readOnly: model.isChanging,
                ),
                TextFormField(
                  controller: model.age.controller,
                  validator: model.age.textFormFieldInputValidator,
                  onChanged: model.age.updateValueWithString,
                  decoration: const InputDecoration(labelText: 'Age'),
                  readOnly: model.isChanging,
                ),
                TextFormField(
                  controller: model.email.controller,
                  validator: model.email.textFormFieldInputValidator,
                  onChanged: model.email.updateValueWithString,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: model.isChanging,
                ),
                CheckboxListTile(
                  value: model.vip.value,
                  title: Row(
                    children: [
                      const Text('VIP Content '),
                      if (model.isChanging) const Text('isChanging', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onChanged: (v) => model.vip.value = v ?? false,
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
