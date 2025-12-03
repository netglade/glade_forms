import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _ComposedModel extends GladeComposedModel<_Model> {
  _ComposedModel([super.initialModels]);
}

class _Model extends GladeModel {
  late GladeStringInput firstName;
  late GladeStringInput lastName;

  @override
  List<GladeInput<Object?>> get inputs => [firstName, lastName];

  @override
  void initialize() {
    firstName = GladeStringInput(
      initialValue: '',
      validator: (v) => (v..satisfy((value) => value.isNotEmpty)).build(),
      validationTranslate: (_, __, ___, ____) => firstName.value.isEmpty ? 'First name cannot be empty' : '',
    );
    lastName = GladeStringInput(
      initialValue: '',
      validator: (v) => (v..satisfy((value) => value.isNotEmpty)).build(),
      validationTranslate: (_, __, ___, ____) => lastName.value.isEmpty ? 'Last name cannot be empty' : '',
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
            Flexible(
              child: GladeComposedListBuilder<_ComposedModel, _Model>(
                shrinkWrap: true,
                itemBuilder: (context, composedModel, model, index) => _Form(
                  composedModel: composedModel,
                  model: model,
                  index: index,
                ),
              ),
            ),
            GladeComposedFormBuilder<_ComposedModel>(
              builder: (context, model, child) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Text(
                      model.isValid ? 'Everything is filled' : 'Something is missing',
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
  final int index;

  const _Form({required this.composedModel, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Person #${index + 1}'),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: model.firstName.controller,
                            validator: model.firstName.textFormFieldInputValidator,
                            decoration: const InputDecoration(labelText: 'First name'),
                          ),
                          Text(
                            model.firstName.translate() ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: model.lastName.controller,
                            validator: model.lastName.textFormFieldInputValidator,
                            decoration: const InputDecoration(labelText: 'Last name'),
                          ),
                          Text(
                            model.lastName.translate() ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => composedModel.removeModel(model), icon: const Icon(Icons.remove)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
