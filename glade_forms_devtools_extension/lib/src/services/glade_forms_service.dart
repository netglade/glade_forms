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
      print('[GladeFormsService] Calling getModels...');

      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        _extensionName,
        args: {'method': _getModelsMethod},
      );

      print('[GladeFormsService] Response received: ${response.json}');

      if (response.json == null) {
        print('[GladeFormsService] Response JSON is null');
        return [];
      }

      final data = response.json!['models'] as List<dynamic>?;
      if (data == null) {
        print('[GladeFormsService] Models key not found or is null');
        return [];
      }

      print('[GladeFormsService] Parsing ${data.length} models');

      final models = data.map((e) => GladeModelDescription.fromJson(e as Map<String, dynamic>)).toList();

      print('[GladeFormsService] Successfully parsed ${models.length} models');

      return models;
    } catch (e, stackTrace) {
      print('[GladeFormsService] Error fetching models: $e');
      print('[GladeFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if the service extension is available
  Future<bool> isServiceAvailable() async {
    try {
      print('[GladeFormsService] Checking if service is available (ping)...');

      await serviceManager.callServiceExtensionOnMainIsolate(
        _extensionName,
        args: {'method': 'ping'},
      );

      print('[GladeFormsService] Service ping successful');
      return true;
    } catch (e) {
      print('[GladeFormsService] Service ping failed: $e');
      return false;
    }
  }
}
