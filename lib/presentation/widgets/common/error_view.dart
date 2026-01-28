import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// A reusable error view with retry functionality
class ErrorView extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool compact;

  const ErrorView({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.compact = false,
  });

  /// Create an error view for network errors
  factory ErrorView.network({
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return ErrorView(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// Create an error view for server errors
  factory ErrorView.server({
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return ErrorView(
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// Create an error view for permission errors
  factory ErrorView.permission({
    required String permission,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return ErrorView(
      title: 'Permission Required',
      message: 'Please grant $permission permission to use this feature.',
      icon: Icons.lock_outline,
      onRetry: onRetry,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Card(
      color: context.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: context.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: context.colorScheme.onErrorContainer),
              ),
            ),
            if (onRetry != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRetry,
                color: context.colorScheme.error,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: context.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A widget that catches errors and displays an error view
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack, VoidCallback retry)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace, _retry);
      }
      return ErrorView(
        message: _error.toString(),
        onRetry: _retry,
      );
    }

    return widget.child;
  }
}
