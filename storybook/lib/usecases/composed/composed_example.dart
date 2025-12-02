import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _ComposedModel extends ComposedGladeModel<_Model> {
  _ComposedModel([super.initialModels]);
}

class _Model extends GladeModel {
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
      child: GladeComposedModelProvider(
        // ignore: avoid-undisposed-instances, handled pro provider
        create: (context) => _ComposedModel([_Model()]),
        child: Column(
          children: [
            Expanded(
              child: GladeComposedListBuilder<_ComposedModel, _Model>(
                itemBuilder: (context, composedModel, model, index) => _Form(composedModel, model),
              ),
            ),
            GladeComposedFormBuilder<_ComposedModel>(
              builder: (context, model, child) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Text(
                      model.isValid ? 'Everything is valid' : 'Not all models are valid',
                      style: TextStyle(
                        color: model.isValid ? Colors.lightGreen : Colors.red,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: GlobalKey(),
                      tooltip: 'add-form',
                      // ignore: prefer-extracting-callbacks, ok here
                      onPressed: () {
                        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
                        model.addModel(_Model());
                      },
                      child: const Text('+', style: TextStyle(fontSize: 26)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final _ComposedModel composedModel;
  final _Model model;

  const _Form(this.composedModel, this.model);

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
                IconButton(onPressed: () => composedModel.removeModel(model), icon: const Icon(Icons.remove)),
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
