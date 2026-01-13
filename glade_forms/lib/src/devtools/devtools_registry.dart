import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/core/core.dart';
import 'package:glade_forms/src/model/glade_model.dart';

/// Registry to track active GladeModel instances for DevTools inspection
class GladeFormsDevToolsRegistry {
  static final GladeFormsDevToolsRegistry _instance = GladeFormsDevToolsRegistry._();

  final Map<String, GladeModel> _models = {};

  /// Get all registered models
  Map<String, GladeModel> get models => Map.unmodifiable(_models);

  factory GladeFormsDevToolsRegistry() => _instance;

  GladeFormsDevToolsRegistry._() {
    _registerServiceExtension();
  }

  /// Register a GladeModel instance
  void registerModel(String id, GladeModel model) {
    _models[id] = model;
  }

  /// Unregister a GladeModel instance
  void unregisterModel(String id) {
    _models.remove(id);
  }

  void _registerServiceExtension() {
    if (kReleaseMode) {
      return; // Only available in debug mode
    }

    developer.registerExtension(
      'ext.glade_forms.inspector',
      (method, parameters) async {
        final methodParam = parameters['method'];

        if (methodParam == 'ping') {
          return developer.ServiceExtensionResponse.result(
            json.encode({'status': 'ok'}),
          );
        }

        if (methodParam == 'getModels') {
          final modelsData = _models.entries.map((entry) {
            return _serializeModel(entry.key, entry.value);
          }).toList();

          return developer.ServiceExtensionResponse.result(
            json.encode({'models': modelsData}),
          );
        }

        if (methodParam == 'getModel') {
          final id = parameters['id'];
          if (id == null || !_models.containsKey(id)) {
            return developer.ServiceExtensionResponse.error(
              developer.ServiceExtensionResponse.invalidParams,
              'Model not found',
            );
          }

          final modelData = _serializeModel(id, _models[id]!);

          return developer.ServiceExtensionResponse.result(
            json.encode({'model': modelData}),
          );
        }

        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Unknown method: $methodParam',
        );
      },
    );
  }

  Map<String, dynamic> _serializeModel(String id, GladeModel model) {
    return {
      'formattedErrors': model.formattedValidationErrors,
      'id': id,
      'inputs': model.inputs.map(_serializeInput).toList(),
      'isDirty': model.isDirty,
      'isPure': model.isPure,
      'isUnchanged': model.isUnchanged,
      'isValid': model.isValid,
      'type': model.runtimeType.toString(),
    };
  }

  Map<String, dynamic> _serializeInput(GladeInput<dynamic> input) {
    return {
      'errors': input.validationErrors.map((e) => e.toString()).toList(),
      'hasConversionError': input.hasConversionError,
      'initialValue': input.initialValue?.toString(),
      'isPure': input.isPure,
      'isUnchanged': input.isUnchanged,
      'isValid': input.isValid,
      'key': input.inputKey,
      'type': input.runtimeType.toString(),
      'value': input.stringValue,
      'warnings': input.validationWarnings.map((e) => e.toString()).toList(),
    };
  }
}
