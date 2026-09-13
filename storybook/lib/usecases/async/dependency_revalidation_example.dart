import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/fake_validation_server.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends GladeModel {
  final FakeValidationServer server = FakeValidationServer(delay: const Duration(milliseconds: 500));

  late GladeInput<String> organisation;
  late GladeStringInput email;

  @override
  List<GladeInput<Object?>> get inputs => [organisation, email];

  @override
  void initialize() {
    organisation = GladeInput.required(inputKey: 'organisation', value: 'netglade');
    email = GladeStringInput(
      inputKey: 'email',
      value: '',
      dependencies: () => [organisation],
      onDependencyChange: (_) => unawaited(email.validateAsync(force: true)),
      validator: (v) =>
          (v
                ..isEmail()
                ..customAsync(
                  (value, key) async {
                    final isAllowed = await server.isEmailAllowedInOrganisation(value, organisation.value);

                    return isAllowed
                        ? null
                        : ValueError(
                            value: value,
                            key: key,
                            devMessage: (_) => 'Email must belong to ${organisation.value} domain',
                          );
                  },
                  key: 'email-domain',
                ))
              .build(asyncDebounce: const Duration(milliseconds: 300)),
    );

    super.initialize();
  }
}

class DependencyRevalidationExample extends StatelessWidget {
  const DependencyRevalidationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Async validation: dependency revalidation',
      description: '''
Email is validated against the selected organisation's domain (`netglade` -> `@netglade.cz`, `acme` -> `@acme.com`, `other` -> anything).

Changing the organisation does not change the email value, so the cached async result would stay.
`onDependencyChange` calls `email.validateAsync(force: true)` to re-run it.

The dropdown updates the input through `model.updateInput`, which is a trigger as well, no `FormField` involved.
''',
      className: 'async/dependency_revalidation_example.dart',
      child: GladeFormBuilder.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => _Model(),
        builder: (context, model, _) => Padding(
          padding: const .all(32),
          child: Form(
            autovalidateMode: .onUserInteraction,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: model.organisation.value,
                  decoration: const InputDecoration(labelText: 'Organisation'),
                  items: const [
                    DropdownMenuItem(value: 'netglade', child: Text('netglade')),
                    DropdownMenuItem(value: 'acme', child: Text('acme')),
                    DropdownMenuItem(value: 'other', child: Text('other')),
                  ],
                  onChanged: (value) => _onOrganisationChanged(model, value),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: model.email.controller,
                  validator: model.email.textFormFieldInputValidator,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    suffixIcon: model.email.isValidating
                        ? const Padding(
                            padding: .all(12),
                            child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Requests: ${model.server.requestCount}'),
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

  void _onOrganisationChanged(_Model model, String? value) {
    final organisation = model.organisation;

    model.updateInput(organisation, value ?? organisation.value);
  }
}
