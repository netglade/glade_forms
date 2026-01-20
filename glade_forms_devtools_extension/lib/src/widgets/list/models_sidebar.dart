import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/widgets/list/model_list_item.dart';
import 'package:netglade_flutter_utils/netglade_flutter_utils.dart';

typedef OnChildTapCallback = void Function(GladeModelDescription model, String childId);

/// Sidebar showing the list of active models.
class ModelsSidebar extends StatelessWidget {
  final List<GladeModelDescription> models;
  final GladeModelDescription? selectedModel;
  final String? selectedChildId;
  final ValueChanged<GladeModelDescription> onModelTap;
  final OnChildTapCallback onChildTap;

  const ModelsSidebar({
    required this.models,
    required this.selectedModel,
    required this.selectedChildId,
    required this.onModelTap,
    required this.onChildTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: Constants.sidebarWidth,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const .all(Constants.spacing16),
            child: Text(
              'Active Models',
              style: theme.textTheme.titleMedium?.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];

                return ModelListItem(
                  model: model,
                  isSelected: selectedModel?.id == model.id,
                  selectedChildId: selectedChildId,
                  onTap: () => onModelTap(model),
                  onChildTap: (id) => onChildTap(model, id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
