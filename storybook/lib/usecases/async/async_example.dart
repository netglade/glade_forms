import 'package:flutter/material.dart';
import 'package:glade_forms/glade_forms.dart';
import 'package:glade_forms_storybook/shared/usecase_container.dart';

class _Model extends AsyncGladeModel {
  late AsyncGladeInput<String> name;

  @override
  List<GladeInputBase<Object?>> get inputs => [name];

  _Model();

  @override
  Future<void> initializeInputs() async {
    final initialValue = await Future.delayed(Duration(milliseconds: 1000), () => Future.value('hello async'));

    name = AsyncGladeInput.create(
      initialValue: initialValue,
      validator: ((v) => (v
            ..satisfyAsync(
              (x) async {
                final _ = await Future.delayed(Duration(milliseconds: 800));

                return x.length > 5;
              },
              key: 'length5',
              devError: (value) => 'Value must be at least 5 characters long',
            ))
          .build()),
    );
  }
}

class AsyncExample extends StatelessWidget {
  const AsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UsecaseContainer(
      shortDescription: 'Async example',
      child: AsyncGladeFormBuilder.create(
        // ignore: avoid-undisposed-instances, handled by GladeFormBuilder
        create: (context) => _Model(),
        initializeBuilder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text('Model is loading'),
            ],
          ),
        ),
        builder: (context, model, _) => Padding(
          padding: EdgeInsets.all(32),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AsyncTextField(
              validator: model.name.textFormFieldInputValidatorAsync,
            ),
          ),
        ),
      ),
    );
  }
}
