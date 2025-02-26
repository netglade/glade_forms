// ignore_for_file: prefer-single-widget-per-file, avoid-undisposed-instances

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends GladeModel {
  late GladeStringInput nameWithController;
  late GladeStringInput nameWrong;
  late GladeIntInput age;
  late GladeStringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [nameWithController, age, email, nameWrong];

  @override
  void initialize() {
    nameWithController = GladeStringInput(inputKey: 'name');
    nameWrong = GladeStringInput(inputKey: 'wrong_name');
    age = GladeIntInput(value: 0, inputKey: 'age');
    email = GladeStringInput(validator: (validator) => (validator..isEmail()).build(), inputKey: 'email');

    super.initialize();
  }
}

class Issue48TextControllerExample extends StatelessWidget {
  const Issue48TextControllerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Issue 48',
      description: 'https://github.com/netglade/glade_forms/issues/48',
      child: ListView(
        children: [
          const HookExample(),
          GladeModelProvider(create: (context) => _Model(), child: const ModelB()),
        ],
      ),
    );
  }
}

class HookExample extends HookWidget {
  const HookExample({super.key});

  @override
  Widget build(BuildContext context) {
    final wrongField = useTextEditingController();
    final numb = useState(0);

    return Column(
      children: [
        Text(numb.value.toString()),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: wrongField,
            onChanged: (v) => numb.value = v.length,
          ),
        ),
      ],
    );
  }
}

class ModelB extends HookWidget {
  const ModelB({super.key});

  @override
  Widget build(BuildContext context) {
    final wrongFieldController = useTextEditingController();

    return GladeFormBuilder<_Model>(
      builder: (context, model, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Text(model.nameWithController.value),
              TextFormField(
                controller: model.nameWithController.controller,
                validator: model.nameWithController.textFormFieldInputValidator,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextButton(
                onPressed: () => model.nameWithController.updateValue('Reseted value'),
                child: const Text('Reset name value'),
              ),
              const Divider(),
              const SizedBox(height: 30),
              const Text('Wrongly behaving field'),
              TextFormField(
                controller: wrongFieldController,
                // Previous version of GladeForms basically did same thing behind the scenes.
                // Upon updating value within GladeInput, GladeInput's controller.text was updated along.
                onChanged: (v) => wrongFieldController.text = v, //THIS IS WRONG
              ),
            ],
          ),
        ),
      ),
    );
  }
}
