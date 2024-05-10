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
    name = GladeInput.stringInput(inputKey: 'name');
    age = GladeInput.intInput(value: 0, inputKey: 'age', useTextEditingController: true);
    email = GladeInput.stringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');

    super.initialize();
  }
}

class AsyncExample extends StatelessWidget {
  const AsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Async example',
      child: GladeFormBuilder.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => _Model(),
        builder: (context, model, _) => const Padding(
          padding: EdgeInsets.all(32),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(children: [AsyncTextField()]),
          ),
        ),
      ),
    );
  }
}
