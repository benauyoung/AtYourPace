import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

class CreatorPile extends StatelessWidget {
  final List<String> imageUrls;
  final double size;
  final double overlap;

  const CreatorPile({super.key, required this.imageUrls, this.size = 40, this.overlap = 0.4});

  @override
  Widget build(BuildContext context) {
    // Show max 5 avatars
    final visibleImages = imageUrls.take(5).toList();
    final remainingCount = imageUrls.length - 5;

    return SizedBox(
      height: size,
      width:
          size * visibleImages.length * (1 - overlap) +
          (remainingCount > 0 ? size : 0) +
          size * overlap,
      child: Stack(
        children: [
          for (int i = 0; i < visibleImages.length; i++)
            Positioned(
              left: i * size * (1 - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colorScheme.surface, width: 2),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(visibleImages[i]),
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          // Placeholder for "Shaka Guide" mock
          if (imageUrls.isEmpty)
            Positioned(
              left: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colorScheme.surface, width: 2),
                ),
                // Mock avatar as seen in screenshot
                child: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text('SG', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
