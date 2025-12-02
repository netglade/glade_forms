import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/src.dart';
import 'package:provider/provider.dart';

typedef CreateComposedModelFunction<C extends GladeComposedModel> = C Function(
  BuildContext context,
);

class GladeComposedModelProvider<C extends GladeComposedModel<M>, M extends GladeModel> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateComposedModelFunction<C>? create;
  final C? value;
  final Widget child;

  factory GladeComposedModelProvider({
    required CreateComposedModelFunction<C> create,
    required Widget child,
    Key? key,
  }) =>
      GladeComposedModelProvider._(create: create, key: key, child: child);

  const GladeComposedModelProvider._({
    required this.child,
    this.create,
    this.value,
    super.key,
  });

  factory GladeComposedModelProvider.value({
    required C value,
    required Widget child,
    Key? key,
  }) =>
      GladeComposedModelProvider._(value: value, key: key, child: child);

  @override
  Widget build(BuildContext context) {
    if (value case final existing?) {
      return ChangeNotifierProvider<C>.value(value: existing, child: child);
    }

    return ChangeNotifierProvider<C>(
      // ignore: avoid-non-null-assertion, when value is null, it is guaranteed that create is not null.
      create: (context) => create!(context),
      child: child,
    );
  }
}
