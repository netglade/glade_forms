import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glade_forms_devtools_extension/src/models/form_model_data.dart';
import 'package:glade_forms_devtools_extension/src/services/glade_forms_service.dart';
import 'package:glade_forms_devtools_extension/src/widgets/model_card.dart';
import 'package:glade_forms_devtools_extension/src/widgets/model_detail_view.dart';

class GladeFormsExtensionScreen extends StatefulWidget {
  const GladeFormsExtensionScreen({super.key});

  @override
  State<GladeFormsExtensionScreen> createState() =>
      _GladeFormsExtensionScreenState();
}

class _GladeFormsExtensionScreenState
    extends State<GladeFormsExtensionScreen> {
  final _service = GladeFormsService();
  List<FormModelData> _models = [];
  FormModelData? _selectedModel;
  bool _isLoading = false;
  bool _serviceAvailable = false;
  Timer? _refreshTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkServiceAndLoadData();
    // Auto-refresh every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && _serviceAvailable) {
        _loadModels();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkServiceAndLoadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glade Forms Inspector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkServiceAndLoadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      );
    }

    if (!_serviceAvailable) {
      return _buildServiceUnavailableView();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkServiceAndLoadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_models.isEmpty) {
      return _buildEmptyView();
    }

    return Row(
      children: [
        // Models list
        SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Active Models (${_models.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    return ModelCard(
                      model: model,
                      isSelected: _selectedModel?.id == model.id,
                      onTap: () {
                        setState(() {
                          _selectedModel = model;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Model detail
        Expanded(
          child: _selectedModel != null
              ? ModelDetailView(model: _selectedModel!)
              : Center(
                  child: Text(
                    'Select a model to view details',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildServiceUnavailableView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Service Not Available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'The glade_forms DevTools service is not available.\n\n'
              'Make sure your app is running and using glade_forms.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _checkServiceAndLoadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Forms',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No GladeModel instances are currently active in your app.\n\n'
              'Navigate to a screen with forms to see them here.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
