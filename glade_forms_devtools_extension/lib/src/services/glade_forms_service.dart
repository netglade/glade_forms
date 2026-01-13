import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart' as serviceConnection;
import 'package:glade_forms_devtools_extension/src/models/form_model_data.dart';

/// Service to communicate with the running Flutter app to get glade_forms data
class GladeFormsService {
  static const String _extensionName = 'ext.glade_forms.inspector';
  static const String _getModelsMethod = 'getModels';
  static const String _getModelMethod = 'getModel';

  final serviceManager = serviceConnection.serviceManager;

  /// Fetch all GladeModel instances from the running app
  Future<List<FormModelData>> fetchModels() async {
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

      return data.map((e) => FormModelData.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Service extension might not be registered yet
      return [];
    }
  }

  /// Fetch a specific GladeModel by ID
  Future<FormModelData?> fetchModel(String id) async {
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        _extensionName,
        args: {
          'method': _getModelMethod,
          'id': id,
        },
      );

      if (response.json == null || response.json!['model'] == null) {
        return null;
      }

      return FormModelData.fromJson(
        response.json!['model'] as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
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
