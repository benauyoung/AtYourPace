import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/stop_model.dart';
import 'widgets/voice_generator_panel.dart';

/// Screen for editing individual tour stops
class StopEditorScreen extends ConsumerStatefulWidget {
  final String tourId;
  final String versionId;
  final StopModel? stop;
  final int stopIndex;
  final ValueChanged<StopModel>? onSave;

  const StopEditorScreen({
    super.key,
    required this.tourId,
    required this.versionId,
    this.stop,
    required this.stopIndex,
    this.onSave,
  });

  @override
  ConsumerState<StopEditorScreen> createState() => _StopEditorScreenState();
}

class _StopEditorScreenState extends ConsumerState<StopEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _triggerRadius;
  late GeoPoint _location;
  String? _audioUrl;
  int? _audioDuration;
  String? _audioText;
  String? _voiceId;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final stop = widget.stop;
    _nameController = TextEditingController(text: stop?.name ?? '');
    _descriptionController = TextEditingController(text: stop?.description ?? '');
    _triggerRadius = stop?.triggerRadius ?? 30;
    _location = stop?.location ?? const GeoPoint(48.8566, 2.3522); // Default Paris
    _audioUrl = stop?.media.audioUrl;
    _audioDuration = stop?.media.audioDuration;
    _audioText = stop?.media.audioText;
    _voiceId = stop?.media.voiceId;

    _nameController.addListener(_markChanged);
    _descriptionController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.stop == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Add Stop' : 'Edit Stop ${widget.stopIndex + 1}'),
        actions: [
          if (_hasChanges)
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
          FilledButton.icon(
            onPressed: _hasChanges ? _saveStop : null,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Section
            _buildSectionHeader(context, 'Basic Information'),
            const SizedBox(height: 16),
            _buildBasicInfoSection(context),
            const SizedBox(height: 32),

            // Location Section
            _buildSectionHeader(context, 'Location & Trigger'),
            const SizedBox(height: 16),
            _buildLocationSection(context),
            const SizedBox(height: 32),

            // Audio Section
            _buildSectionHeader(context, 'Audio Narration'),
            const SizedBox(height: 16),
            _buildAudioSection(context),
            const SizedBox(height: 32),

            // Images Section
            _buildSectionHeader(context, 'Images'),
            const SizedBox(height: 16),
            _buildImagesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Stop Name',
                hintText: 'e.g., Eiffel Tower',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of this location...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location display
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coordinates'),
                      Text(
                        '${_location.latitude.toStringAsFixed(6)}, ${_location.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open map picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Map picker coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Pick on Map'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Trigger radius slider
            Text(
              'Trigger Radius',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _triggerRadius.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 18,
                    label: '${_triggerRadius}m',
                    onChanged: (value) {
                      setState(() {
                        _triggerRadius = value.round();
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${_triggerRadius}m',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Radius presets
            Wrap(
              spacing: 8,
              children: [15, 25, 35, 50, 75].map((radius) {
                return ActionChip(
                  label: Text('${radius}m'),
                  onPressed: () {
                    setState(() {
                      _triggerRadius = radius;
                      _hasChanges = true;
                    });
                  },
                  backgroundColor: _triggerRadius == radius
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Audio will start playing when user enters this radius',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio options tabs
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.auto_awesome), text: 'AI Generate'),
                  Tab(icon: Icon(Icons.mic), text: 'Record'),
                  Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
                ],
                labelColor: Theme.of(context).colorScheme.primary,
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 500,
                child: TabBarView(
                  children: [
                    // AI Generate tab
                    VoiceGeneratorPanel(
                      tourId: widget.tourId,
                      stopId: widget.stop?.id ?? 'new_${widget.stopIndex}',
                      initialScript: _audioText,
                      initialVoiceId: _voiceId,
                      initialAudioUrl: _audioUrl,
                      initialAudioDuration: _audioDuration,
                      onAudioGenerated: (url) {
                        setState(() {
                          _audioUrl = url;
                          _hasChanges = true;
                        });
                      },
                    ),
                    // Record tab
                    _buildRecordTab(context),
                    // Upload tab
                    _buildUploadTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTab(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Record Audio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Use your microphone to record narration',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: Implement recording
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recording feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Start Recording'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadTab(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Audio File',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Supported formats: MP3, WAV, M4A (max 10MB)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement file picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File upload coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Choose File'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final images = widget.stop?.media.images ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Stop Images',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement image upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image upload coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Image'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (images.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No images added',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image.url,
                              width: 160,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton.filled(
                              onPressed: () {
                                // TODO: Remove image
                              },
                              icon: const Icon(Icons.close, size: 16),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(4),
                                minimumSize: const Size(24, 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveStop() {
    final now = DateTime.now();
    final stop = widget.stop?.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          triggerRadius: _triggerRadius,
          location: _location,
          media: widget.stop!.media.copyWith(
            audioUrl: _audioUrl,
            audioDuration: _audioDuration,
            audioText: _audioText,
            voiceId: _voiceId,
          ),
          updatedAt: now,
        ) ??
        StopModel(
          id: '',
          tourId: widget.tourId,
          versionId: widget.versionId,
          order: widget.stopIndex,
          name: _nameController.text,
          description: _descriptionController.text,
          location: _location,
          geohash: '', // Should be calculated
          triggerRadius: _triggerRadius,
          media: StopMedia(
            audioUrl: _audioUrl,
            audioDuration: _audioDuration,
            audioText: _audioText,
            voiceId: _voiceId,
          ),
          createdAt: now,
          updatedAt: now,
        );

    widget.onSave?.call(stop);
    setState(() => _hasChanges = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stop saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
