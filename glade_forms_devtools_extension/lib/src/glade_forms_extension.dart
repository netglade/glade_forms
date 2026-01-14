import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/constants.dart';
import 'package:glade_forms_devtools_extension/src/debug/mock_data.dart';
import 'package:glade_forms_devtools_extension/src/models/glade_model_description.dart';
import 'package:glade_forms_devtools_extension/src/services/glade_forms_service.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/composed/composed_model_view.dart';
import 'package:glade_forms_devtools_extension/src/widgets/detail/model_detail_view.dart';
import 'package:glade_forms_devtools_extension/src/widgets/list/models_sidebar.dart';
import 'package:glade_forms_devtools_extension/src/widgets/views/empty_models_view.dart';
import 'package:glade_forms_devtools_extension/src/widgets/views/error_view.dart';
import 'package:glade_forms_devtools_extension/src/widgets/views/loading_view.dart';
import 'package:glade_forms_devtools_extension/src/widgets/views/service_unavailable_view.dart';
import 'package:multi_split_view/multi_split_view.dart';

/// Debug mode flag - set via --dart-define
const bool _kDebugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: false);

class GladeFormsExtensionScreen extends StatefulWidget {
  const GladeFormsExtensionScreen({super.key});

  @override
  State<GladeFormsExtensionScreen> createState() => _GladeFormsExtensionScreenState();
}

class _GladeFormsExtensionScreenState extends State<GladeFormsExtensionScreen> {
  final _service = GladeFormsService();
  List<GladeModelDescription> _models = [];
  GladeModelDescription? _selectedModel;
  String? _selectedChildId; // Track selected child model ID
  bool _isLoading = false;
  bool _serviceAvailable = false;
  Timer? _refreshTimer;
  String? _error;

  // Debug mode state
  MockScenario _currentScenario = MockScenario.composedModel;
  final bool _debugModeEnabled = _kDebugMode;

