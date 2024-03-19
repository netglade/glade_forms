import 'package:flutter/material.dart';
import 'package:glade_forms/src/model/glade_model.dart';
import 'package:glade_forms/src/widgets/glade_model_debug_info.dart';
import 'package:glade_forms/src/widgets/glade_model_provider.dart';

class GladeModelDebugInfoModal {
  const GladeModelDebugInfoModal();
  static void showDebugInfoModel<M extends GladeModel>(BuildContext context, M model) {
    final _ = showModalBottomSheet<void>(
      context: context,
      builder: (builderContext) => GladeModelProvider.value(
        value: model,
        child: BottomSheet(onClosing: () {}, builder: (context) => const GladeModelDebugInfo()),
      ),
    );
  }
}
