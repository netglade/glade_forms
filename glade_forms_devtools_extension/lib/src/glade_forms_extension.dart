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

/// Debug mode flag - set via --dart-define.
// ignore: prefer-boolean-prefixes, keep name
const bool _kDebugMode = bool.fromEnvironment('DEBUG_MODE');

typedef OnChildTapCallback = void Function(GladeModelDescription model, String childId);

// ignore: prefer-match-file-name, keep in same file
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
  bool _isServiceAvailable = false;
  Timer? _refreshTimer;
  String? _error;

  // Debug mode state
  MockScenario _currentScenario = .composedModel;
  final bool _isDebugModeEnabled = _kDebugMode;

  @override
  void initState() {
    super.initState();
    if (_isDebugModeEnabled) {
      // ignore: avoid-unnecessary-setstate, it is ok
      _loadMockData();
    } else {
      // ignore: avoid-async-call-in-sync-function, it is ok
      _checkServiceAndLoadData();
      // ignore: prefer-extracting-callbacks, keep inline
      _refreshTimer = Timer.periodic(Constants.refreshInterval, (_) {
        // ignore: avoid-async-call-in-sync-function, it is ok
        _checkServiceAndLoadData(shouldForceRefresh: false);
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Glade Forms Inspector'),
            if (_isDebugModeEnabled) ...[
              const SizedBox(width: Constants.spacing8),
              Container(
                padding: const .symmetric(
                  horizontal: Constants.spacing8,
                  vertical: Constants.spacing4,
                ),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: .all(.circular(4)),
                ),
                child: const Text(
                  Constants.debugBadge,
                  style: TextStyle(
                    fontSize: Constants.debugBadgeFontSize,
                    fontWeight: .bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_isDebugModeEnabled)
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
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : () => unawaited(_checkServiceAndLoadData()),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _ExtensionBody(
        isLoading: _isLoading,
        isServiceAvailable: _isServiceAvailable,
        error: _error,
        models: _models,
        selectedModel: _selectedModel,
        selectedChildId: _selectedChildId,
        onRetry: () => unawaited(_checkServiceAndLoadData()),
        // ignore: prefer-extracting-callbacks, keep inline
        onModelSelected: (model) {
          setState(() {
            _selectedModel = model;
            _selectedChildId = null;
          });
        },
        // ignore: prefer-extracting-callbacks, keep inline
        onChildSelected: (model, childId) {
          setState(() {
            _selectedModel = model;
            _selectedChildId = childId;
          });
        },
      ),
    );
  }

  Future<void> _checkServiceAndLoadData({bool shouldForceRefresh = true}) async {
    if (shouldForceRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final isAvailable = await _service.isServiceAvailable();

      if (!context.mounted) return;

      setState(() {
        _isServiceAvailable = isAvailable;
      });

      if (isAvailable) {
        await _loadModels();
      }
      // ignore: avoid_catches_without_on_clauses, gotta catch them all
    } catch (e) {
      setState(() {
        _error = 'Error checking service: $e';
        _isServiceAvailable = false;
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
          if (_selectedModel case final model?) {
            _selectedModel = models.firstWhere(
              (m) => m.id == model.id,
              // ignore: avoid-unsafe-collection-methods, checked by condition
              orElse: () => models.isNotEmpty ? models.first : model,
            );
          }
        });
      }
      // ignore: avoid_catches_without_on_clauses, gotta catch them all
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
      _isServiceAvailable = true;
      _isLoading = false;
      _error = null;
      _selectedModel = _models.firstOrNull;
      _selectedChildId = null;
    });
  }

  void _switchMockScenario(MockScenario scenario) {
    setState(() {
      _currentScenario = scenario;
    });
    _loadMockData();
  }
}

// Private widgets

class _ExtensionBody extends StatefulWidget {
  final bool isLoading;

  final bool isServiceAvailable;
  final String? error;
  final List<GladeModelDescription> models;
  final GladeModelDescription? selectedModel;
  final String? selectedChildId;
  final VoidCallback onRetry;
  final ValueChanged<GladeModelDescription> onModelSelected;
  final OnChildTapCallback onChildSelected;

  const _ExtensionBody({
    required this.isLoading,
    required this.isServiceAvailable,
    required this.error,
    required this.models,
    required this.selectedModel,
    required this.selectedChildId,
    required this.onRetry,
    required this.onModelSelected,
    required this.onChildSelected,
  });

  @override
  State<_ExtensionBody> createState() => _ExtensionBodyState();
}

class _ExtensionBodyState extends State<_ExtensionBody> {
  final MultiSplitViewController _controller = MultiSplitViewController(
    areas: [
      // ignore: avoid-undisposed-instances, it is ok
      Area(data: 'sidebar', min: 300, max: 500, size: 350),
      // ignore: avoid-undisposed-instances, it is ok
      Area(data: 'detail', flex: 1),
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const LoadingView();
    }

    if (!widget.isServiceAvailable) {
      return ServiceUnavailableView(onRetry: widget.onRetry);
    }

    if (widget.error != null) {
      return ErrorView(errorMessage: widget.error!, onRetry: widget.onRetry);
    }

    if (widget.models.isEmpty) {
      return const EmptyModelsView();
    }

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(dividerThickness: 2),
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
        sizeUnderflowPolicy: .stretchFirst,
        // ignore: prefer-extracting-callbacks, keep  inline, prefer-boolean-prefixes
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
  final GladeModelDescription? selectedModel;

  final String? selectedChildId;

  const _DetailPane({
    required this.selectedModel,
    required this.selectedChildId,
  });

  @override
  Widget build(BuildContext context) {
    final model = selectedModel;
    if (model == null) {
      return Center(
        child: Text(
          Constants.selectModelMessage,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // If a child model is selected, show its details
    if (selectedChildId != null && model.isComposed) {
      // ignore: avoid-unsafe-collection-methods, checked by condition
      final childModel = model.childModels.firstWhere(
        (child) => child.id == selectedChildId,
      );

      return ModelDetailView(model: childModel);
    }

    // If the parent composed model is selected, show composed view
    if (model.isComposed) {
      return ComposedModelView(model: model);
    }

    // For regular models, show detail view
    return ModelDetailView(model: model);
  }
}
