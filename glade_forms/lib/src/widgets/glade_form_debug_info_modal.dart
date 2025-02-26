import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/widgets/glade_form_debug_info.dart';
import 'package:glade_forms/src/widgets/glade_model_provider.dart';

abstract final class GladeFormDebugInfoModal {
  const GladeFormDebugInfoModal();

  static void show<M extends GladeModel>(BuildContext context, M model) {
    final _ = showModalBottomSheet<void>(
      context: context,
      builder: (builderContext) => GladeModelProvider.value(
        value: model,
        // ignore: no-empty-block, empty is ok.
        child: BottomSheet(onClosing: () {}, builder: (context) => const GladeFormDebugInfo()),
      ),
    );
  }
}
