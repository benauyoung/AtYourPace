import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../../data/models/tour_version_model.dart';
import '../../providers/tour_providers.dart';

class TourReviewScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourReviewScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourReviewScreen> createState() => _TourReviewScreenState();
}

class _TourReviewScreenState extends ConsumerState<TourReviewScreen> {
  final _reviewNotesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourAsync = ref.watch(tourByIdProvider(widget.tourId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Tour'),
        actions: [
          // Quick approve button
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            color: Colors.green,
            onPressed: _isSubmitting ? null : () => _showApproveDialog(context),
            tooltip: 'Approve',
          ),
          // Quick reject button
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            color: Colors.red,
            onPressed: _isSubmitting ? null : () => _showRejectDialog(context),
            tooltip: 'Reject',
          ),
        ],
      ),
      body: tourAsync.when(
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found'));
          }
          return _buildReviewContent(context, tour);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: tourAsync.when(
        data: (tour) => tour != null
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _showRejectDialog(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _showApproveDialog(context),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, TourModel tour) {
    final versionId = tour.draftVersionId;
    final versionAsync = ref.watch(
      tourVersionProvider((tourId: widget.tourId, versionId: versionId)),
    );
    final stopsAsync = ref.watch(
      stopsProvider((tourId: widget.tourId, versionId: versionId)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tour status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.pending_actions, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Review',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Submitted for review on ${_formatDate(tour.updatedAt)}',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tour basic info
          Text(
            'Tour Information',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            children: [
              _InfoRow(
                label: 'Location',
                value: '${tour.city ?? 'Unknown'}, ${tour.country ?? ''}',
              ),
              _InfoRow(
                label: 'Creator',
                value: tour.creatorName,
              ),
              _InfoRow(
                label: 'Category',
                value: tour.category.displayName,
              ),
              _InfoRow(
                label: 'Tour Type',
                value: tour.tourType.displayName,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Version details
          Text(
            'Content Details',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          versionAsync.when(
            data: (version) {
              if (version == null) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Version not found'),
                  ),
                );
              }
              return _InfoCard(
                children: [
                  _InfoRow(label: 'Title', value: version.title),
                  _InfoRow(label: 'Description', value: version.description),
                  if (version.duration != null)
                    _InfoRow(label: 'Duration', value: version.duration!),
                  if (version.distance != null)
                    _InfoRow(label: 'Distance', value: version.distance!),
                  _InfoRow(
                    label: 'Difficulty',
                    value: version.difficulty.displayName,
                  ),
                  if (version.languages.isNotEmpty)
                    _InfoRow(
                      label: 'Languages',
                      value: version.languages.join(', '),
                    ),
                ],
              );
            },
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading version: $error'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stops preview
          Text(
            'Stops',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          stopsAsync.when(
            data: (stops) {
              if (stops.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: context.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        const Text('No stops defined'),
                      ],
                    ),
                  ),
                );
              }
              return Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stops.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: context.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(stop.name),
                      subtitle: Text(
                        stop.description.isNotEmpty
                            ? stop.description
                            : 'No description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (stop.hasAudio)
                            Icon(
                              Icons.audiotrack,
                              size: 20,
                              color: context.colorScheme.primary,
                            ),
                          if (stop.hasImages)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.image,
                                size: 20,
                                color: context.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading stops: $error'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Review notes input
          Text(
            'Review Notes',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewNotesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Add notes for the creator (optional)...\n\nThese will be visible to the creator.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve Tour'),
        content: const Text(
          'This will publish the tour and make it visible to all users. '
          'Are you sure you want to approve this tour?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _approveTour();
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Tour'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for rejection. '
              'This will be sent to the creator.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              _rejectTour(reasonController.text);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveTour() async {
    setState(() => _isSubmitting = true);

    try {
      if (AppConfig.demoMode) {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Call actual approval API
        final adminService = ref.read(adminServiceProvider);
        await adminService.approveTour(widget.tourId);
      }

      if (mounted) {
        context.showSuccessSnackBar('Tour approved successfully');
        GoRouter.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to approve tour: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _rejectTour(String reason) async {
    setState(() => _isSubmitting = true);

    try {
      if (AppConfig.demoMode) {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Call actual rejection API
        final adminService = ref.read(adminServiceProvider);
        await adminService.rejectTour(widget.tourId, reason);
      }

      if (mounted) {
        context.showSuccessSnackBar('Tour rejected');
        GoRouter.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to reject tour: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
