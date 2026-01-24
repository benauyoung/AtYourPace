import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_providers.dart';

class TourReviewsSection extends ConsumerWidget {
  final String tourId;
  final TourStats stats;

  const TourReviewsSection({
    super.key,
    required this.tourId,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(tourReviewsProvider(tourId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with rating summary
        Row(
          children: [
            Text(
              'Reviews',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (currentUser != null)
              TextButton.icon(
                onPressed: () => _showWriteReviewDialog(context, ref),
                icon: const Icon(Icons.rate_review),
                label: const Text('Write Review'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Rating summary card
        _RatingSummaryCard(stats: stats),
        const SizedBox(height: 16),

        // Reviews list
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return _EmptyReviews(
                onWriteReview: currentUser != null
                    ? () => _showWriteReviewDialog(context, ref)
                    : null,
              );
            }

            return Column(
              children: [
                ...reviews.take(3).map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(review: review),
                )),
                if (reviews.length > 3)
                  OutlinedButton(
                    onPressed: () => _showAllReviews(context, reviews),
                    child: Text('See all ${reviews.length} reviews'),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Error loading reviews: $error'),
            ),
          ),
        ),
      ],
    );
  }

  void _showWriteReviewDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => WriteReviewSheet(
        tourId: tourId,
        onSubmit: (rating, comment) async {
          // Submit review to Firestore
          final submitService = ref.read(submitReviewProvider);
          await submitService.submitReview(
            tourId: tourId,
            rating: rating,
            comment: comment.isNotEmpty ? comment : null,
          );
        },
      ),
    );
  }

  void _showAllReviews(BuildContext context, List<ReviewModel> reviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'All Reviews (${reviews.length})',
                    style: context.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(review: reviews[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  final TourStats stats;

  const _RatingSummaryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Big rating number
            Column(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final rating = stats.averageRating;
                    if (index < rating.floor()) {
                      return const Icon(Icons.star, color: Colors.amber, size: 16);
                    } else if (index < rating) {
                      return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                    }
                    return const Icon(Icons.star_border, color: Colors.amber, size: 16);
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.totalRatings} reviews',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),

            // Rating bars
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  // Demo distribution
                  final percentage = star == 5 ? 0.6 : star == 4 ? 0.25 : star == 3 ? 0.1 : 0.05;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: context.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: context.colorScheme.surfaceContainerHighest,
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.userPhotoUrl != null
                      ? NetworkImage(review.userPhotoUrl!)
                      : null,
                  child: review.userPhotoUrl == null
                      ? Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          )),
                          const SizedBox(width: 8),
                          Text(
                            review.formattedDate,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  final VoidCallback? onWriteReview;

  const _EmptyReviews({this.onWriteReview});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your experience!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onWriteReview != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onWriteReview,
                icon: const Icon(Icons.edit),
                label: const Text('Write a Review'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WriteReviewSheet extends StatefulWidget {
  final String tourId;
  final Future<void> Function(int rating, String comment) onSubmit;

  const WriteReviewSheet({
    super.key,
    required this.tourId,
    required this.onSubmit,
  });

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Write a Review',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rating
            Text(
              'How would you rate this tour?',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNumber = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starNumber),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starNumber <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingText(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Comment
            Text(
              'Share your experience',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'What did you enjoy about this tour?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _rating == 0 || _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap to rate';
    }
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_rating, _commentController.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
