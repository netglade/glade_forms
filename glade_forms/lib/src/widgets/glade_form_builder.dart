import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/model.dart';
import 'package:glade_forms/src/widgets/glade_model_provider.dart';
import 'package:provider/provider.dart';

typedef GladeFormWidgetBuilder<M extends GladeModelBase> = Widget Function(
  BuildContext context,
  M model,
  Widget? child,
);

class GladeFormBuilder<M extends GladeModelBase> extends StatelessWidget {
  final CreateModelFunction<M>? create;
  final M? value;
  final GladeFormWidgetBuilder<M> builder;
  final Widget loadingWidget;
  final Widget? child;

  factory GladeFormBuilder({
    required GladeFormWidgetBuilder<M> builder,
    Widget loadingWidget = const Center(child: CircularProgressIndicator()),
    Key? key,
    Widget? child,
  }) =>
      GladeFormBuilder._(builder: builder, loadingWidget: loadingWidget, key: key, child: child);

  const GladeFormBuilder._({
    required this.builder,
    required this.loadingWidget,
    super.key,
    this.create,
    this.value,
    this.child,
  });

  factory GladeFormBuilder.create({
    required CreateModelFunction<M> create,
    required GladeFormWidgetBuilder<M> builder,
    Widget loadingWidget = const Center(child: CircularProgressIndicator()),
    Widget? child,
    Key? key,
  }) =>
      GladeFormBuilder._(
        builder: builder,
        loadingWidget: loadingWidget,
        create: create,
        key: key,
        child: child,
      );

  factory GladeFormBuilder.value({
    required GladeFormWidgetBuilder<M> builder,
    required M value,
    Widget loadingWidget = const Center(child: CircularProgressIndicator()),
    Widget? child,
    Key? key,
  }) =>
      GladeFormBuilder._(
        builder: builder,
        value: value,
        loadingWidget: loadingWidget,
        key: key,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    // if(!value.isInitialized)
    if (create case final createFn?) {
      return GladeModelProvider(
        create: createFn,
        child: Consumer<M>(
          builder: (context, model, ch) => model.isInitialized ? builder(context, model, ch) : loadingWidget,
          child: child,
        ),
      );
    } else if (value case final modelValue?) {
      return GladeModelProvider.value(
        value: modelValue,
        child: Consumer<M>(
          builder: (context, model, ch) => model.isInitialized ? builder(context, model, ch) : loadingWidget,
          child: child,
        ),
      );
    }

    return Consumer<M>(
      builder: (context, model, ch) => model.isInitialized ? builder(context, model, ch) : loadingWidget,
      child: child,
    );
  }
}
