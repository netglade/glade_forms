import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends GladeModel {
  late GladeIntInput age;
  late GladeIntInput income;

  @override
  List<GladeInput<Object?>> get inputs => [age, income];

  @override
  void initialize() {
    age = GladeIntInput(
      value: 0,
      inputKey: 'age',
      useTextEditingController: true,
      validator: (v) => (v..isMin(min: 18, severity: ErrorServerity.warning)).build(),
    );
    income = GladeIntInput(
      value: 0,
      inputKey: 'income',
      useTextEditingController: true,
      validator: (v) => (v
            ..isMin(min: 18, severity: ErrorServerity.warning)
            ..isMin(min: 25, severity: ErrorServerity.warning))
          .build(),
    );

    super.initialize();
  }
}

class WarningInputExample extends StatelessWidget {
  const WarningInputExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Warning validation example',
      description: "Example with warning validation which doesn't stop form submission",
      child: GladeFormBuilder.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => _Model(),
        builder: (context, model, _) => Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                // TextFormField(
                //   controller: model.age.controller,
                //   validator: model.age.textFormFieldInputValidator,
                //   decoration: const InputDecoration(labelText: 'Age'),
                // ),
                const Text(
                  'This field displays warnings as part of validation. \n Warning: Income must be min 18 \n Warning: Income must be min 25',
                ),
                TextFormField(
                  controller: model.income.controller,
                  validator: (value) => model.income
                      .textFormFieldInputValidator(value, severity: ErrorServerity.warning, delimiter: '\n'),
                  decoration: const InputDecoration(labelText: 'Income'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: model.isValid
                      ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')))
                      : null,
                  child: const Text('Save'),
                ),
                const GladeFormDebugInfo<_Model>(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
