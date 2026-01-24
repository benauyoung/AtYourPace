import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/geohash_utils.dart';
import '../../../data/models/stop_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/location_service.dart';
import '../../providers/tour_providers.dart';
import '../../widgets/audio/audio_recorder_widget.dart';
import '../../widgets/audio/voice_selector_widget.dart';
import '../../widgets/map/tour_map_widget.dart';

class StopEditorScreen extends ConsumerStatefulWidget {
  final String tourId;
  final String versionId;
  final StopModel? existingStop;
  final int stopOrder;

  const StopEditorScreen({
    super.key,
    required this.tourId,
    required this.versionId,
    this.existingStop,
    required this.stopOrder,
  });

  @override
  ConsumerState<StopEditorScreen> createState() => _StopEditorScreenState();
}

class _StopEditorScreenState extends ConsumerState<StopEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scriptController = TextEditingController();

  mapbox.Position? _selectedPosition;
  double _triggerRadius = 30.0;
  bool _isMapExpanded = true;
  bool _isSaving = false;

  // Audio state
  String? _audioUrl;
  String? _localAudioPath;
  AudioSource? _audioSource;
  bool _isGeneratingAudio = false;
  String? _selectedVoiceId;
  bool _isPlayingPreview = false;

  // Image state
  final List<StopImage> _images = [];
  final List<String> _pendingLocalImagePaths = []; // Images not yet uploaded
  bool _isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingStop != null) {
      _nameController.text = widget.existingStop!.name;
      _descriptionController.text = widget.existingStop!.description;
      _selectedPosition = mapbox.Position(
        widget.existingStop!.location.longitude,
        widget.existingStop!.location.latitude,
      );
      _triggerRadius = widget.existingStop!.triggerRadius.toDouble();

      // Load existing audio
      if (widget.existingStop!.media.audioUrl != null) {
        _audioUrl = widget.existingStop!.media.audioUrl;
        _audioSource = widget.existingStop!.media.audioSource;
      }
      if (widget.existingStop!.media.audioText != null) {
        _scriptController.text = widget.existingStop!.media.audioText!;
      }

      // Load existing images
      if (widget.existingStop!.media.images.isNotEmpty) {
        _images.addAll(widget.existingStop!.media.images);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scriptController.dispose();
    // Stop any audio preview that might be playing
    if (_isPlayingPreview) {
      ref.read(audioServiceProvider).stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(currentPositionProvider);
    final isEditing = widget.existingStop != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Stop' : 'Add Stop'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveStop,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isMapExpanded
                ? MediaQuery.of(context).size.height * 0.35
                : 120,
            child: Stack(
              children: [
                TourMapWidget(
                  initialCenter: _selectedPosition ??
                      (currentPosition.valueOrNull != null
                          ? mapbox.Position(
                              currentPosition.valueOrNull!.longitude,
                              currentPosition.valueOrNull!.latitude,
                            )
                          : null),
                  initialZoom: 17,
                  showUserLocation: true,
                  stops: _selectedPosition != null
                      ? [
                          StopMarker(
                            id: 'selected',
                            name: _nameController.text.isEmpty
                                ? 'Stop ${widget.stopOrder + 1}'
                                : _nameController.text,
                            latitude: _selectedPosition!.lat.toDouble(),
                            longitude: _selectedPosition!.lng.toDouble(),
                            order: widget.stopOrder,
                            triggerRadius: _triggerRadius,
                          ),
                        ]
                      : null,
                  onMapTapped: (position) {
                    setState(() {
                      _selectedPosition = position;
                    });
                  },
                  onMapLongPressed: (position) {
                    setState(() {
                      _selectedPosition = position;
                    });
                  },
                ),

                // Expand/collapse button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'expand_map',
                    onPressed: () {
                      setState(() => _isMapExpanded = !_isMapExpanded);
                    },
                    child: Icon(
                      _isMapExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                ),

                // Use current location button
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'use_location',
                    onPressed: () {
                      if (currentPosition.valueOrNull != null) {
                        setState(() {
                          _selectedPosition = mapbox.Position(
                            currentPosition.valueOrNull!.longitude,
                            currentPosition.valueOrNull!.latitude,
                          );
                        });
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // Instruction overlay
                if (_selectedPosition == null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.touch_app,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap on the map to place the stop',
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Form section
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Location info
                  if (_selectedPosition != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Location',
                                    style: context.textTheme.labelMedium,
                                  ),
                                  Text(
                                    '${_selectedPosition!.lat.toStringAsFixed(6)}, '
                                    '${_selectedPosition!.lng.toStringAsFixed(6)}',
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _selectedPosition = null);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Stop name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Stop Name *',
                      hintText: 'e.g., Historic Town Hall',
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a stop name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of this stop...',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Trigger radius
                  Text(
                    'Trigger Radius',
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Audio will play when user enters this radius',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _triggerRadius,
                          min: 10,
                          max: 100,
                          divisions: 9,
                          label: '${_triggerRadius.toInt()} m',
                          onChanged: (value) {
                            setState(() => _triggerRadius = value);
                          },
                        ),
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '${_triggerRadius.toInt()} m',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Audio section
                  _buildAudioSection(context),

                  const SizedBox(height: 16),

                  // Images section
                  _buildImagesSection(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context) {
    final hasAudio = _audioUrl != null || _localAudioPath != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audio Content',
                  style: context.textTheme.titleMedium,
                ),
                if (hasAudio) ...[
                  const Spacer(),
                  Chip(
                    label: Text(_getAudioSourceLabel()),
                    avatar: Icon(
                      _getAudioSourceIcon(),
                      size: 16,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Show current audio player if audio exists
            if (hasAudio) ...[
              _buildCurrentAudioPreview(context),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Replace Audio',
                style: context.textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
            ],

            // Audio options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showRecordDialog,
                    icon: const Icon(Icons.mic),
                    label: const Text('Record'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploadAudio,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGeneratingAudio ? null : _showElevenLabsDialog,
                icon: _isGeneratingAudio
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGeneratingAudio ? 'Generating...' : 'Generate with AI',
                ),
              ),
            ),

            // Remove audio button if audio exists
            if (hasAudio) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: _removeAudio,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove Audio'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAudioPreview(BuildContext context) {
    final audioState = ref.watch(audioStateProvider);
    final isPlaying = audioState.valueOrNull == AudioState.playing && _isPlayingPreview;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.audiotrack,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Narration',
                  style: context.textTheme.titleSmall,
                ),
                Text(
                  _getAudioSourceLabel(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleAudioPreview,
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
            ),
            iconSize: 36,
            color: isPlaying ? context.colorScheme.primary : null,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAudioPreview() async {
    final audioService = ref.read(audioServiceProvider);

    if (_isPlayingPreview) {
      await audioService.stop();
      setState(() => _isPlayingPreview = false);
    } else {
      try {
        final audioPath = _localAudioPath ?? _audioUrl;
        if (audioPath == null) return;

        // Load and play the audio
        if (_localAudioPath != null && !kIsWeb) {
          await audioService.playFile(_localAudioPath!);
        } else if (_audioUrl != null) {
          await audioService.playUrl(_audioUrl!);
        }

        setState(() => _isPlayingPreview = true);

        // Listen for completion to update state
        audioService.stateStream.listen((state) {
          if (state == AudioState.completed || state == AudioState.idle) {
            if (mounted) {
              setState(() => _isPlayingPreview = false);
            }
          }
        });
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('Failed to play audio: $e');
        }
      }
    }
  }

  String _getAudioSourceLabel() {
    final source = _audioSource;
    if (source == null) return 'No audio';
    return source.displayName;
  }

  IconData _getAudioSourceIcon() {
    switch (_audioSource) {
      case AudioSource.recorded:
        return Icons.mic;
      case AudioSource.uploaded:
        return Icons.upload_file;
      case AudioSource.elevenlabs:
        return Icons.auto_awesome;
      case null:
        return Icons.audiotrack;
    }
  }

  void _showRecordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Record Audio',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Record your narration for this stop',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AudioRecorderWidget(
                  existingAudioUrl: _localAudioPath ?? _audioUrl,
                  onRecordingComplete: (path) {
                    setState(() {
                      _localAudioPath = path;
                      _audioSource = AudioSource.recorded;
                    });
                    Navigator.pop(context);
                    this.context.showSuccessSnackBar('Recording saved');
                  },
                  onRecordingDeleted: () {
                    setState(() {
                      _localAudioPath = null;
                      if (_audioSource == AudioSource.recorded) {
                        _audioSource = null;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (kIsWeb) {
          // Handle web upload
          if (file.bytes != null) {
            try {
              if (mounted) {
                context.showInfoSnackBar('Uploading audio...');
              }

              final storageService = ref.read(storageServiceProvider);
              final stopId = widget.existingStop?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';

              final downloadUrl = await storageService.uploadStopAudioBytes(
                tourId: widget.tourId,
                stopId: stopId,
                audioBytes: file.bytes!,
              );

              setState(() {
                _audioUrl = downloadUrl;
                _audioSource = AudioSource.uploaded;
              });

              if (mounted) {
                context.showSuccessSnackBar('Audio uploaded successfully');
              }
            } catch (e) {
              if (mounted) {
                context.showErrorSnackBar('Failed to upload audio: $e');
              }
            }
          }
        } else if (file.path != null) {
          // Upload from mobile platform
          try {
            if (mounted) {
              context.showInfoSnackBar('Uploading audio...');
            }

            final storageService = ref.read(storageServiceProvider);
            final stopId = widget.existingStop?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';

            final downloadUrl = await storageService.uploadStopAudio(
              tourId: widget.tourId,
              stopId: stopId,
              audioFile: File(file.path!),
            );

            setState(() {
              _audioUrl = downloadUrl;
              _audioSource = AudioSource.uploaded;
            });

            if (mounted) {
              context.showSuccessSnackBar('Audio uploaded successfully');
            }
          } catch (e) {
            if (mounted) {
              context.showErrorSnackBar('Failed to upload audio: $e');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick audio file: $e');
      }
    }
  }

  void _showElevenLabsDialog() {
    // Pre-fill script with description if empty
    if (_scriptController.text.isEmpty && _descriptionController.text.isNotEmpty) {
      _scriptController.text = _descriptionController.text;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate Audio with AI'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the script for the AI to narrate:',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _scriptController,
                maxLines: 8,
                minLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your narration script here...\n\n'
                      'Example: "Welcome to the Historic Town Hall, built in 1892. '
                      'This magnificent building has served as the center of civic '
                      'life for over a century..."',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              VoiceSelectorWidget(
                selectedVoiceId: _selectedVoiceId,
                onVoiceSelected: (voiceId) {
                  setState(() => _selectedVoiceId = voiceId);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Limited to 1 request per minute',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (AppConfig.demoMode) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science,
                        size: 16,
                        color: context.colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo mode: Audio generation simulated',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_scriptController.text.trim().isEmpty) {
                context.showErrorSnackBar('Please enter a script');
                return;
              }
              Navigator.pop(dialogContext);
              _generateAudioWithAI();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAudioWithAI() async {
    setState(() => _isGeneratingAudio = true);

    try {
      if (AppConfig.demoMode) {
        // Simulate AI generation delay
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _audioUrl = 'demo_generated_audio.mp3';
          _audioSource = AudioSource.elevenlabs;
          _isGeneratingAudio = false;
        });

        if (mounted) {
          context.showSuccessSnackBar('Audio generated successfully');
        }
      } else {
        // Call ElevenLabs Cloud Function
        final functionsService = ref.read(cloudFunctionsServiceProvider);

        final audioUrl = await functionsService.generateElevenLabsAudio(
          tourId: widget.tourId,
          stopId: widget.existingStop?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
          text: _scriptController.text,
          voiceId: _selectedVoiceId ?? '21m00Tcm4TlvDq8ikWAM', // Default to Rachel
        );

        setState(() {
          _audioUrl = audioUrl;
          _audioSource = AudioSource.elevenlabs;
          _isGeneratingAudio = false;
        });

        if (mounted) {
          context.showSuccessSnackBar('Audio generated successfully');
        }
      }
    } catch (e) {
      setState(() => _isGeneratingAudio = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to generate audio: $e');
      }
    }
  }

  void _removeAudio() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Audio?'),
        content: const Text('This will remove the audio from this stop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _audioUrl = null;
                _localAudioPath = null;
                _audioSource = null;
              });
              context.showSuccessSnackBar('Audio removed');
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final totalImages = _images.length + _pendingLocalImagePaths.length;
    final hasImages = totalImages > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Images',
                  style: context.textTheme.titleMedium,
                ),
                if (hasImages) ...[
                  const Spacer(),
                  Text(
                    '$totalImages image${totalImages > 1 ? 's' : ''}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Image gallery
            if (hasImages) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: totalImages + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == totalImages) {
                      // Add more button
                      return _buildAddImageButton(context);
                    }
                    // Show uploaded images first, then pending local images
                    if (index < _images.length) {
                      return _buildImageTile(
                        context,
                        _images[index].url,
                        index,
                        isLocal: false,
                      );
                    } else {
                      final localIndex = index - _images.length;
                      return _buildImageTile(
                        context,
                        _pendingLocalImagePaths[localIndex],
                        index,
                        isLocal: true,
                      );
                    }
                  },
                ),
              ),
            ] else ...[
              // Empty state with add button
              SizedBox(
                width: double.infinity,
                child: _isUploadingImage
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: _showImagePickerOptions,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(
    BuildContext context,
    String imagePath,
    int index, {
    required bool isLocal,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isLocal && !kIsWeb
                ? Image.file(
                    File(imagePath),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imagePath,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 120,
                        height: 120,
                        color: context.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: context.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
          ),
          // Local file indicator
          if (isLocal)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Local',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(imagePath, isLocal: isLocal),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context) {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _showImagePickerOptions,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isUploadingImage
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: context.colorScheme.outline,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose Multiple'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultipleImages();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        await _uploadImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      for (final file in pickedFiles) {
        await _uploadImage(file.path);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick images: $e');
      }
    }
  }

  Future<void> _uploadImage(String localPath) async {
    setState(() => _isUploadingImage = true);

    try {
      if (AppConfig.demoMode) {
        // In demo mode, just keep as pending local image
        setState(() {
          _pendingLocalImagePaths.add(localPath);
          _isUploadingImage = false;
        });
        return;
      }

      // Upload to Firebase Storage
      final storageService = ref.read(storageServiceProvider);
      final stopId = widget.existingStop?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final imageIndex = _images.length + _pendingLocalImagePaths.length;

      final downloadUrl = await storageService.uploadStopImage(
        tourId: widget.tourId,
        stopId: stopId,
        imageFile: File(localPath),
        imageIndex: imageIndex,
      );

      setState(() {
        _images.add(StopImage(url: downloadUrl, order: imageIndex));
        _isUploadingImage = false;
      });

      if (mounted) {
        context.showSuccessSnackBar('Image uploaded');
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to upload image: $e');
      }
    }
  }

  void _removeImage(String imagePath, {required bool isLocal}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Image?'),
        content: const Text('This will remove the image from this stop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                if (isLocal) {
                  _pendingLocalImagePaths.remove(imagePath);
                } else {
                  _images.removeWhere((img) => img.url == imagePath);
                }
              });
              context.showSuccessSnackBar('Image removed');
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveStop() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPosition == null) {
      context.showErrorSnackBar('Please select a location on the map');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Calculate geohash for the location
      final geohash = GeohashUtils.encode(
        _selectedPosition!.lat.toDouble(),
        _selectedPosition!.lng.toDouble(),
      );

      // Create media model
      // Combine uploaded images with any pending local images (converted to StopImage)
      final allImages = [
        ..._images,
        ..._pendingLocalImagePaths.asMap().entries.map(
              (e) => StopImage(url: e.value, order: _images.length + e.key),
            ),
      ];
      final media = StopMedia(
        audioUrl: _audioUrl ?? _localAudioPath,
        audioSource: _audioSource ?? AudioSource.recorded,
        audioText: _scriptController.text.isNotEmpty ? _scriptController.text : null,
        images: allImages,
      );

      // Create stop model
      final now = DateTime.now();
      final stop = StopModel(
        id: widget.existingStop?.id ?? '',
        tourId: widget.tourId,
        versionId: widget.versionId,
        order: widget.stopOrder,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: GeoPoint(
          _selectedPosition!.lat.toDouble(),
          _selectedPosition!.lng.toDouble(),
        ),
        geohash: geohash,
        triggerRadius: _triggerRadius.toInt(),
        media: media,
        createdAt: widget.existingStop?.createdAt ?? now,
        updatedAt: now,
      );

      // Return the stop data
      if (mounted) {
        Navigator.pop(context, stop);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to save stop: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
