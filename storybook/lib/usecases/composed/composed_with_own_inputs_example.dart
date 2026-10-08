import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

/// Composed model with its own inputs - the team's name and motto live on the composed model itself,
/// next to the forms of its members.
class _TeamModel extends GladeComposedModel<_MemberModel> {
  late GladeStringInput teamName;
  late GladeStringInput motto;

  @override
  List<GladeInput<Object?>> get inputs => [teamName, motto];

  _TeamModel([super.initialModels]);

  @override
  void initialize() {
    teamName = GladeStringInput(
      initialValue: '',
      inputKey: 'teamName',
      validator: (v) => (v..notEmpty()).build(),
      validationTranslate: (_, _, _, _) => 'Team name cannot be empty',
    );
    // GladeStringInput is required by default, and the motto is not.
    motto = GladeStringInput(initialValue: '', inputKey: 'motto', isRequired: false);

    super.initialize();
  }
}

class _MemberModel extends GladeModel {
  late GladeStringInput firstName;
  late GladeStringInput lastName;

  @override
  List<GladeInput<Object?>> get inputs => [firstName, lastName];

  @override
  void initialize() {
    firstName = GladeStringInput(
      initialValue: '',
      validator: (v) => (v..notEmpty()).build(),
      validationTranslate: (_, _, _, _) => 'First name cannot be empty',
    );
    lastName = GladeStringInput(
      initialValue: '',
      validator: (v) => (v..notEmpty()).build(),
      validationTranslate: (_, _, _, _) => 'Last name cannot be empty',
    );

    super.initialize();
  }
}

class ComposedWithOwnInputsExample extends StatelessWidget {
  const ComposedWithOwnInputsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: "Composed form with composed model's own inputs",
      child: GladeModelProvider(
        // ignore: avoid-undisposed-instances, handled by provider
        create: (context) => _TeamModel([_MemberModel()]),
        child: Column(
          children: [
            const _TeamFields(),
            Flexible(
              child: GladeComposedListBuilder<_TeamModel, _MemberModel>(
                shrinkWrap: true,
                itemBuilder: (context, teamModel, memberModel, index) =>
                    _MemberForm(teamModel: teamModel, model: memberModel, index: index),
              ),
            ),
            const _TeamSummary(),
          ],
        ),
      ),
    );
  }
}

/// Composed model's own inputs are consumed exactly like inputs of a plain GladeModel.
class _TeamFields extends StatelessWidget {
  const _TeamFields();

  @override
  Widget build(BuildContext context) {
    return GladeFormConsumer<_TeamModel>(
      builder: (context, model, child) => Padding(
        padding: const .symmetric(vertical: 8, horizontal: 16),
        child: Card(
          child: Padding(
            padding: const .all(8),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const Text('Team'),
                TextFormField(
                  controller: model.teamName.controller,
                  validator: model.teamName.textFormFieldInputValidator,
                  decoration: const InputDecoration(labelText: 'Team name'),
                ),
                Text(
                  model.teamName.translate() ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
                TextFormField(
                  controller: model.motto.controller,
                  decoration: const InputDecoration(labelText: 'Motto (optional)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamSummary extends StatelessWidget {
  const _TeamSummary();

  @override
  Widget build(BuildContext context) {
    return GladeFormConsumer<_TeamModel>(
      builder: (context, model, child) => Padding(
        padding: const .only(bottom: 16),
        child: Column(
          children: [
            Text(
              model.isValid ? 'Everything is filled' : 'Something is missing',
              style: TextStyle(color: model.isValid ? Colors.lightGreen : Colors.red),
            ),
            Text('Last updated: ${model.lastUpdatedInputKeys.join(', ')}'),
            Row(
              mainAxisAlignment: .center,
              spacing: 16,
              children: [
                FloatingActionButton(
                  heroTag: GlobalKey(),
                  tooltip: 'Add member',
                  // ignore: prefer-extracting-callbacks, ok here
                  onPressed: () {
                    // ignore: avoid-undisposed-instances, disposed with the composed model
                    model.addModel(_MemberModel());
                  },
                  child: const Text('+', style: TextStyle(fontSize: 26)),
                ),
                FloatingActionButton(
                  heroTag: GlobalKey(),
                  tooltip: 'Reset the whole form',
                  onPressed: model.resetToInitialValue,
                  child: const Icon(Icons.restart_alt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberForm extends StatelessWidget {
  final _TeamModel teamModel;
  final _MemberModel model;
  final int index;

  const _MemberForm({required this.teamModel, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 8, horizontal: 16),
      child: Card(
        child: Padding(
          padding: const .all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text('Member #${index + 1}'),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
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
                        crossAxisAlignment: .start,
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
                    IconButton(
                      onPressed: () => teamModel.removeModel(model),
                      icon: const Icon(Icons.remove),
                    ),
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
