import 'package:flutter/material.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/widgets/glade_form_provider.dart';
import 'package:provider/provider.dart';

typedef GladeFormWidgetBuilder<M extends GladeModel> = Widget Function(BuildContext context, M model);

class GladeFormBuilder<M extends GladeModel> extends StatelessWidget {
  final CreateModelFunction<M>? create;
  final M? value;
  final GladeFormWidgetBuilder<M> builder;

  factory GladeFormBuilder({
    required CreateModelFunction<M> create,
    required GladeFormWidgetBuilder<M> builder,
    Key? key,
  }) =>
      GladeFormBuilder._(builder: builder, create: create, key: key);

  const GladeFormBuilder._({
    required this.builder,
    super.key,
    this.create,
    this.value,
  });

  factory GladeFormBuilder.value({
    required GladeFormWidgetBuilder<M> builder,
    required M value,
    Key? key,
  }) =>
      GladeFormBuilder._(builder: builder, value: value, key: key);

  @override
  Widget build(BuildContext context) {
    if (create case final createFn?) {
      return GladeFormProvider(
        create: createFn,
        child: Consumer<M>(
          builder: (context, model, _) => builder(context, model),
        ),
      );
    } else if (value case final modelValue?) {
      return GladeFormProvider.value(
        value: modelValue,
        child: Consumer<M>(
          builder: (context, model, _) => builder(context, model),
        ),
      );
    }

    return Consumer<M>(
      builder: (context, model, _) => builder(context, model),
    );
  }
}
