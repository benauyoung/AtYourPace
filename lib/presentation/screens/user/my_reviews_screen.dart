import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/skeleton_loader.dart';

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Reviews')),
        body: const Center(
          child: Text('Please log in to see your reviews'),
        ),
      );
    }

    final reviewsAsync = ref.watch(userReviewsProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return EmptyState.noReviews(
              onWriteReview: () => context.go(RouteNames.discover),
            );
          }

          return RefreshableList(
            onRefresh: () async {
              ref.invalidate(userReviewsProvider(currentUser.uid));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  key: ValueKey(review.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(
                    review: review,
                    onTap: () => context.push(
                      RouteNames.tourDetailsPath(review.tourId),
                    ),
                    onEdit: () => _showEditReviewSheet(context, ref, review),
                    onDelete: () => _confirmDeleteReview(context, ref, review),
                  ),
                );
              },
            ),
          );
        },
        loading: () => SkeletonList.reviews(count: 4),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(userReviewsProvider(currentUser.uid)),
        ),
      ),
    );
  }

  void _showEditReviewSheet(BuildContext context, WidgetRef ref, ReviewModel review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EditReviewSheet(
        review: review,
        onSubmit: (rating, comment) async {
          final submitService = ref.read(submitReviewProvider);
          await submitService.submitReview(
            tourId: review.tourId,
            rating: rating,
            comment: comment.isNotEmpty ? comment : null,
          );
        },
      ),
    );
  }

  void _confirmDeleteReview(BuildContext context, WidgetRef ref, ReviewModel review) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Review?'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final deleteService = ref.read(deleteReviewProvider);
                await deleteService.deleteReview(
                  tourId: review.tourId,
                  reviewId: review.id,
                );
                if (context.mounted) {
                  context.showSuccessSnackBar('Review deleted');
                }
              } catch (e) {
                if (context.mounted) {
                  context.showErrorSnackBar('Failed to delete review: $e');
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with rating and date
              Row(
                children: [
                  // Star rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) => Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    )),
                  ),
                  const Spacer(),
                  Text(
                    review.formattedDate,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tour ID (we'd ideally show tour name here)
              Text(
                'Tour: ${review.tourId}',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Comment
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  review.comment!,
                  style: context.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditReviewSheet extends StatefulWidget {
  final ReviewModel review;
  final Future<void> Function(int rating, String comment) onSubmit;

  const _EditReviewSheet({
    required this.review,
    required this.onSubmit,
  });

  @override
  State<_EditReviewSheet> createState() => _EditReviewSheetState();
}

class _EditReviewSheetState extends State<_EditReviewSheet> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;
    _commentController = TextEditingController(text: widget.review.comment ?? '');
  }

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
                  'Edit Review',
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
              'Your Rating',
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
            const SizedBox(height: 24),

            // Comment
            Text(
              'Your Review',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                isLoading: _isSubmitting,
                onPressed: _rating == 0 ? null : _submitReview,
                child: const Text('Update Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_rating, _commentController.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update review: $e'),
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
