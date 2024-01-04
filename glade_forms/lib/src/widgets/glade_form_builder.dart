import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/model.dart';
import 'package:glade_forms/src/widgets/glade_model_provider.dart';
import 'package:provider/provider.dart';

typedef GladeFormWidgetBuilder<M extends GladeModelBase> = Widget Function(BuildContext context, M model, Widget? child);

class GladeFormBuilder<M extends GladeModelBase> extends StatelessWidget {
  final CreateModelFunction<M>? create;
  final M? value;
  final GladeFormWidgetBuilder<M> builder;
  final Widget? child;

  factory GladeFormBuilder({
    required GladeFormWidgetBuilder<M> builder,
    Key? key,
    Widget? child,
  }) =>
      GladeFormBuilder._(builder: builder, key: key, child: child);

  const GladeFormBuilder._({
    required this.builder,
    super.key,
    this.create,
    this.value,
    this.child,
  });

  factory GladeFormBuilder.create({
    required CreateModelFunction<M> create,
    required GladeFormWidgetBuilder<M> builder,
    Widget? child,
    Key? key,
  }) =>
      GladeFormBuilder._(
        builder: builder,
        create: create,
        key: key,
        child: child,
      );

  factory GladeFormBuilder.value({
    required GladeFormWidgetBuilder<M> builder,
    required M value,
    Widget? child,
    Key? key,
  }) =>
      GladeFormBuilder._(
        builder: builder,
        value: value,
        key: key,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    if (create case final createFn?) {
      return GladeModelProvider(
        create: createFn,
        child: Consumer<M>(builder: builder, child: child),
      );
    } else if (value case final modelValue?) {
      return GladeModelProvider.value(
        value: modelValue,
        child: Consumer<M>(builder: builder, child: child),
      );
    }

    return Consumer<M>(builder: builder, child: child);
  }
}
