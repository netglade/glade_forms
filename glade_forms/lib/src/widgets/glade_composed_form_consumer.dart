import 'package:flutter/material.dart';
import 'package:glade_forms/src/src.dart';

class GladeComposedFormConsumer<C extends GladeComposedModel> extends StatelessWidget {
  final GladeComposedWidgetBuilder<C> builder;
  // ignore: prefer-correct-callback-field-name, ok name
  final GladeComposedFormListenerFn<C>? listener;
  final Widget? child;

  const GladeComposedFormConsumer({
    required this.builder,
    super.key,
    this.listener,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (listener case final listenerValue?) {
      return GladeComposedFormListener<C>(
        listener: listenerValue,
        child: GladeComposedFormBuilder<C>(builder: builder, child: child),
      );
    }

    return GladeFormBuilder(builder: builder, child: child);
  }
}
