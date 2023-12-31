// ignore_for_file: avoid-passing-self-as-argument

import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Item {
  final int id;
  final String name;
  const _Item({required this.id, required this.name});
}

class _Model extends GladeModel {
  final List<_Item> availableItems = [
    const _Item(id: 1, name: 'Legendary sword'),
    const _Item(id: 2, name: 'Moon stone'),
    const _Item(id: 3, name: 'Golden apple'),
  ];

  late GladeInput<_Item?> selectedItem;
  late GladeInput<List<int>> availableStats;

  @override
  List<GladeInput<Object?>> get inputs => [selectedItem, availableStats];

  @override
  void initialize() {
    selectedItem = GladeInput.create(
      validator: (v) => (v..notNull()).build(),
      value: null,
      inputKey: 'selectedItem',
    );
    availableStats = GladeInput.create(
      validator: (v) => v.build(),
      value: [],
      inputKey: 'stats',
      valueConverter: StringToTypeConverter(
        converter: (rawInput, cantConvert) {
          final r = RegExp(r'^\d+(,\s*\d+\s*)*$');
          final input = rawInput;

          if (input == null) return cantConvert("Cant't convert null value", rawValue: input);
          if (!r.hasMatch(input)) {
            return cantConvert(
              "Cant't convert. Must be separated list of numbers divided by comma.",
              rawValue: input,
            );
          }

          final strValues = input.split(',');

          return strValues.map(int.parse).toList();
        },
        converterBack: (input) => input.join(','),
      ),
    );

    super.initialize();
  }
}

class ComplexObjectMappingExample extends StatelessWidget {
  const ComplexObjectMappingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Converters and complex objects',
      className: 'complex_object_mapping_example.dart',
      child: GladeFormBuilder.create(
        create: (context) => _Model(),
        builder: (context, model, _) {
          return Form(
            autovalidateMode: AutovalidateMode.always,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Characters stats'),
                        controller: model.availableStats.controller,
                        validator: model.availableStats.textFormFieldInputValidator,
                        onChanged: (value) => model.stringFieldUpdateInput(model.availableStats, value),
                      ),
                      DropdownButton(
                        items: model.availableItems
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        value: model.selectedItem.value?.id,
                        onChanged: (v) => model.updateInput(
                          model.selectedItem,
                          // ignore: avoid-unsafe-collection-methods, ok here.
                          model.availableItems.firstWhere((element) => element.id == v),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Character stats'),
                      ...model.availableStats.value.map((e) => Text(e.toString())),
                      const Text('Selected item'),
                      Text(model.selectedItem.value?.name ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
