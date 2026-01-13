// ignore_for_file: prefer-trailing-comma, avoid-undisposed-instances

import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _ComposedModel extends GladeComposedModel<_NestedComposedModel> {
  _ComposedModel([super.initialModels]);
}

class _NestedComposedModel extends GladeComposedModel<_Model> {
  _NestedComposedModel([super.initialModels]);
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

class NestedComposedExample extends StatelessWidget {
  const NestedComposedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Nested composed forms',
      child: GladeModelProvider(
        create: (context) => _ComposedModel([
          _NestedComposedModel([_Model(), _Model()]),
          _NestedComposedModel([_Model(), _Model()]),
        ]),
        child: Column(
          children: [
            Flexible(
              child: GladeComposedListBuilder<_ComposedModel, _NestedComposedModel>(
                shrinkWrap: true,
                itemBuilder: (context, model, nestedModel, index) => _GroupContainer(
                  composedModel: model,
                  nestedComposedModel: nestedModel,
                  groupIndex: index,
                ),
              ),
            ),
            GladeFormBuilder<_ComposedModel>(
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
                      tooltip: 'Add new group',
                      // ignore: prefer-extracting-callbacks, ok here
                      onPressed: () {
                        model.addModel(_NestedComposedModel([_Model()]));
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

class _GroupContainer extends StatelessWidget {
  final _ComposedModel composedModel;
  final _NestedComposedModel nestedComposedModel;
  final int groupIndex;

  const _GroupContainer({required this.composedModel, required this.nestedComposedModel, required this.groupIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Text('Group #${groupIndex + 1}'),
                  IconButton(
                    onPressed: () => composedModel.removeModel(nestedComposedModel),
                    icon: const Icon(Icons.remove),
                  ),
                ],
              ),
              GladeComposedListBuilder<_NestedComposedModel, _Model>(
                shrinkWrap: true,
                itemBuilder: (context, model, nestedModel, personIndex) => _Form(
                  composedModel: model,
                  model: nestedModel,
                  index: personIndex,
                ),
              ),
              Text(
                nestedComposedModel.isValid ? 'Group is valid' : 'Group is invalid',
                style: TextStyle(
                  color: nestedComposedModel.isValid ? Colors.lightGreen : Colors.red,
                ),
              ),
              TextButton(
                // ignore: prefer-extracting-callbacks, ok here
                onPressed: () {
                  nestedComposedModel.addModel(_Model());
                },
                child: const Text('Add person', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final _NestedComposedModel composedModel;
  final _Model model;
  final int index;

  const _Form({required this.composedModel, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide()),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white,
      ),
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
    );
  }
}
