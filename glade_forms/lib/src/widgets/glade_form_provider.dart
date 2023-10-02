import 'package:flutter/widgets.dart';
import 'package:glade_forms/src/core/mutable_generic_model.dart';
import 'package:provider/provider.dart';

typedef CreateModelFunction<M extends MutableGenericModel> = M Function(BuildContext context);

class GladeFormProvider<M extends MutableGenericModel> extends StatelessWidget {
  final CreateModelFunction<M>? create;
  final M? value;
  final Widget child;

  factory GladeFormProvider({required CreateModelFunction<M> create, required Widget child}) =>
      GladeFormProvider._(create: create, child: child);

  const GladeFormProvider._({
    required this.child,
    this.create,
    this.value,
    super.key,
  });

  factory GladeFormProvider.value({required M value, required Widget child}) =>
      GladeFormProvider._(value: value, child: child);

  @override
  Widget build(BuildContext context) {
    if (value case final x?) {
      return ChangeNotifierProvider.value(value: x, child: child);
    }

    return ChangeNotifierProvider<M>(create: create!, child: child);
  }
}
