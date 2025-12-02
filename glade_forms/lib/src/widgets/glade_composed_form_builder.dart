import 'package:flutter/material.dart';
import 'package:glade_forms/src/src.dart';
import 'package:provider/provider.dart';

typedef GladeComposedWidgetBuilder<C extends ComposedGladeModel> = Widget Function(
  BuildContext context,
  C model,
  Widget? child,
);

class GladeComposedFormBuilder<C extends ComposedGladeModel> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateComposedModelFunction<C>? create;
  final C? value;
  final GladeComposedWidgetBuilder<C> builder;
  final Widget? child;

  factory GladeComposedFormBuilder({
    required GladeComposedWidgetBuilder<C> builder,
    Key? key,
    Widget? child,
  }) =>
      GladeComposedFormBuilder._(builder: builder, key: key, child: child);

  const GladeComposedFormBuilder._({
    required this.builder,
    super.key,
    this.create,
    this.value,
    this.child,
  });

  factory GladeComposedFormBuilder.create({
    required CreateComposedModelFunction<C> create,
    required GladeComposedWidgetBuilder<C> builder,
    Widget? child,
    Key? key,
  }) =>
      GladeComposedFormBuilder._(
        builder: builder,
        create: create,
        key: key,
        child: child,
      );

  factory GladeComposedFormBuilder.value({
    required GladeComposedWidgetBuilder<C> builder,
    required C value,
    Widget? child,
    Key? key,
  }) =>
      GladeComposedFormBuilder._(
        builder: builder,
        value: value,
        key: key,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    if (create case final createFn?) {
      return GladeComposedModelProvider(
        create: createFn,
        child: Consumer<C>(builder: builder, child: child),
      );
    } else if (value case final modelValue?) {
      return GladeComposedModelProvider.value(
        value: modelValue,
        child: Consumer<C>(builder: builder, child: child),
      );
    }

    return Consumer<C>(builder: builder, child: child);
  }
}
