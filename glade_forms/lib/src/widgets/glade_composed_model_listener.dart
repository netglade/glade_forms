import 'package:flutter/material.dart';
import 'package:glade_forms/src/src.dart';
import 'package:provider/provider.dart';

typedef GladeComposedModelListenerFn<C extends GladeComposedModel> = void Function(
  BuildContext context,
  C model,
);

class GladeComposedModelListener<C extends GladeComposedModel> extends StatefulWidget {
  final Widget child;
  // ignore: prefer-correct-callback-field-name, ok name
  final GladeComposedModelListenerFn<C> listener;

  const GladeComposedModelListener({required this.child, required this.listener, super.key});

  @override
  State<GladeComposedModelListener<C>> createState() => _GladeComposedModelListenerState();
}

class _GladeComposedModelListenerState<C extends GladeComposedModel> extends State<GladeComposedModelListener<C>> {
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
