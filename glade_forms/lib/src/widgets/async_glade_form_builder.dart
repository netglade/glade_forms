import 'package:flutter/material.dart';
import 'package:glade_forms/src/widgets/glade_model_provider.dart';
import 'package:provider/provider.dart';

import '../model/glade_model_base.dart';
import 'glade_form_builder.dart';

class AsyncGladeFormBuilder<M extends GladeModelBase> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateModelFunction<M>? create;
  final M? value;
  // ignore: prefer-correct-callback-field-name, ok name
  final GladeFormWidgetBuilder<M> builder;
  final WidgetBuilder? initializeBuilder;
  final Widget? child;

  factory AsyncGladeFormBuilder({
    required GladeFormWidgetBuilder<M> builder,
    WidgetBuilder? initializeBuilder,
    Key? key,
    Widget? child,
  }) =>
      AsyncGladeFormBuilder._(
        builder: builder,
        key: key,
        child: child,
        initializeBuilder: initializeBuilder,
      );

  const AsyncGladeFormBuilder._({
    required this.builder,
    required this.initializeBuilder,
    super.key,
    this.create,
    this.value,
    this.child,
  });

  factory AsyncGladeFormBuilder.create({
    required CreateModelFunction<M> create,
    required GladeFormWidgetBuilder<M> builder,
    WidgetBuilder? initializeBuilder,
    Widget? child,
    Key? key,
  }) =>
      AsyncGladeFormBuilder._(
        builder: builder,
        initializeBuilder: initializeBuilder,
        create: create,
        key: key,
        child: child,
      );

  factory AsyncGladeFormBuilder.value({
    required GladeFormWidgetBuilder<M> builder,
    required M value,
    WidgetBuilder? initializeBuilder,
    Widget? child,
    Key? key,
  }) =>
      AsyncGladeFormBuilder._(
        builder: builder,
        initializeBuilder: initializeBuilder,
        value: value,
        key: key,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final consumerBuilder = (context, model, child) {
      if (model.isInitialized) return builder(context, model, child);

      return initializeBuilder?.call(context) ?? CircularProgressIndicator();
    };

    if (create case final createFn?) {
      return GladeModelProvider(
        create: createFn,
        child: Consumer<M>(builder: consumerBuilder, child: child),
      );
    } else if (value case final modelValue?) {
      return GladeModelProvider.value(
        value: modelValue,
        child: Consumer<M>(builder: consumerBuilder, child: child),
      );
    }

    return Consumer<M>(builder: consumerBuilder, child: child);
  }
}
