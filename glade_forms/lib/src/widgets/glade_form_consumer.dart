import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/src.dart';

class GladeFormConsumer<M extends GladeModelBase> extends StatelessWidget {
  final GladeFormWidgetBuilder<M> builder;
  // ignore: prefer-correct-callback-field-name, ok name
  final GladeFormListenerFn<M>? listener;
  final Widget? child;

  const GladeFormConsumer({
    required this.builder,
    super.key,
    this.listener,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (listener case final listenerValue?) {
      return GladeFormListener<M>(
        listener: listenerValue,
        child: GladeFormBuilder<M>(builder: builder, child: child),
      );
    }

    return GladeFormBuilder(builder: builder, child: child);
  }
}
