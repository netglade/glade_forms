import 'package:flutter/material.dart';

class AsyncTextField<T> extends StatefulWidget {
  const AsyncTextField({super.key});

  @override
  State<AsyncTextField<T>> createState() => _AsyncTextFieldState<T>();
}

class _AsyncTextFieldState<T> extends State<AsyncTextField<T>> {
  bool isValidating = false;

  String? validationMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (isValidating) return 'Validating...';

                    return validationMessage;
                  },
                  onChanged: (value) async {
                    setState(() {
                      validationMessage = null;
                      isValidating = true;
                    });

                    await Future.delayed(const Duration(milliseconds: 1000));

                    setState(() {
                      validationMessage = 'Error';
                      isValidating = false;
                      // _formKey.currentState?.validate();
                    });
                  },
                ),
              ),
              Visibility(
                visible: isValidating,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
          Text(validationMessage ?? '...'),
        ],
      ),
    );
  }
}
