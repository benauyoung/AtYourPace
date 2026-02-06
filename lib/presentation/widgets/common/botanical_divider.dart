import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';

/// A decorative botanical divider — wavy line with small dots.
///
/// Replaces flat `<hr>` dividers with an organic, hand-drawn feel.
/// Use between sections on detail screens, in bottom sheets, etc.
///
/// ```dart
/// BotanicalDivider()
/// BotanicalDivider(color: AppColors.primary, width: 200)
/// ```
class BotanicalDivider extends StatelessWidget {
  final Color? color;
  final double? width;
  final double height;
  final double dotSize;

  const BotanicalDivider({
    super.key,
    this.color,
    this.width,
    this.height = 20,
    this.dotSize = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: CustomPaint(
        painter: _BotanicalDividerPainter(
          color: color ?? AppColors.borderLinen,
          dotSize: dotSize,
        ),
      ),
    );
  }
}

class _BotanicalDividerPainter extends CustomPainter {
  final Color color;
  final double dotSize;

  _BotanicalDividerPainter({required this.color, required this.dotSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final margin = 24.0;

    // Draw wavy line
    final path = Path();
    path.moveTo(margin, centerY);

    final waveWidth = size.width - margin * 2;
    const segments = 12;
    final segmentWidth = waveWidth / segments;
    const amplitude = 2.5;

    for (int i = 0; i < segments; i++) {
      final x1 = margin + segmentWidth * i + segmentWidth / 2;
      final y1 = centerY + (i.isEven ? -amplitude : amplitude);
      final x2 = margin + segmentWidth * (i + 1);
      final y2 = centerY;
      path.quadraticBezierTo(x1, y1, x2, y2);
    }

    canvas.drawPath(path, paint);

    // Draw dots at each end and center
    canvas.drawCircle(Offset(margin - 8, centerY), dotSize, dotPaint);
    canvas.drawCircle(Offset(size.width / 2, centerY), dotSize, dotPaint);
    canvas.drawCircle(Offset(size.width - margin + 8, centerY), dotSize, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _BotanicalDividerPainter oldDelegate) =>
      color != oldDelegate.color || dotSize != oldDelegate.dotSize;
}
