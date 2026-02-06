import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../../core/extensions/context_extensions.dart';

/// A full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? barrierColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: barrierColor ?? AppColors.textPrimary.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message!, style: context.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A button with built-in loading state
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool filled;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.style,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final button =
        filled
            ? FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: _buildChild(),
            )
            : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: _buildChild(),
            );

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return child;
  }
}

/// A simple loading indicator with optional text
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool centered;
  final double size;

  const LoadingIndicator({super.key, this.message, this.centered = true, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: size, height: size, child: const CircularProgressIndicator()),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (centered) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: indicator));
    }

    return indicator;
  }
}

/// A pull-to-refresh wrapper
class RefreshableList extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final ScrollController? controller;

  const RefreshableList({super.key, required this.onRefresh, required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}

/// An async value widget that handles loading, error, and data states
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, VoidCallback retry)? error;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.snapshot,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return loading?.call() ?? const LoadingIndicator();
    }

    if (snapshot.hasError) {
      return error?.call(snapshot.error!, onRetry ?? () {}) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
                const SizedBox(height: 16),
                Text('Something went wrong', style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          );
    }

    if (snapshot.hasData) {
      return data(snapshot.data as T);
    }

    return loading?.call() ?? const LoadingIndicator();
  }
}
