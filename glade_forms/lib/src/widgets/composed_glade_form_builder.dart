import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/composed_glade_model.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

typedef ComposedGladeListItemBuilder<M extends GladeModel> = Widget Function(
  BuildContext context,
  M itemModel,
  int index,
);

typedef Builder = Widget Function(BuildContext context);

class ComposedGladeFormBuilder<C extends ComposedGladeModel<M>, M extends GladeModel> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateComposedModelFunction<C>? create;
  final C? value;
  final ComposedGladeListItemBuilder<M> itemBuilder;
  final Builder? bottomBuilder;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool shrinkWrap;

  factory ComposedGladeFormBuilder({
    required ComposedGladeListItemBuilder<M> itemBuilder,
    Key? key,
    Builder? bottomBuilder,
  }) =>
      ComposedGladeFormBuilder._(itemBuilder: itemBuilder, key: key, bottomBuilder: bottomBuilder);

  factory ComposedGladeFormBuilder.create({
    required CreateComposedModelFunction<C> create,
    required ComposedGladeListItemBuilder<M> itemBuilder,
    Builder? bottomBuilder,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    Key? key,
  }) {
    return ComposedGladeFormBuilder._(
      create: create,
      itemBuilder: itemBuilder,
      physics: physics,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      key: key,
      bottomBuilder: bottomBuilder,
    );
  }

  factory ComposedGladeFormBuilder.value({
    required C value,
    required ComposedGladeListItemBuilder<M> itemBuilder,
    Builder? bottomBuilder,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    Key? key,
  }) {
    return ComposedGladeFormBuilder._(
      value: value,
      itemBuilder: itemBuilder,
      physics: physics,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      key: key,
      bottomBuilder: bottomBuilder,
    );
  }

  const ComposedGladeFormBuilder._({
    required this.itemBuilder,
    this.bottomBuilder,
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
      return ComposedGladeModelProvider<C, M>(
        create: createFn,
        child: _ComposedGladeFormList<C, M>(
          scrollDirection: scrollDirection,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemBuilder: itemBuilder,
          bottomBuilder: bottomBuilder,
        ),
      );
    } else if (value case final modelValue?) {
      return ComposedGladeModelProvider<C, M>.value(
        value: modelValue,
        child: _ComposedGladeFormList<C, M>(
          scrollDirection: scrollDirection,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemBuilder: itemBuilder,
          bottomBuilder: bottomBuilder,
        ),
      );
    }

    return _ComposedGladeFormList<C, M>(
      scrollDirection: scrollDirection,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemBuilder: itemBuilder,
      bottomBuilder: bottomBuilder,
    );
  }
}

class _ComposedGladeFormList<C extends ComposedGladeModel<M>, M extends GladeModel> extends StatelessWidget {
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ComposedGladeListItemBuilder<M> itemBuilder;
  final Builder? bottomBuilder;

  const _ComposedGladeFormList({
    required this.itemBuilder,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.shrinkWrap = false,
    this.bottomBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<C>(
      builder: (context, composedModel, _) {
        final models = composedModel.models;

        return CustomScrollView(
          physics: physics,
          scrollDirection: scrollDirection,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final itemModel = models.elementAtOrNull(index);

                  if (itemModel == null) return const SizedBox.shrink();

                  return GladeModelProvider<M>.value(
                    value: itemModel,
                    child: Consumer<M>(
                      builder: (context, model, _) => itemBuilder(context, model, index),
                    ),
                  );
                },
                childCount: models.length,
              ),
            ),
            if (bottomBuilder != null)
              SliverToBoxAdapter(
                child: Consumer<C>(
                  builder: (context, _, __) => bottomBuilder?.call(context) ?? const SizedBox.shrink(),
                ),
              ),
          ],
        );
      },
    );
  }
}
