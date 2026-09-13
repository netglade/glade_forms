import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/fake_validation_server.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';
import 'package:widgetbook/widgetbook.dart';

class _Model extends GladeModel {
  final FakeValidationServer server;
  final AsyncValidationMode mode;
  final Duration debounce;

  late GladeStringInput username;

  @override
  AsyncValidationMode get asyncValidationMode => mode;

  @override
  List<GladeInput<Object?>> get inputs => [username];

  _Model({required this.server, required this.mode, required this.debounce});

  @override
  void initialize() {
    username = GladeStringInput(
      inputKey: 'username',
      value: '',
      validator: (v) =>
          (v
                ..minLength(length: 3)
                ..satisfyAsync(
                  server.isUsernameAvailable,
                  key: 'username-taken',
                  devMessage: (value) => 'Username "$value" is already taken',
                ))
              .build(asyncDebounce: debounce),
      defaultValidationTranslations: const DefaultValidationTranslations(
        defaultAsyncValidationFailedMessage: 'Could not verify username, try again',
      ),
    );

    super.initialize();
  }
}

class UsernameAvailabilityExample extends StatelessWidget {
  const UsernameAvailabilityExample({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.knobs.object.dropdown(
      label: 'Async validation mode',
      options: AsyncValidationMode.values,
      labelBuilder: (value) => value.name,
    );
    final debounceMs = context.knobs.int.slider(label: 'Debounce (ms)', initialValue: 300, max: 2000);
    final serverDelayMs = context.knobs.int.slider(label: 'Server delay (ms)', initialValue: 800, max: 3000);
    final isServerFailing = context.knobs.boolean(label: 'Server failing');

    return UsecaseContainer(
      shortDescription: 'Async validation: username availability',
      description: '''
Type a username. Taken usernames: `admin`, `glade`, `petr`.

- Synchronous rule (min length 3) runs first; the server is asked only when it passes.
- Requests are debounced; rapid typing produces one request.
- **strict** mode: the Save button is disabled while validating.
- **lastKnown** mode: the Save button stays enabled while validating and `onPressed` awaits `model.validateAsync()` before saving.
- Toggle *Server failing* to see `onError` default handling (`AsyncValidationFailedError` with a default message).
''',
      className: 'async/username_availability_example.dart',
      child: KeyedSubtree(
        key: ValueKey('$mode-$debounceMs'),
        child: GladeFormBuilder.create(
          // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
          create: (context) => _Model(
            server: FakeValidationServer(delay: Duration(milliseconds: serverDelayMs), isFailing: isServerFailing),
            mode: mode,
            debounce: Duration(milliseconds: debounceMs),
          ),
          builder: (context, model, _) {
            model.server
              ..delay = Duration(milliseconds: serverDelayMs)
              ..isFailing = isServerFailing;

            return Padding(
              padding: const .all(32),
              child: Form(
                autovalidateMode: .onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: model.username.controller,
                      validator: model.username.textFormFieldInputValidator,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        suffixIcon: model.username.isValidating
                            ? const Padding(
                                padding: .all(12),
                                child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : (model.username.isValid && !model.username.isPure ? const Icon(Icons.check) : null),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Mode: ${model.asyncValidationMode.name}, requests: ${model.server.requestCount}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: model.isValid ? () => unawaited(_save(context, model)) : null,
                      child: const Text('Save'),
                    ),
                    const GladeFormDebugInfo<_Model>(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, _Model model) async {
    final messenger = ScaffoldMessenger.of(context);
    final isValid = await model.validateAsync();

    final _ = messenger.showSnackBar(
      SnackBar(content: Text(isValid ? 'Saved' : 'Validation failed after awaiting server')),
    );
  }
}