  @override
  void initState() {
    super.initState();
    if (_debugModeEnabled) {
      _loadMockData();
    } else {
      _checkServiceAndLoadData();
      _refreshTimer = Timer.periodic(GladeFormsConstants.refreshInterval, (_) {
        _checkServiceAndLoadData(forceRefresh: false);
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkServiceAndLoadData({bool forceRefresh = true}) async {
    setState(() {
      if (forceRefresh) {
        _isLoading = true;
        _error = null;
      }
    });

    try {
      final available = await _service.isServiceAvailable();

      setState(() {
        _serviceAvailable = available;
      });

      if (available) {
        await _loadModels();
      }
    } catch (e) {
      setState(() {
        _error = 'Error checking service: $e';
        _serviceAvailable = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadModels() async {
    try {
      final models = await _service.fetchModels();
      if (mounted) {
        setState(() {
          _models = models;
          _error = null;
          // Update selected model if it's still in the list
          if (_selectedModel != null) {
            _selectedModel = models.firstWhere(
              (m) => m.id == _selectedModel!.id,
              orElse: () => models.isNotEmpty ? models.first : _selectedModel!,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading models: $e';
        });
      }
    }
  }

  void _loadMockData() {
    setState(() {
      _models = MockDataProvider.getModelsForScenario(_currentScenario);
      _serviceAvailable = true;
      _isLoading = false;
      _error = null;
      _selectedModel = _models.isNotEmpty ? _models.first : null;
      _selectedChildId = null;
    });
  }

  void _switchMockScenario(MockScenario scenario) {
    setState(() {
      _currentScenario = scenario;
    });
    _loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Glade Forms Inspector'),
            if (_debugModeEnabled) ...[
              const SizedBox(width: GladeFormsConstants.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GladeFormsConstants.spacing8,
                  vertical: GladeFormsConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  GladeFormsConstants.debugBadge,
                  style: TextStyle(
                    fontSize: GladeFormsConstants.debugBadgeFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_debugModeEnabled) ...[
            PopupMenuButton<MockScenario>(
              icon: const Icon(Icons.science),
              tooltip: 'Select Mock Scenario',
              onSelected: _switchMockScenario,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: MockScenario.noModels,
                  child: Text('No Models'),
                ),
                const PopupMenuItem(
                  value: MockScenario.singleModel,
                  child: Text('Single Model'),
                ),
                const PopupMenuItem(
                  value: MockScenario.composedModel,
                  child: Text('Composed Model'),
                ),
                const PopupMenuItem(
                  value: MockScenario.multipleModels,
                  child: Text('Multiple Models'),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _checkServiceAndLoadData,
              tooltip: 'Refresh',
            ),
          ],
        ],
      ),
      body: _ExtensionBody(
        isLoading: _isLoading,
        serviceAvailable: _serviceAvailable,
        error: _error,
        models: _models,
        selectedModel: _selectedModel,
        selectedChildId: _selectedChildId,
        onRetry: _checkServiceAndLoadData,
        onModelSelected: (model) {
          setState(() {
            _selectedModel = model;
            _selectedChildId = null;
          });
        },
        onChildSelected: (model, childId) {
          setState(() {
            _selectedModel = model;
            _selectedChildId = childId;
          });
        },
      ),
    );
  }
}

// Private widgets

class _ExtensionBody extends StatefulWidget {
  const _ExtensionBody({
    required this.isLoading,
    required this.serviceAvailable,
    required this.error,
    required this.models,
    required this.selectedModel,
    required this.selectedChildId,
    required this.onRetry,
    required this.onModelSelected,
    required this.onChildSelected,
  });

  final bool isLoading;
  final bool serviceAvailable;
  final String? error;
  final List<GladeModelDescription> models;
  final GladeModelDescription? selectedModel;
  final String? selectedChildId;
  final VoidCallback onRetry;
  final void Function(GladeModelDescription model) onModelSelected;
  final void Function(GladeModelDescription model, String childId) onChildSelected;

  @override
  State<_ExtensionBody> createState() => _ExtensionBodyState();
}

class _ExtensionBodyState extends State<_ExtensionBody> {
  final MultiSplitViewController _controller = MultiSplitViewController(areas: [
    Area(
      data: 'sidebar',
      min: 300,
      max: 500,
      size: 350,
    ),
    Area(data: 'detail', flex: 1),
  ]);

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return LoadingView();
    }

    if (!widget.serviceAvailable) {
      return ServiceUnavailableView(onRetry: widget.onRetry);
    }

    if (widget.error != null) {
      return ErrorView(errorMessage: widget.error!, onRetry: widget.onRetry);
    }

    if (widget.models.isEmpty) {
      return const EmptyModelsView();
    }

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 2,
      ),
      child: MultiSplitView(
        controller: _controller,
        builder: (context, area) => switch (area.data) {
          'sidebar' => ModelsSidebar(
              models: widget.models,
              selectedModel: widget.selectedModel,
              selectedChildId: widget.selectedChildId,
              onModelTap: widget.onModelSelected,
              onChildTap: widget.onChildSelected,
            ),
          'detail' => _DetailPane(
              selectedModel: widget.selectedModel,
              selectedChildId: widget.selectedChildId,
            ),
          _ => const SizedBox.shrink(),
        },
        sizeUnderflowPolicy: SizeUnderflowPolicy.stretchFirst,
        dividerBuilder: (axis, index, resizable, dragging, highlighted, themeData) {
          return Container(
            color: dragging ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
          );
        },
      ),
    );
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.selectedModel,
    required this.selectedChildId,
  });

  final GladeModelDescription? selectedModel;
  final String? selectedChildId;

  @override
  Widget build(BuildContext context) {
    if (selectedModel == null) {
      return Center(
        child: Text(
          GladeFormsConstants.selectModelMessage,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    // If a child model is selected, show its details
    if (selectedChildId != null && selectedModel!.isComposed) {
      final childModel = selectedModel!.childModels.firstWhere(
        (child) => child.id == selectedChildId,
      );

      return ModelDetailView(model: childModel);
    }

    // If the parent composed model is selected, show composed view
    if (selectedModel!.isComposed) {
      return ComposedModelView(model: selectedModel!);
    }

    // For regular models, show detail view
    return ModelDetailView(model: selectedModel!);
  }
}
