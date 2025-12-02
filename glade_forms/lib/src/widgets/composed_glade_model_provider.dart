import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/src.dart';
import 'package:provider/provider.dart';

typedef CreateComposedModelFunction<C extends ComposedGladeModel> = C Function(
  BuildContext context,
);

class ComposedGladeModelProvider<C extends ComposedGladeModel<M>, M extends GladeModel> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateComposedModelFunction<C>? create;
  final C? value;
  final Widget child;

  factory ComposedGladeModelProvider({
    required CreateComposedModelFunction<C> create,
    required Widget child,
    Key? key,
  }) =>
      ComposedGladeModelProvider._(create: create, key: key, child: child);

  const ComposedGladeModelProvider._({
    required this.child,
    this.create,
    this.value,
    super.key,
  });

  factory ComposedGladeModelProvider.value({
    required C value,
    required Widget child,
    Key? key,
  }) =>
      ComposedGladeModelProvider._(value: value, key: key, child: child);

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
