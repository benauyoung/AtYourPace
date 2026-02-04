import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/neumorphic.dart';
import 'view_models/marketplace_view_model.dart';
import 'widgets/marketplace_list_view.dart';
import 'widgets/marketplace_map_view.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to update view mode in ViewModel
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Just updated
        final isMap = _tabController.index == 1;
        // Access provider safely without watching in initState
        final currentIsMap = ref.read(marketplaceProvider).isMapView;
        if (isMap != currentIsMap) {
          ref.read(marketplaceProvider.notifier).toggleViewMode();
        }
      }
    });

    // Listen to search changes
    _searchController.addListener(() {
      ref.read(marketplaceProvider.notifier).setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch view mode to sync tab controller if changed externally (e.g. from a "Map" button in list view)
    ref.listen(marketplaceProvider.select((s) => s.isMapView), (previous, isMap) {
      if (isMap && _tabController.index != 1) {
        _tabController.animateTo(1);
      } else if (!isMap && _tabController.index != 0) {
        _tabController.animateTo(0);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search and Tabs
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: Neumorphic.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for tours, cities, or tags...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Map/List Toggle
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg - 2),
                      ),
                      labelColor: theme.colorScheme.onPrimary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_rounded),
                              SizedBox(width: 8),
                              Text('List view'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_rounded),
                              SizedBox(width: 8),
                              Text('Map view'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe to avoid conflict with map
                children: const [MarketplaceListView(), MarketplaceMapView()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
