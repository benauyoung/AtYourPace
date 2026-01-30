import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'modules/basic_info_module.dart';
import 'modules/media_module.dart';
import 'modules/pricing_module.dart';
import 'modules/route_module.dart';
import 'modules/stops_module.dart';
import 'providers/tour_editor_provider.dart';

/// Main tour editor screen with tab-based navigation
class TourEditorScreen extends ConsumerStatefulWidget {
  final String? tourId;
  final String? versionId;

  const TourEditorScreen({
    super.key,
    this.tourId,
    this.versionId,
  });

  @override
  ConsumerState<TourEditorScreen> createState() => _TourEditorScreenState();
}

class _TourEditorScreenState extends ConsumerState<TourEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (icon: Icons.info_outline, label: 'Basic Info'),
    (icon: Icons.route, label: 'Route'),
    (icon: Icons.format_list_bulleted, label: 'Stops'),
    (icon: Icons.image_outlined, label: 'Media'),
    (icon: Icons.attach_money, label: 'Pricing'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initialize the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = (tourId: widget.tourId, versionId: widget.versionId);
      ref.read(tourEditorProvider(params).notifier).initialize();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final params = (tourId: widget.tourId, versionId: widget.versionId);
      ref.read(tourEditorProvider(params).notifier).setCurrentTab(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.watch(tourEditorProvider(params));
    final notifier = ref.read(tourEditorProvider(params).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isNewTour ? 'Create Tour' : 'Edit Tour'),
        actions: [
          // Validation status
          if (state.validationErrors.isNotEmpty)
            Tooltip(
              message: state.validationErrors.join('\n'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          // Unsaved changes indicator
          if (state.hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Unsaved',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          // Save button
          FilledButton.icon(
            onPressed: state.isSaving ? null : () => _save(notifier),
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(state.isSaving ? 'Saving...' : 'Save'),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) {
            return Tab(
              icon: Icon(tab.icon),
              text: tab.label,
            );
          }).toList(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(context, state.error!, notifier)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    BasicInfoModule(
                      tourId: widget.tourId,
                      versionId: widget.versionId,
                    ),
                    RouteModule(
                      tourId: widget.tourId,
                      versionId: widget.versionId,
                    ),
                    StopsModule(
                      tourId: widget.tourId,
                      versionId: widget.versionId,
                    ),
                    MediaModule(
                      tourId: widget.tourId,
                      versionId: widget.versionId,
                    ),
                    PricingModule(
                      tourId: widget.tourId,
                      versionId: widget.versionId,
                    ),
                  ],
                ),
      bottomNavigationBar: _buildBottomBar(context, state, notifier),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    TourEditorNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Tour',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => notifier.initialize(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    TourEditorState state,
    TourEditorNotifier notifier,
  ) {
    // Show progress indicator
    final completedSections = _getCompletedSections(state);
    final progress = completedSections / 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Progress indicator
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Completion',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Navigation buttons
          if (_tabController.index > 0)
            OutlinedButton.icon(
              onPressed: () {
                _tabController.animateTo(_tabController.index - 1);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          const SizedBox(width: 8),
          if (_tabController.index < _tabs.length - 1)
            FilledButton.icon(
              onPressed: () {
                _tabController.animateTo(_tabController.index + 1);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
            )
          else
            FilledButton.icon(
              onPressed: state.hasMinimumContent
                  ? () => _showPublishDialog(context, notifier)
                  : null,
              icon: const Icon(Icons.publish),
              label: const Text('Submit for Review'),
            ),
        ],
      ),
    );
  }

  int _getCompletedSections(TourEditorState state) {
    int completed = 0;

    // Basic Info: has title and description
    if (state.title.isNotEmpty && state.title != 'Untitled Tour' && state.description.isNotEmpty) {
      completed++;
    }

    // Route: has at least one stop location
    if (state.stops.isNotEmpty) {
      completed++;
    }

    // Stops: has stops with content
    if (state.stops.isNotEmpty && state.stops.any((s) => s.name.isNotEmpty)) {
      completed++;
    }

    // Media: has cover image
    if (state.coverImageUrl != null) {
      completed++;
    }

    // Pricing: always complete (defaults to free)
    completed++;

    return completed;
  }

  Future<void> _save(TourEditorNotifier notifier) async {
    final success = await notifier.save();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tour saved successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final params = (tourId: widget.tourId, versionId: widget.versionId);
        final error = ref.read(tourEditorProvider(params)).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save tour'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showPublishDialog(BuildContext context, TourEditorNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit for Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your tour will be reviewed by our team before being published.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Before submitting, please ensure:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildChecklistItem(context, 'All stops have audio narration'),
            _buildChecklistItem(context, 'Cover image is uploaded'),
            _buildChecklistItem(context, 'Description is complete'),
            _buildChecklistItem(context, 'Route is properly mapped'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement submit for review
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tour submitted for review'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
