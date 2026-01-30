import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tour_editor_provider.dart';

/// Pricing tab for tour editing - free/paid configuration
class PricingModule extends ConsumerStatefulWidget {
  final String? tourId;
  final String? versionId;

  const PricingModule({
    super.key,
    this.tourId,
    this.versionId,
  });

  @override
  ConsumerState<PricingModule> createState() => _PricingModuleState();
}

class _PricingModuleState extends ConsumerState<PricingModule> {
  late TextEditingController _priceController;
  String _selectedCurrency = 'EUR';

  static const _currencies = [
    ('EUR', '€', 'Euro'),
    ('USD', '\$', 'US Dollar'),
    ('GBP', '£', 'British Pound'),
  ];

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialValues();
    });
  }

  void _loadInitialValues() {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.read(tourEditorProvider(params));

    if (state.price != null) {
      _priceController.text = state.price!.toStringAsFixed(2);
    }
    _selectedCurrency = state.currency;
    setState(() {});
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

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
          // Pricing Type Selection
          _buildSectionHeader(context, 'Pricing Type'),
          const SizedBox(height: 16),
          _buildPricingTypeSelector(context, state, notifier),
          const SizedBox(height: 32),

          // Price Configuration (only if paid)
          if (!state.isFree) ...[
            _buildSectionHeader(context, 'Price'),
            const SizedBox(height: 16),
            _buildPriceInput(context, state, notifier),
            const SizedBox(height: 32),

            // Currency Selection
            _buildSectionHeader(context, 'Currency'),
            const SizedBox(height: 16),
            _buildCurrencySelector(context, notifier),
            const SizedBox(height: 32),
          ],

          // Pricing Guidelines
          _buildSectionHeader(context, 'Pricing Guidelines'),
          const SizedBox(height: 16),
          _buildPricingGuidelines(context, state),
          const SizedBox(height: 32),

          // Revenue Info
          _buildRevenueInfo(context, state),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildPricingTypeSelector(
    BuildContext context,
    TourEditorState state,
    TourEditorNotifier notifier,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildPricingOption(
            context,
            icon: Icons.card_giftcard,
            title: 'Free',
            description: 'Anyone can access this tour',
            isSelected: state.isFree,
            onTap: () => notifier.setFree(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPricingOption(
            context,
            icon: Icons.attach_money,
            title: 'Paid',
            description: 'Set a price for your tour',
            isSelected: !state.isFree,
            onTap: () => notifier.setPaid(4.99),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                        : colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput(
    BuildContext context,
    TourEditorState state,
    TourEditorNotifier notifier,
  ) {
    final currencySymbol =
        _currencies.firstWhere((c) => c.$1 == _selectedCurrency).$2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            currencySymbol,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          width: 150,
          child: TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(8),
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (value) {
              final price = double.tryParse(value);
              if (price != null && price > 0) {
                notifier.updatePricing(price: price);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        // Quick price buttons
        Wrap(
          spacing: 8,
          children: [2.99, 4.99, 7.99, 9.99].map((price) {
            return ActionChip(
              label: Text('$currencySymbol${price.toStringAsFixed(2)}'),
              onPressed: () {
                _priceController.text = price.toStringAsFixed(2);
                notifier.updatePricing(price: price);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    TourEditorNotifier notifier,
  ) {
    return SegmentedButton<String>(
      segments: _currencies.map((currency) {
        return ButtonSegment<String>(
          value: currency.$1,
          label: Text('${currency.$2} ${currency.$1}'),
        );
      }).toList(),
      selected: {_selectedCurrency},
      onSelectionChanged: (selection) {
        setState(() => _selectedCurrency = selection.first);
        notifier.updatePricing(currency: selection.first);
      },
    );
  }

  Widget _buildPricingGuidelines(BuildContext context, TourEditorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isFree) ...[
              _buildGuidelineItem(
                context,
                icon: Icons.groups,
                title: 'Maximum Reach',
                description:
                    'Free tours get more downloads and help build your reputation',
              ),
              const SizedBox(height: 12),
              _buildGuidelineItem(
                context,
                icon: Icons.star_outline,
                title: 'Reviews Matter',
                description:
                    'More users means more reviews and visibility',
              ),
            ] else ...[
              _buildGuidelineItem(
                context,
                icon: Icons.trending_up,
                title: 'Market Rates',
                description:
                    'Most audio tours are priced between €3-10',
              ),
              const SizedBox(height: 12),
              _buildGuidelineItem(
                context,
                icon: Icons.timer,
                title: 'Value for Duration',
                description:
                    '30-60 min tours: €3-5, 1-2 hour tours: €5-10',
              ),
              const SizedBox(height: 12),
              _buildGuidelineItem(
                context,
                icon: Icons.workspace_premium,
                title: 'Quality Premium',
                description:
                    'Professional narration and unique content can command higher prices',
              ),
            ],
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

  Widget _buildRevenueInfo(BuildContext context, TourEditorState state) {
    if (state.isFree) return const SizedBox.shrink();

    final price = state.price ?? 0;
    final platformFee = price * 0.30; // 30% platform fee
    final creatorRevenue = price - platformFee;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Revenue Breakdown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRevenueItem(
                    context,
                    label: 'Tour Price',
                    value: '€${price.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildRevenueItem(
                    context,
                    label: 'Platform Fee (30%)',
                    value: '-€${platformFee.toStringAsFixed(2)}',
                    isNegative: true,
                  ),
                ),
                Expanded(
                  child: _buildRevenueItem(
                    context,
                    label: 'Your Revenue',
                    value: '€${creatorRevenue.toStringAsFixed(2)}',
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Revenue per sale. Payments are processed monthly via Stripe.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(
    BuildContext context, {
    required String label,
    required String value,
    bool isNegative = false,
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isNegative
                    ? Theme.of(context).colorScheme.error
                    : isHighlighted
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
        ),
      ],
    );
  }
}
