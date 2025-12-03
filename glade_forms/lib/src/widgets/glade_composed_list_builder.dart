import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_composed_model.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

typedef GladeComposedListItemBuilder<C extends GladeComposedModel<M>, M extends GladeModel> = Widget Function(
  BuildContext context,
  C composedModel,
  M itemModel,
  int index,
);

typedef Builder = Widget Function(BuildContext context);

class GladeComposedListBuilder<C extends GladeComposedModel<M>, M extends GladeModel> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateComposedModelFunction<C>? create;
  final C? value;
  final GladeComposedListItemBuilder<C, M> itemBuilder;
  final Widget? child;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool shrinkWrap;

  factory GladeComposedListBuilder({
    required GladeComposedListItemBuilder<C, M> itemBuilder,
    Key? key,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    Widget? child,
  }) =>
      GladeComposedListBuilder._(
        itemBuilder: itemBuilder,
        key: key,
        physics: physics,
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
        child: child,
      );

  factory GladeComposedListBuilder.create({
    required CreateComposedModelFunction<C> create,
    required GladeComposedListItemBuilder<C, M> itemBuilder,
    Widget? child,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    Key? key,
  }) {
    return GladeComposedListBuilder._(
      create: create,
      itemBuilder: itemBuilder,
      physics: physics,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      key: key,
      child: child,
    );
  }

  factory GladeComposedListBuilder.value({
    required C value,
    required GladeComposedListItemBuilder<C, M> itemBuilder,
    Widget? child,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    Key? key,
  }) {
    return GladeComposedListBuilder._(
      value: value,
      itemBuilder: itemBuilder,
      physics: physics,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      key: key,
      child: child,
    );
  }

  const GladeComposedListBuilder._({
    required this.itemBuilder,
    this.child,
    this.create,
    this.value,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // choose provider style: create/value
    if (create case final createFn?) {
      return GladeComposedModelProvider<C, M>(
        create: createFn,
        child: _GladeComposedFormList<C, M>(
          scrollDirection: scrollDirection,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemBuilder: itemBuilder,
          child: child,
        ),
      );
    }

    if (value case final modelValue?) {
      return GladeComposedModelProvider<C, M>.value(
        value: modelValue,
        child: _GladeComposedFormList<C, M>(
          scrollDirection: scrollDirection,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemBuilder: itemBuilder,
          child: child,
        ),
      );
    }

    return _GladeComposedFormList<C, M>(
      scrollDirection: scrollDirection,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemBuilder: itemBuilder,
      child: child,
    );
  }
}

class _GladeComposedFormList<C extends GladeComposedModel<M>, M extends GladeModel> extends StatelessWidget {
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final GladeComposedListItemBuilder<C, M> itemBuilder;
  final Widget? child;

  const _GladeComposedFormList({
    required this.itemBuilder,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.shrinkWrap = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<C>(
      builder: (context, composedModel, _) {
        final models = composedModel.models;

        return CustomScrollView(
          physics: physics,
          scrollDirection: scrollDirection,
          shrinkWrap: shrinkWrap,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final itemModel = models.elementAtOrNull(index);

                  if (itemModel == null) return const SizedBox.shrink();

                  return GladeModelProvider<M>.value(
                    value: itemModel,
                    child: Consumer<M>(
                      builder: (context, model, _) => itemBuilder(context, composedModel, model, index),
                    ),
                  );
                },
                childCount: models.length,
              ),
            ),
            if (child != null) SliverToBoxAdapter(child: child),
          ],
        );
      },
    );
  }
}
