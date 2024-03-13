import 'package:flutter/material.dart';
import 'package:glade_forms/src/core/core.dart';

//todo for now always validate on user interaction.
class AsyncGladeFormField<T> extends StatefulWidget {
  final AsyncGladeInput<T> input;
  final VoidCallback? onValidation;

  const AsyncGladeFormField({
    required this.input,
    super.key,
    this.onValidation,
  });

  @override
  State<AsyncGladeFormField> createState() => _AsyncGladeFormFieldState();
}

class _AsyncGladeFormFieldState extends State<AsyncGladeFormField> {
  bool isValidating = false;
  String? validationError;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.input.controller,
      // ignore: prefer-extracting-callbacks, asdsasa asdas.
      validator: (value) {
        if (isValidating) return null;

        return validationError;
      },
      // ignore: prefer-extracting-callbacks, should be ok., avoid-passing-async-when-sync-expected
      onChanged: (value) async {
        setState(() {
          isValidating = true;
        });
        await widget.input.updateValueWithStringAsync(value);
        final validation = await widget.input.textFormFieldInputValidator(value);

        if (context.mounted) {
          setState(() {
            validationError = validation;
            isValidating = false;
          });
        }
      },
    );
  }
}
