import 'package:flutter/material.dart';

import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/neumorphic.dart';

/// A neumorphic-styled card with soft shadows
///
/// Provides a raised, extruded appearance that gives depth
/// without harsh drop shadows.
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final bool pressed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double intensity;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
    this.pressed = false,
    this.onTap,
    this.onLongPress,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? AppColors.surfaceDark : AppColors.surface);

    final shadows = pressed
        ? Neumorphic.flat
        : isDark
            ? Neumorphic.raisedDark(intensity: intensity)
            : Neumorphic.raised(intensity: intensity);

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: container,
      );
    }

    return container;
  }
}

/// A neumorphic button with pressed state
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final bool enabled;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius = 14,
    this.color,
    this.enabled = true,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.color ?? (isDark ? AppColors.surfaceDark : AppColors.surface);

    final shadows = _isPressed || !widget.enabled
        ? Neumorphic.flat
        : isDark
            ? Neumorphic.raisedDark(intensity: 0.7, blur: 15, offset: const Offset(5, 5))
            : Neumorphic.raised(intensity: 0.7, blur: 15, offset: const Offset(5, 5));

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: widget.padding ?? AppSpacing.buttonPadding,
        decoration: BoxDecoration(
          color: widget.enabled ? bgColor : bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: shadows,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: widget.enabled
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                : AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A neumorphic icon button
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
  });

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surface);
    final iconColor = widget.iconColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    final shadows = _isPressed || !widget.enabled
        ? Neumorphic.flat
        : isDark
            ? Neumorphic.raisedDark(intensity: 0.6, blur: 12, offset: const Offset(4, 4))
            : Neumorphic.raised(intensity: 0.6, blur: 12, offset: const Offset(4, 4));

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.enabled ? bgColor : bgColor.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: shadows,
        ),
        child: Icon(
          widget.icon,
          size: widget.size * 0.5,
          color: widget.enabled ? iconColor : AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// A neumorphic container for inset/pressed appearance
class NeumorphicInset extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const NeumorphicInset({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ??
        (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark ? null : Neumorphic.inset(),
      ),
      child: child,
    );
  }
}

/// A neumorphic progress indicator
class NeumorphicProgress extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final double borderRadius;

  const NeumorphicProgress({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final fillColor = progressColor ?? AppColors.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark ? null : Neumorphic.inset(intensity: 0.5, blur: 8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
