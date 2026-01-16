import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart' as service_connection;
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';

/// Service to communicate with the running Flutter app to get glade_forms data.
class GladeFormsService {
  final serviceManager = service_connection.serviceManager;
  static const String _extensionName = 'ext.glade_forms.inspector';

  static const String _getModelsMethod = 'getModels';

  /// Fetch all GladeModel instances from the running app
  Future<List<GladeModelDescription>> fetchModels() async {
    final response = await serviceManager.callServiceExtensionOnMainIsolate(
      _extensionName,
      args: {'method': _getModelsMethod},
    );
    if (response.json == null) {
      return [];
    }

    // ignore: avoid-dynamic,  avoid-non-null-assertion, checked by condition and can be anything,
    final data = response.json!['models'] as List<dynamic>?;
    if (data == null) {
      return [];
    }

    return data.map((e) => GladeModelDescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Check if the service extension is available.
  Future<bool> isServiceAvailable() async {
    try {
      final _ = await serviceManager.callServiceExtensionOnMainIsolate(
        _extensionName,
        args: {'method': 'ping'},
      );

      return true;
      // ignore: avoid_catches_without_on_clauses, since we want to catch all errors
    } catch (e) {
      return false;
    }
  }
}
