import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/stop_model.dart';
import '../../../data/models/tour_model.dart';
import '../../../data/models/tour_version_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tour_providers.dart';
import 'stop_editor_screen.dart';

/// Provider for tour editor state
final tourEditorProvider =
    StateNotifierProvider.autoDispose<TourEditorNotifier, TourEditorState>(
        (ref) {
  return TourEditorNotifier();
});

class TourEditorState {
  final String? tourId;
  final String title;
  final String description;
  final TourType tourType;
  final TourCategory category;
  final String? coverImageUrl;
  final List<StopModel> stops;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final GeoPoint? startLocation;
  final String city;
  final String country;

  const TourEditorState({
    this.tourId,
    this.title = '',
    this.description = '',
    this.tourType = TourType.walking,
    this.category = TourCategory.history,
    this.coverImageUrl,
    this.stops = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.startLocation,
    this.city = '',
    this.country = '',
  });

  TourEditorState copyWith({
    String? tourId,
    String? title,
    String? description,
    TourType? tourType,
    TourCategory? category,
    String? coverImageUrl,
    List<StopModel>? stops,
    bool? isLoading,
    bool? isSaving,
    String? error,
    GeoPoint? startLocation,
    String? city,
    String? country,
  }) {
    return TourEditorState(
      tourId: tourId ?? this.tourId,
      title: title ?? this.title,
      description: description ?? this.description,
      tourType: tourType ?? this.tourType,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      stops: stops ?? this.stops,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      startLocation: startLocation ?? this.startLocation,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  bool get isValid =>
      title.isNotEmpty && description.isNotEmpty && stops.isNotEmpty;
}

class TourEditorNotifier extends StateNotifier<TourEditorState> {
  TourEditorNotifier() : super(const TourEditorState());

  void setTitle(String title) => state = state.copyWith(title: title);
  void setDescription(String desc) => state = state.copyWith(description: desc);
  void setTourType(TourType type) => state = state.copyWith(tourType: type);
  void setCategory(TourCategory cat) => state = state.copyWith(category: cat);
  void setCoverImage(String? url) => state = state.copyWith(coverImageUrl: url);
  void setCity(String city) => state = state.copyWith(city: city);
  void setCountry(String country) => state = state.copyWith(country: country);

  void loadTour(TourModel tour, TourVersionModel version, List<StopModel> stops) {
    state = TourEditorState(
      tourId: tour.id,
      title: version.title,
      description: version.description,
      tourType: tour.tourType,
      category: tour.category,
      coverImageUrl: version.coverImageUrl,
      stops: stops,
      startLocation: tour.startLocation,
      city: tour.city ?? '',
      country: tour.country ?? '',
    );
  }

  void addStop(StopModel stop) {
    final newStops = [...state.stops, stop];
    // Update start location if this is the first stop
    final startLocation =
        state.stops.isEmpty ? stop.location : state.startLocation;
    state = state.copyWith(stops: newStops, startLocation: startLocation);
  }

  void updateStop(int index, StopModel stop) {
    final newStops = [...state.stops];
    newStops[index] = stop;
    state = state.copyWith(stops: newStops);
  }

  void removeStop(int index) {
    final newStops = [...state.stops];
    newStops.removeAt(index);
    // Reorder stops
    for (int i = 0; i < newStops.length; i++) {
      newStops[i] = newStops[i].copyWith(order: i);
    }
    state = state.copyWith(stops: newStops);
  }

  void reorderStops(int oldIndex, int newIndex) {
    final newStops = [...state.stops];
    final stop = newStops.removeAt(oldIndex);
    newStops.insert(newIndex, stop);
    // Update order
    for (int i = 0; i < newStops.length; i++) {
      newStops[i] = newStops[i].copyWith(order: i);
    }
    state = state.copyWith(stops: newStops);
  }

  void setSaving(bool saving) => state = state.copyWith(isSaving: saving);
  void setError(String? error) => state = state.copyWith(error: error);
  void setTourId(String tourId) => state = state.copyWith(tourId: tourId);
}

class TourEditorScreen extends ConsumerStatefulWidget {
  final String? tourId;

  const TourEditorScreen({super.key, this.tourId});

  @override
  ConsumerState<TourEditorScreen> createState() => _TourEditorScreenState();
}

class _TourEditorScreenState extends ConsumerState<TourEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  bool get isEditing => widget.tourId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();

    // Load existing tour if editing
    if (isEditing) {
      _loadTour();
    }
  }

