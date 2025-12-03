import 'package:flutter/material.dart';
import 'package:glade_forms/src/src.dart';
import 'package:provider/provider.dart';

typedef GladeComposedFormListenerFn<C extends GladeComposedModel> = void Function(
  BuildContext context,
  C model,
);

class GladeComposedFormListener<C extends GladeComposedModel> extends StatefulWidget {
  final Widget child;
  // ignore: prefer-correct-callback-field-name, ok name
  final GladeComposedFormListenerFn<C> listener;

  const GladeComposedFormListener({required this.child, required this.listener, super.key});

  @override
  State<GladeComposedFormListener<C>> createState() => _GladeComposedModelListenerState();
}

class _GladeComposedModelListenerState<C extends GladeComposedModel> extends State<GladeComposedFormListener<C>> {
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
