import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/tour_model.dart';
import '../../../../../data/models/tour_version_model.dart';
import '../providers/tour_editor_provider.dart';

/// Basic information tab for tour editing
class BasicInfoModule extends ConsumerStatefulWidget {
  final String? tourId;
  final String? versionId;

  const BasicInfoModule({
    super.key,
    this.tourId,
    this.versionId,
  });

  @override
  ConsumerState<BasicInfoModule> createState() => _BasicInfoModuleState();
}

class _BasicInfoModuleState extends ConsumerState<BasicInfoModule> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _regionController;
  late TextEditingController _countryController;

  TourCategory _selectedCategory = TourCategory.history;
  TourType _selectedTourType = TourType.walking;
  TourDifficulty _selectedDifficulty = TourDifficulty.moderate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _cityController = TextEditingController();
    _regionController = TextEditingController();
    _countryController = TextEditingController();

    // Load initial values after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialValues();
    });
  }

  void _loadInitialValues() {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.read(tourEditorProvider(params));

    _titleController.text = state.title == 'Untitled Tour' ? '' : state.title;
    _descriptionController.text = state.description;
    _cityController.text = state.city ?? '';
    _regionController.text = state.region ?? '';
    _countryController.text = state.country ?? '';
    _selectedCategory = state.category;
    _selectedTourType = state.tourType;
    _selectedDifficulty = state.difficulty;

    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    // Watch the provider to rebuild on state changes
    ref.watch(tourEditorProvider(params));
    final notifier = ref.read(tourEditorProvider(params).notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          _buildSectionHeader(context, 'Tour Title', required: true),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Enter a catchy title for your tour',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            maxLength: 100,
            onChanged: (value) => notifier.updateTitle(value),
          ),
          const SizedBox(height: 24),

          // Description Section
          _buildSectionHeader(context, 'Description', required: true),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Describe what makes this tour special...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            maxLength: 1000,
            onChanged: (value) => notifier.updateDescription(value),
          ),
          const SizedBox(height: 24),

          // Category & Type Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Category'),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(notifier),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Tour Type'),
                    const SizedBox(height: 8),
                    _buildTourTypeSelector(notifier),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Difficulty
          _buildSectionHeader(context, 'Difficulty'),
          const SizedBox(height: 8),
          _buildDifficultySelector(notifier),
          const SizedBox(height: 24),

          // Location Section
          _buildSectionHeader(context, 'Location'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notifier.updateBasicInfo(city: value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _regionController,
                  decoration: const InputDecoration(
                    labelText: 'Region/State',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notifier.updateBasicInfo(region: value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notifier.updateBasicInfo(country: value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tags Section (placeholder for future)
          _buildSectionHeader(context, 'Tags'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.label_outline,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tags coming soon...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {bool required = false}) {
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

  Widget _buildCategoryDropdown(TourEditorNotifier notifier) {
    return DropdownButtonFormField<TourCategory>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: TourCategory.values.map((category) {
        return DropdownMenuItem<TourCategory>(
          value: category,
          child: Row(
            children: [
              Icon(category.icon, size: 20),
              const SizedBox(width: 8),
              Text(category.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
          notifier.updateBasicInfo(category: value);
        }
      },
    );
  }

  Widget _buildTourTypeSelector(TourEditorNotifier notifier) {
    return SegmentedButton<TourType>(
      segments: TourType.values.map((type) {
        return ButtonSegment<TourType>(
          value: type,
          label: Text(type.displayName),
          icon: Icon(type.icon),
        );
      }).toList(),
      selected: {_selectedTourType},
      onSelectionChanged: (selection) {
        setState(() => _selectedTourType = selection.first);
        notifier.updateBasicInfo(tourType: selection.first);
      },
    );
  }

  Widget _buildDifficultySelector(TourEditorNotifier notifier) {
    return SegmentedButton<TourDifficulty>(
      segments: TourDifficulty.values.map((difficulty) {
        return ButtonSegment<TourDifficulty>(
          value: difficulty,
          label: Text(difficulty.displayName),
        );
      }).toList(),
      selected: {_selectedDifficulty},
      onSelectionChanged: (selection) {
        setState(() => _selectedDifficulty = selection.first);
        notifier.updateBasicInfo(difficulty: selection.first);
      },
    );
  }
}
