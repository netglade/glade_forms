import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:provider/provider.dart';

typedef CreateModelFunction<M extends GladeModel> = M Function(BuildContext context);

class GladeModelProvider<M extends GladeModel> extends StatelessWidget {
  // ignore: prefer-correct-callback-field-name, ok name
  final CreateModelFunction<M>? create;
  final M? value;
  final Widget child;

  factory GladeModelProvider({required CreateModelFunction<M> create, required Widget child, Key? key}) =>
      GladeModelProvider._(create: create, key: key, child: child);

  const GladeModelProvider._({
    required this.child,
    this.create,
    this.value,
    super.key,
  });

  factory GladeModelProvider.value({required M value, required Widget child, Key? key}) =>
      GladeModelProvider._(value: value, key: key, child: child);

  @override
  Widget build(BuildContext context) {
    if (value case final x?) {
      return ChangeNotifierProvider.value(value: x, child: child);
    }

    // ignore: avoid-non-null-assertion, when value is null, it is guaranteed that create is not null.
    return ChangeNotifierProvider<M>(create: create!, child: child);
  }
}
