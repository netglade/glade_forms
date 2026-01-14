import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:glade_forms/src/devtools/devtools_serialization.dart';
import 'package:glade_forms/src/model/glade_composed_model.dart';
import 'package:glade_forms/src/model/glade_model_base.dart';

/// Registry to track active GladeModel instances for DevTools inspection.
// ignore: prefer-match-file-name, keep name as is
class GladeFormsDevToolsRegistry {
  static GladeFormsDevToolsRegistry? _instance;

  final Map<String, GladeModelBase> _models = {};
  final Set<String> _childModelIds = {};

  /// Get all registered models (excluding child models of composed models).
  Map<String, GladeModelBase> get models => Map.unmodifiable(
        Map.fromEntries(_models.entries.where((e) => !_childModelIds.contains(e.key))),
      );

  factory GladeFormsDevToolsRegistry() {
    if (_instance == null) {
      throw StateError(
        'GladeForms.initialize() must be called before using GladeModel. Add GladeForms.initialize() in your main() method.',
      );
    }

    // ignore: avoid-non-null-assertion, checked above
    return _instance!;
  }

  GladeFormsDevToolsRegistry._() {
    _registerServiceExtension();
  }

  /// Initialize the registry and register DevTools service extension.
  static void initialize() {
    _instance ??= GladeFormsDevToolsRegistry._();
  }

  /// Register a GladeModel instance.
  void registerModel(String id, GladeModelBase model) {
    _models[id] = model;
  }

  /// Unregister a GladeModel instance.
  void unregisterModel(String id) {
    final _ = _models.remove(id);
  }

  void _registerServiceExtension() {
    if (kReleaseMode) {
      return; // DevTools integration only available in debug mode.
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
          // Clear and rebuild child model IDs
          _childModelIds.clear();

          // First pass: serialize all models to populate _childModelIds
          final allModelsData = _models.entries.map((entry) => _serializeModel(entry.key, entry.value)).toList();

          // Second pass: filter out child models
          // ignore: avoid-collection-methods-with-unrelated-types, should be ok
          final modelsData = allModelsData.where((modelData) => !_childModelIds.contains(modelData['id'])).toList();

          return developer.ServiceExtensionResponse.result(
            json.encode({'models': modelsData}),
          );
        }

        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Unknown method: ${methodParam ?? "null"}',
        );
      },
    );
  }

  Map<String, dynamic> _serializeModel(String id, GladeModelBase model) {
    final isComposed = model is GladeComposedModel;
    final baseData = model.toDevToolsJson();

    return {
      ...baseData,
      'id': id,
      'isComposed': isComposed,
      'childModels': isComposed
          ? model.models.asMap().entries.map((entry) {
              return _serializeChildModel(entry.key, entry.value);
            }).toList()
          : <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _serializeChildModel(int index, GladeModelBase model) {
    final childId = '${model.runtimeType}_${identityHashCode(model)}';
    final _ = _childModelIds.add(childId);

    final baseData = model.toDevToolsJson();

    return {...baseData, 'id': childId, 'index': index};
  }
}
