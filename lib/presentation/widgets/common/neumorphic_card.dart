import 'package:flutter/material.dart';

import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/glassmorphic.dart';

/// A glassmorphic-styled card with frosted glass effect
///
/// Provides a frosted glass appearance that floats over the
/// parchment backdrop with subtle sepia shadows.
///
/// Note: Class name kept as NeumorphicCard for backward compatibility.
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
    this.borderRadius = 32,
    this.color,
    this.pressed = false,
    this.onTap,
    this.onLongPress,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration =
        isDark
            ? Glassmorphic.mediumDark(borderRadius: borderRadius)
            : Glassmorphic.medium(borderRadius: borderRadius, tint: color);

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding ?? AppSpacing.cardPadding,
      decoration: decoration,
      transform: pressed ? (Matrix4.identity()..scale(0.97)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(onTap: onTap, onLongPress: onLongPress, child: container);
    }

    return container;
  }
}

/// A glassmorphic button with pressed state
///
/// Note: Class name kept as NeumorphicButton for backward compatibility.
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
    this.borderRadius = 12,
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
    final bgColor = widget.color ?? (isDark ? AppColors.surfaceDark : AppColors.glassMedium);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: widget.padding ?? AppSpacing.buttonPadding,
        transform: _isPressed ? (Matrix4.identity()..scale(0.97)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.enabled ? bgColor : bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.glassBorder, width: 1.0),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color:
                widget.enabled
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                    : AppColors.textTertiary,
            fontWeight: FontWeight.w700,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A glassmorphic icon button
///
/// Note: Class name kept as NeumorphicIconButton for backward compatibility.
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
    final bgColor =
        widget.backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.glassMedium);
    final iconColor =
        widget.iconColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        transform: _isPressed ? (Matrix4.identity()..scale(0.97)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.enabled ? bgColor : bgColor.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder, width: 1.0),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
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

/// A glassmorphic container for inset/pressed appearance
///
/// Note: Class name kept as NeumorphicInset for backward compatibility.
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
    final bgColor =
        color ??
        (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant.withOpacity(0.5));

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              isDark
                  ? AppColors.highlightDark.withOpacity(0.15)
                  : AppColors.accentLight.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

/// A glassmorphic progress indicator with gold fill
///
/// Note: Class name kept as NeumorphicProgress for backward compatibility.
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
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant.withOpacity(0.5));
    final fillColor = progressColor ?? AppColors.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.accentLight.withOpacity(0.15), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [fillColor.withOpacity(0.7), fillColor]),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
