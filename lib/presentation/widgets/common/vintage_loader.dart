import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../../config/theme/typography.dart';

/// Skeuomorphic progress indicators for the Boutique Editorial design system.
///
/// Replaces standard Material loading indicators with themed alternatives:
/// - [VintageLoader.compass] — Rotating compass rose spinner
/// - [VintageLoader.inkProgress] — Ink-fill linear progress bar
/// - [VintageLoader.quill] — Quill pen drawing animation
///
/// Usage:
/// ```dart
/// VintageLoader.compass(size: 48)
/// VintageLoader.inkProgress(progress: 0.6)
/// ```
class VintageLoader extends StatelessWidget {
  const VintageLoader._({
    super.key,
    required this.type,
    this.size = 40,
    this.progress,
    this.label,
    this.color,
  });

  /// Rotating compass rose spinner for general loading.
  factory VintageLoader.compass({Key? key, double size = 40, Color? color}) =>
      VintageLoader._(key: key, type: _LoaderType.compass, size: size, color: color);

  /// Ink-fill linear progress bar for determinate progress.
  factory VintageLoader.inkProgress({
    Key? key,
    required double progress,
    String? label,
    Color? color,
  }) => VintageLoader._(
    key: key,
    type: _LoaderType.inkProgress,
    progress: progress,
    label: label,
    color: color,
  );

  /// Quill pen drawing dots animation for indeterminate loading.
  factory VintageLoader.quill({Key? key, double size = 40, Color? color}) =>
      VintageLoader._(key: key, type: _LoaderType.quill, size: size, color: color);

  final _LoaderType type;
  final double size;
  final double? progress;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _LoaderType.compass:
        return _CompassSpinner(size: size, color: color);
      case _LoaderType.inkProgress:
        return _InkProgressBar(progress: progress ?? 0, label: label, color: color);
      case _LoaderType.quill:
        return _QuillDots(size: size, color: color);
    }
  }
}

enum _LoaderType { compass, inkProgress, quill }

/// Rotating compass rose — a custom-painted compass needle that spins.
class _CompassSpinner extends StatefulWidget {
  const _CompassSpinner({required this.size, this.color});
  final double size;
  final Color? color;

  @override
  State<_CompassSpinner> createState() => _CompassSpinnerState();
}

class _CompassSpinnerState extends State<_CompassSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CompassPainter(rotation: _controller.value * 2 * math.pi, color: color),
        );
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.rotation, required this.color});
  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Outer circle
    final circlePaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, radius - 2, circlePaint);

    // Compass needle - north (gold)
    final northPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final northPath =
        Path()
          ..moveTo(0, -(radius - 6))
          ..lineTo(-4, 0)
          ..lineTo(4, 0)
          ..close();
    canvas.drawPath(northPath, northPaint);

    // Compass needle - south (sepia)
    final southPaint =
        Paint()
          ..color = AppColors.accent.withOpacity(0.6)
          ..style = PaintingStyle.fill;
    final southPath =
        Path()
          ..moveTo(0, radius - 6)
          ..lineTo(-4, 0)
          ..lineTo(4, 0)
          ..close();
    canvas.drawPath(southPath, southPaint);

    // Center dot
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 3, dotPaint);

    // Tick marks at cardinal points
    final tickPaint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final outerPoint = Offset(
        (radius - 2) * math.cos(angle - math.pi / 2),
        (radius - 2) * math.sin(angle - math.pi / 2),
      );
      final innerPoint = Offset(
        (radius - 8) * math.cos(angle - math.pi / 2),
        (radius - 8) * math.sin(angle - math.pi / 2),
      );
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) => oldDelegate.rotation != rotation;
}

/// Ink-fill progress bar — a horizontal bar that fills like ink spreading.
class _InkProgressBar extends StatelessWidget {
  const _InkProgressBar({required this.progress, this.label, this.color});

  final double progress;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.accentLight.withOpacity(0.2), width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: clampedProgress),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(widthFactor: value, child: child);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [barColor.withOpacity(0.7), barColor]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Label
        if (label != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AppTypography.annotation),
              Text(
                '${(clampedProgress * 100).toInt()}%',
                style: AppTypography.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Quill pen dots — three dots that pulse in sequence like ink drops.
class _QuillDots extends StatefulWidget {
  const _QuillDots({required this.size, this.color});
  final double size;
  final Color? color;

  @override
  State<_QuillDots> createState() => _QuillDotsState();
}

class _QuillDotsState extends State<_QuillDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final dotSize = widget.size / 5;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * math.sin(value * math.pi);
            final opacity = 0.3 + 0.7 * math.sin(value * math.pi);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dotSize * 0.4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