  Future<void> _loadTour() async {
    if (widget.tourId == null) return;

    final tour = await ref.read(tourByIdProvider(widget.tourId!).future);
    if (tour == null) return;

    final versionId = tour.draftVersionId;
    final version = await ref.read(
      tourVersionProvider((tourId: tour.id, versionId: versionId)).future,
    );
    if (version == null) return;

    final stops = await ref.read(
      stopsProvider((tourId: tour.id, versionId: versionId)).future,
    );

    ref.read(tourEditorProvider.notifier).loadTour(tour, version, stops);

    _titleController.text = version.title;
    _descriptionController.text = version.description;
    _cityController.text = tour.city ?? '';
    _countryController.text = tour.country ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(tourEditorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tour' : 'Create Tour'),
        actions: [
          if (editorState.stops.isNotEmpty)
            TextButton(
              onPressed: editorState.isSaving ? null : _submitForReview,
              child: const Text('Submit'),
            ),
          TextButton(
            onPressed: editorState.isSaving ? null : _saveDraft,
            child: editorState.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cover image
            _CoverImagePicker(
              imageUrl: editorState.coverImageUrl,
              tourId: widget.tourId ?? editorState.tourId,
              onImageSelected: (url) {
                ref.read(tourEditorProvider.notifier).setCoverImage(url);
              },
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tour Title *',
                hintText: 'e.g., Historic Downtown Walking Tour',
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (value) {
                ref.read(tourEditorProvider.notifier).setTitle(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe what makes this tour special...',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                ref.read(tourEditorProvider.notifier).setDescription(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      hintText: 'e.g., San Francisco',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: (value) {
                      ref.read(tourEditorProvider.notifier).setCity(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                      hintText: 'e.g., United States',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    onChanged: (value) {
                      ref.read(tourEditorProvider.notifier).setCountry(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tour type selection
            Text(
              'Tour Type',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TourType>(
              segments: const [
                ButtonSegment(
                  value: TourType.walking,
                  label: Text('Walking'),
                  icon: Icon(Icons.directions_walk),
                ),
                ButtonSegment(
                  value: TourType.driving,
                  label: Text('Driving'),
                  icon: Icon(Icons.directions_car),
                ),
              ],
              selected: {editorState.tourType},
              onSelectionChanged: (selection) {
                ref
                    .read(tourEditorProvider.notifier)
                    .setTourType(selection.first);
              },
            ),
            const SizedBox(height: 24),

            // Category selection
            Text(
              'Category',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TourCategory.values.map((category) {
                final isSelected = editorState.category == category;
                return FilterChip(
                  label: Text(category.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(tourEditorProvider.notifier)
                          .setCategory(category);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Stops section
            _StopsSection(
              stops: editorState.stops,
              tourId: widget.tourId ?? 'new',
              onAddStop: _addStop,
              onEditStop: _editStop,
              onDeleteStop: _deleteStop,
              onReorder: _reorderStops,
            ),

            const SizedBox(height: 32),

            // Submission info
            if (editorState.stops.isEmpty)
              Card(
                color: context.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add at least one stop to submit your tour for review.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addStop() async {
    final editorState = ref.read(tourEditorProvider);
    final result = await Navigator.push<StopModel>(
      context,
      MaterialPageRoute(
        builder: (context) => StopEditorScreen(
          tourId: widget.tourId ?? 'new',
          versionId: 'draft',
          stopOrder: editorState.stops.length,
        ),
      ),
    );

    if (result != null) {
      ref.read(tourEditorProvider.notifier).addStop(result);
    }
  }

  Future<void> _editStop(int index) async {
    final editorState = ref.read(tourEditorProvider);
    final existingStop = editorState.stops[index];

    final result = await Navigator.push<StopModel>(
      context,
      MaterialPageRoute(
        builder: (context) => StopEditorScreen(
          tourId: widget.tourId ?? 'new',
          versionId: 'draft',
          existingStop: existingStop,
          stopOrder: index,
        ),
      ),
    );

    if (result != null) {
      ref.read(tourEditorProvider.notifier).updateStop(index, result);
    }
  }

  void _deleteStop(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stop'),
        content: const Text('Are you sure you want to delete this stop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(tourEditorProvider.notifier).removeStop(index);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reorderStops(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    ref.read(tourEditorProvider.notifier).reorderStops(oldIndex, newIndex);
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(tourEditorProvider.notifier).setSaving(true);

    try {
      // In demo mode, just show success
      if (AppConfig.demoMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.showSuccessSnackBar('Tour saved as draft');
          context.go(RouteNames.creatorDashboard);
        }
        return;
      }

      // Save to Firestore
      final editorState = ref.read(tourEditorProvider);
      final tourService = ref.read(tourManagementServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;

      if (currentUser == null) {
        throw Exception('User must be signed in to save tours');
      }

      if (editorState.startLocation == null) {
        throw Exception('Start location is required');
      }

      // Generate version ID
      final versionId = editorState.tourId != null
          ? 'draft_v${DateTime.now().millisecondsSinceEpoch}'
          : 'draft_v1';

      // Build tour model
      final tour = TourModel(
        id: editorState.tourId ?? '',
        creatorId: currentUser.uid,
        creatorName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        category: editorState.category,
        tourType: editorState.tourType,
        status: TourStatus.draft,
        startLocation: editorState.startLocation!,
        geohash: '', // Will be calculated by service
        city: editorState.city.isNotEmpty ? editorState.city : null,
        country: editorState.country.isNotEmpty ? editorState.country : null,
        draftVersionId: versionId,
        draftVersion: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Build version model
      final version = TourVersionModel(
        id: versionId,
        tourId: editorState.tourId ?? '',
        versionNumber: 1,
        versionType: VersionType.draft,
        title: editorState.title,
        description: editorState.description,
        coverImageUrl: editorState.coverImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save tour
      final savedTourId = await tourService.saveTourDraft(
        tourId: editorState.tourId,
        tour: tour,
        version: version,
        stops: editorState.stops,
      );

      // Update state with tour ID if it was newly created
      if (editorState.tourId == null) {
        ref.read(tourEditorProvider.notifier).setTourId(savedTourId);
      }

      if (mounted) {
        context.showSuccessSnackBar('Tour saved as draft');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to save tour: $e');
      }
    } finally {
      ref.read(tourEditorProvider.notifier).setSaving(false);
    }
  }

  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) return;

    final editorState = ref.read(tourEditorProvider);
    if (editorState.stops.isEmpty) {
      context.showErrorSnackBar('Add at least one stop before submitting');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit for Review'),
        content: const Text(
          'Your tour will be reviewed by our team before it becomes visible to users. '
          'You can still edit your tour while it\'s pending review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    ref.read(tourEditorProvider.notifier).setSaving(true);

    try {
      // In demo mode, just show success
      if (AppConfig.demoMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.showSuccessSnackBar('Tour submitted for review');
          context.go(RouteNames.creatorDashboard);
        }
        return;
      }

      // Submit to Firestore with pending_review status
      final editorState = ref.read(tourEditorProvider);

      // Ensure tour is saved first
      if (editorState.tourId == null) {
        // Save the tour first
        await _saveDraft();
        // Get the updated state after save
        final updatedState = ref.read(tourEditorProvider);
        if (updatedState.tourId == null) {
          throw Exception('Failed to save tour before submission');
        }
      }

      final tourService = ref.read(tourManagementServiceProvider);
      final finalState = ref.read(tourEditorProvider);

      await tourService.submitForReview(finalState.tourId!);

      if (mounted) {
        context.showSuccessSnackBar('Tour submitted for review');
        context.go(RouteNames.creatorDashboard);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to submit tour: $e');
      }
    } finally {
      ref.read(tourEditorProvider.notifier).setSaving(false);
    }
  }
}

class _CoverImagePicker extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String? tourId;
  final ValueChanged<String?> onImageSelected;

  const _CoverImagePicker({
    this.imageUrl,
    this.tourId,
    required this.onImageSelected,
  });

  @override
  ConsumerState<_CoverImagePicker> createState() => _CoverImagePickerState();
}

class _CoverImagePickerState extends ConsumerState<_CoverImagePicker> {
  bool _isUploading = false;
  String? _localImagePath;

  @override
  Widget build(BuildContext context) {
    final displayImage = _localImagePath ?? widget.imageUrl;
    final isLocalImage = _localImagePath != null;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image display
            if (displayImage != null)
              isLocalImage && !kIsWeb
                  ? Image.file(
                      File(displayImage),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      displayImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),

            // Empty state or overlay
            InkWell(
              onTap: _isUploading ? null : _showPickerOptions,
              child: displayImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Cover Image',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // Upload indicator
            if (_isUploading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Edit button when image exists
            if (displayImage != null && !_isUploading)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _showPickerOptions,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: _removeCoverImage,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
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
                subtitle: const Text('Take a photo and crop it'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select an image and crop it'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _cropImage(String imagePath) async {
    // Skip cropping on web platform
    if (kIsWeb) return imagePath;

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Cover Image',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Cover Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );

      return croppedFile?.path;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      // Return original path if cropping fails
      return imagePath;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return;

      // Crop the image
      final croppedPath = await _cropImage(image.path);
      if (croppedPath == null) return;

      setState(() {
        _localImagePath = croppedPath;
        _isUploading = true;
      });

      if (AppConfig.demoMode) {
        // In demo mode, just show the local preview
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() => _isUploading = false);
        widget.onImageSelected(croppedPath);
        if (mounted) {
          context.showSuccessSnackBar('Cover image selected');
        }
        return;
      }

      // Upload to Firebase Storage
      final storageService = ref.read(storageServiceProvider);
      final tourId = widget.tourId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Read cropped file bytes
      final bytes = await File(croppedPath).readAsBytes();

      final downloadUrl = await storageService.uploadTourCover(
        tourId: tourId,
        imageBytes: bytes,
      );

      setState(() {
        _localImagePath = null;
        _isUploading = false;
      });

      widget.onImageSelected(downloadUrl);

      if (mounted) {
        context.showSuccessSnackBar('Cover image uploaded');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to upload image: $e');
      }
    }
  }

  void _removeCoverImage() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Cover Image?'),
        content: const Text('This will remove the cover image from your tour.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _localImagePath = null;
              });
              widget.onImageSelected(null);
              context.showSuccessSnackBar('Cover image removed');
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
}

class _StopsSection extends StatelessWidget {
  final List<StopModel> stops;
  final String tourId;
  final VoidCallback onAddStop;
  final void Function(int index) onEditStop;
  final void Function(int index) onDeleteStop;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _StopsSection({
    required this.stops,
    required this.tourId,
    required this.onAddStop,
    required this.onEditStop,
    required this.onDeleteStop,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.place, color: context.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Stops (${stops.length})',
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: onAddStop,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stops.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 48,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No stops added yet',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Add Stop" to create your first stop',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stops.length,
                onReorder: onReorder,
                itemBuilder: (context, index) {
                  final stop = stops[index];
                  return _StopListItem(
                    key: ValueKey(stop.id),
                    stop: stop,
                    index: index,
                    onEdit: () => onEditStop(index),
                    onDelete: () => onDeleteStop(index),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StopListItem extends StatelessWidget {
  final StopModel stop;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StopListItem({
    super.key,
    required this.stop,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colorScheme.primaryContainer,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(stop.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stop.description.isNotEmpty)
              Text(
                stop.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  stop.hasAudio ? Icons.audiotrack : Icons.audiotrack_outlined,
                  size: 16,
                  color: stop.hasAudio
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  stop.hasAudio ? 'Audio added' : 'No audio',
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stop.triggerRadius}m radius',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: context.colorScheme.error,
              ),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
