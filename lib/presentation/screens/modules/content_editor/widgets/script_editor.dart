import 'package:flutter/material.dart';

/// Script editor widget with character counting and duration estimation
class ScriptEditor extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool enabled;
  final int estimatedDurationSeconds;

  const ScriptEditor({
    super.key,
    required this.controller,
    this.maxLength = 5000,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.estimatedDurationSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final characterCount = controller.text.length;
    final isOverLimit = characterCount > maxLength;
    final percentUsed = (characterCount / maxLength * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        Row(
          children: [
            Text(
              'Narration Script',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Duration estimate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Est. ${_formatDuration(estimatedDurationSeconds)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Text field
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: 8,
          minLines: 5,
          decoration: InputDecoration(
            hintText: hintText ?? 'Write the narration script for this stop...',
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
            filled: true,
            fillColor: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceContainerHighest,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // Character counter and progress
        Row(
          children: [
            // Character count
            Text(
              '$characterCount / $maxLength characters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverLimit
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
                fontWeight: isOverLimit ? FontWeight.bold : null,
              ),
            ),
            const Spacer(),
            // Word count
            Text(
              '${_getWordCount(controller.text)} words',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentUsed / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              isOverLimit
                  ? theme.colorScheme.error
                  : percentUsed > 80
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
            ),
            minHeight: 4,
          ),
        ),

        // Warning if approaching limit
        if (percentUsed > 80 && !isOverLimit) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 4),
              Text(
                'Approaching character limit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],

        // Error if over limit
        if (isOverLimit) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                'Script exceeds maximum length',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  int _getWordCount(String text) {
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0:00';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

/// Standalone script editor dialog
class ScriptEditorDialog extends StatefulWidget {
  final String initialScript;
  final int maxLength;
  final String? title;

  const ScriptEditorDialog({
    super.key,
    this.initialScript = '',
    this.maxLength = 5000,
    this.title,
  });

  static Future<String?> show(
    BuildContext context, {
    String initialScript = '',
    int maxLength = 5000,
    String? title,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => ScriptEditorDialog(
        initialScript: initialScript,
        maxLength: maxLength,
        title: title,
      ),
    );
  }

  @override
  State<ScriptEditorDialog> createState() => _ScriptEditorDialogState();
}

class _ScriptEditorDialogState extends State<ScriptEditorDialog> {
  late TextEditingController _controller;
  int _estimatedDuration = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialScript);
    _updateEstimate();
    _controller.addListener(_updateEstimate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateEstimate() {
    final wordCount = _controller.text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    setState(() {
      _estimatedDuration = (wordCount / 150 * 60).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? 'Edit Script'),
      content: SizedBox(
        width: 600,
        child: ScriptEditor(
          controller: _controller,
          maxLength: widget.maxLength,
          estimatedDurationSeconds: _estimatedDuration,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _controller.text.length <= widget.maxLength
              ? () => Navigator.pop(context, _controller.text)
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
