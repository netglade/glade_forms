import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:provider/provider.dart';

typedef GladeFormListenerFn<M extends GladeModel> = void Function(
  BuildContext context,
  M model,
  List<String> lastUpdatedInputKey,
);

class GladeFormListener<M extends GladeModel> extends StatefulWidget {
  final Widget child;
  final GladeFormListenerFn<M> listener;

  const GladeFormListener({
    required this.listener,
    required this.child,
    super.key,
  });

  @override
  State<GladeFormListener<M>> createState() => _GladeFormListenerState<M>();
}

class _GladeFormListenerState<M extends GladeModel> extends State<GladeFormListener<M>> {
  M? _model;

  @override
  void initState() {
    super.initState();
    context.read<M>().addListener(_onModelUpdate);
  }

  @override
  void dispose() {
    _model?.removeListener(_onModelUpdate);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _model = context.read<M>();
    super.didChangeDependencies();
  }

  void _onModelUpdate() {
    final m = context.read<M>();
    widget.listener(context, m, m.lastUpdatedInputKeys);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
