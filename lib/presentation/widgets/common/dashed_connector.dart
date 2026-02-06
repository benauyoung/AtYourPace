import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';

/// A dashed line connector widget for timelines and route connections.
///
/// Use for "next stop" cards, tour timeline, and map route indicators.
/// Matches the spec: strokeDasharray equivalent of 8px dash, 4px gap.
///
/// ```dart
/// DashedConnector(height: 40) // vertical
/// DashedConnector(width: 100, axis: Axis.horizontal)
/// ```
class DashedConnector extends StatelessWidget {
  final double? height;
  final double? width;
  final Axis axis;
  final Color? color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const DashedConnector({
    super.key,
    this.height,
    this.width,
    this.axis = Axis.vertical,
    this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 8,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: axis == Axis.vertical ? strokeWidth : (width ?? double.infinity),
      height: axis == Axis.vertical ? (height ?? 40) : strokeWidth,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color ?? AppColors.borderLinen,
          strokeWidth: strokeWidth,
          dashLength: dashLength,
          dashGap: dashGap,
          axis: axis,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final Axis axis;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final totalLength = axis == Axis.vertical ? size.height : size.width;
    final dashAndGap = dashLength + dashGap;
    double current = 0;

    while (current < totalLength) {
      final dashEnd = (current + dashLength).clamp(0.0, totalLength);

      if (axis == Axis.vertical) {
        canvas.drawLine(
          Offset(size.width / 2, current),
          Offset(size.width / 2, dashEnd),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(current, size.height / 2),
          Offset(dashEnd, size.height / 2),
          paint,
        );
      }

      current += dashAndGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      dashGap != oldDelegate.dashGap;
}
