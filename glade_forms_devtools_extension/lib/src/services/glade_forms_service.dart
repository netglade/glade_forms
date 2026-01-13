import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart' as serviceConnection;
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';

/// Service to communicate with the running Flutter app to get glade_forms data
class GladeFormsService {
  static const String _extensionName = 'ext.glade_forms.inspector';
  static const String _getModelsMethod = 'getModels';

  final serviceManager = serviceConnection.serviceManager;

  /// Fetch all GladeModel instances from the running app
  Future<List<GladeModelDescription>> fetchModels() async {
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        _extensionName,
        args: {'method': _getModelsMethod},
      );

      if (response.json == null) {
        return [];
      }

      final data = response.json!['models'] as List<dynamic>?;
      if (data == null) {
        return [];
      }

      return data.map((e) => GladeModelDescription.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Service extension might not be registered yet
      return [];
    }
  }

  /// Check if the service extension is available
  Future<bool> isServiceAvailable() async {
    try {
      await serviceManager.callServiceExtensionOnMainIsolate(
        _extensionName,
        args: {'method': 'ping'},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
