import 'package:flutter/material.dart';
import 'package:glade_forms/src/src.dart';
import 'package:provider/provider.dart';

typedef ComposedGladeModelListenerFn<C extends ComposedGladeModel> = void Function(
  BuildContext context,
  C model,
);

class ComposedGladeModelListener<C extends ComposedGladeModel> extends StatefulWidget {
  final Widget child;
  // ignore: prefer-correct-callback-field-name, ok name
  final ComposedGladeModelListenerFn<C> listener;

  const ComposedGladeModelListener({required this.child, required this.listener, super.key});

  @override
  State<ComposedGladeModelListener<C>> createState() => _ComposedGladeModelListenerState();
}

class _ComposedGladeModelListenerState<C extends ComposedGladeModel> extends State<ComposedGladeModelListener<C>> {
  C? _model;

  @override
  void initState() {
    super.initState();
    context.read<C>().addListener(_onModelUpdate);
  }

  @override
  void dispose() {
    _model?.removeListener(_onModelUpdate);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _model = context.read<C>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onModelUpdate() {
    final m = context.read<C>();
    widget.listener(context, m);
  }
}
