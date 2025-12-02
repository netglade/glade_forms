import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';
import 'package:provider/provider.dart';

class _ComposedModelImpl extends ComposedGladeModel<_ModelImpl> {
  _ComposedModelImpl([super.initialModels]);
}

class _ModelImpl extends GladeModel {
  late GladeBoolInput adult;
  late GladeStringInput name;

  @override
  List<GladeInput<Object?>> get inputs => [adult, name];

  @override
  void initialize() {
    adult = GladeBoolInput(
      initialValue: false,
      validator: (v) => (v..satisfy((value) => value)).build(),
      validationTranslate: (_, __, ___, ____) => adult.value ? '' : 'Adulthood must be true',
    );
    name = GladeStringInput(
      initialValue: '',
      validator: (v) => (v..satisfy((value) => value.isNotEmpty)).build(),
      validationTranslate: (_, __, ___, ____) => name.value.isEmpty ? 'Name cannot be empty' : '',
    );
    super.initialize();
  }
}

class ComposedExample extends StatelessWidget {
  const ComposedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Composed forms',
      child: ComposedGladeFormBuilder<_ComposedModelImpl, _ModelImpl>.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => _ComposedModelImpl([_ModelImpl()]),
        itemBuilder: (context, model, index) => _Form(model),
        bottomBuilder: (context) {
          final composedModel = context.read<_ComposedModelImpl>();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Text(
                  composedModel.isValid ? 'Everything is valid' : 'Not all models are valid',
                  style: TextStyle(
                    color: composedModel.isValid ? Colors.lightGreen : Colors.red,
                  ),
                ),
                FloatingActionButton(
                  heroTag: GlobalKey(),
                  tooltip: 'add-form',
                  // ignore: prefer-extracting-callbacks, ok here
                  onPressed: () {
                    // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
                    composedModel.addModel(_ModelImpl());
                  },
                  child: const Text('+', style: TextStyle(fontSize: 26)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final _ModelImpl model;

  const _Form(this.model);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: model.name.controller,
                    validator: model.name.textFormFieldInputValidator,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                Switch(value: model.adult.value, onChanged: (v) => model.adult.updateValue(v)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.name.translate() ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
                Text(
                  model.adult.translate() ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
