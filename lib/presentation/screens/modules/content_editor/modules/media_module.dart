import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tour_editor_provider.dart';

/// Media tab for tour editing - cover image and media management
class MediaModule extends ConsumerStatefulWidget {
  final String? tourId;
  final String? versionId;

  const MediaModule({
    super.key,
    this.tourId,
    this.versionId,
  });

  @override
  ConsumerState<MediaModule> createState() => _MediaModuleState();
}

class _MediaModuleState extends ConsumerState<MediaModule> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.watch(tourEditorProvider(params));
    final notifier = ref.read(tourEditorProvider(params).notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image Section
          _buildSectionHeader(context, 'Cover Image', required: true),
          const SizedBox(height: 8),
          Text(
            'This image will be displayed in the marketplace and tour details.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 16),
          _buildCoverImagePicker(context, state, notifier),
          const SizedBox(height: 32),

          // Image Guidelines
          _buildSectionHeader(context, 'Image Guidelines'),
          const SizedBox(height: 8),
          _buildGuidelinesCard(context),
          const SizedBox(height: 32),

          // Gallery Section (Future)
          _buildSectionHeader(context, 'Stop Images'),
          const SizedBox(height: 8),
          _buildGalleryPlaceholder(context, state),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildCoverImagePicker(
    BuildContext context,
    TourEditorState state,
    TourEditorNotifier notifier,
  ) {
    final coverUrl = state.coverImageUrl;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: coverUrl != null
            ? _buildImagePreview(context, coverUrl, notifier)
            : _buildImagePlaceholder(context, notifier),
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    String imageUrl,
    TourEditorNotifier notifier,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Overlay with actions
        Positioned(
          bottom: 12,
          right: 12,
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: () => _pickImage(notifier),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Replace'),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  notifier.updateCoverImage(null);
                },
                icon: const Icon(Icons.delete),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(
    BuildContext context,
    TourEditorNotifier notifier,
  ) {
    return InkWell(
      onTap: () => _pickImage(notifier),
      borderRadius: BorderRadius.circular(12),
      child: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Click to upload cover image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommended: 1920x1080 (16:9)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
    );
  }

  Widget _buildGuidelinesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuidelineItem(
              context,
              icon: Icons.aspect_ratio,
              title: 'Aspect Ratio',
              description: '16:9 recommended for best display',
            ),
            const SizedBox(height: 12),
            _buildGuidelineItem(
              context,
              icon: Icons.high_quality,
              title: 'Resolution',
              description: 'Minimum 1280x720, recommended 1920x1080',
            ),
            const SizedBox(height: 12),
            _buildGuidelineItem(
              context,
              icon: Icons.file_present,
              title: 'File Format',
              description: 'JPG or PNG, max 10MB',
            ),
            const SizedBox(height: 12),
            _buildGuidelineItem(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Tips',
              description:
                  'Use a vibrant image that represents your tour location',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryPlaceholder(BuildContext context, TourEditorState state) {
    final stopsWithImages =
        state.stops.where((s) => s.hasImages).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stop Images',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        state.stops.isEmpty
                            ? 'Add stops to manage their images'
                            : '$stopsWithImages of ${state.stops.length} stops have images',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                if (state.stops.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to stops tab
                    },
                    child: const Text('Manage in Stops'),
                  ),
              ],
            ),
            if (state.stops.isNotEmpty && stopsWithImages > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.stops.length,
                  itemBuilder: (context, index) {
                    final stop = state.stops[index];
                    if (!stop.hasImages) return const SizedBox.shrink();
                    // Show first image from stop
                    final firstImage = stop.media.images.first;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          firstImage.url,
                          width: 120,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(TourEditorNotifier notifier) async {
    // TODO: Implement image picking with image_picker
    // For now, show a placeholder dialog
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Image'),
        content: const Text(
          'Image picker will be implemented with the image_picker package.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Use a placeholder image for testing
              Navigator.pop(
                context,
                'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1920',
              );
            },
            child: const Text('Use Placeholder'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _isUploading = true);
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 1));
      notifier.updateCoverImage(result);
      setState(() => _isUploading = false);
    }
  }
}
