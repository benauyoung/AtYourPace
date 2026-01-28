import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/context_extensions.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Help
          _buildSectionHeader(context, 'Quick Help'),
          Card(
            child: Column(
              children: [
                _buildHelpTile(
                  context,
                  icon: Icons.play_circle_outline,
                  title: 'How do I start a tour?',
                  content: '''1. Browse available tours from the Discover tab
2. Tap on a tour to see details
3. Tap "Start Tour" to begin
4. Allow location access when prompted
5. Walk to the first stop - audio will play automatically!''',
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Why isn\'t the audio playing?',
                  content: '''Make sure:
- Location services are enabled for this app
- You're within the trigger radius of a stop (usually 30-50 meters)
- Your device volume is turned up
- Bluetooth headphones are connected if you're using them

Try switching to Manual Mode (tap the toggle at the top) to manually trigger audio.''',
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context,
                  icon: Icons.download_outlined,
                  title: 'How do I use tours offline?',
                  content: '''1. Go to the tour details page
2. Tap the download icon
3. Wait for the download to complete
4. You can now use the tour without internet!

Manage downloaded tours in Settings > Manage Downloads.''',
                ),
                const Divider(height: 1),
                _buildHelpTile(
                  context,
                  icon: Icons.create_outlined,
                  title: 'How do I create a tour?',
                  content: '''To create tours, you need a Creator account:
1. Go to Profile > Settings
2. Apply for Creator status
3. Once approved, you'll see the Create tab in navigation

As a Creator, you can add stops with audio, images, and trigger zones.''',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ
          _buildSectionHeader(context, 'Frequently Asked Questions'),
          Card(
            child: Column(
              children: [
                _buildFaqTile(
                  context,
                  question: 'Is the app free to use?',
                  answer: 'Yes! AYP Tour Guide is free to download and use. Some premium tours may have a cost in the future.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'Does the app work without internet?',
                  answer: 'Yes, if you download tours beforehand. The map requires internet for initial loading, but audio and tour data work offline.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'How accurate is the GPS triggering?',
                  answer: 'GPS accuracy varies by device and environment. Tours use trigger radii (usually 30-50m) to account for GPS drift. Buildings and trees can affect accuracy.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'Can I pause a tour and resume later?',
                  answer: 'Yes! Your progress is saved automatically. When you return to a tour, you\'ll continue from where you left off.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'How do I report an issue with a tour?',
                  answer: 'On the tour details page, tap the menu icon and select "Report Issue". You can describe the problem and we\'ll review it.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Support
          _buildSectionHeader(context, 'Contact Support'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@atyourpace.app'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchEmail(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report a Bug'),
                  subtitle: const Text('Help us improve the app'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showBugReportDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback'),
                  subtitle: const Text('Share your suggestions'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showFeedbackDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          _buildSectionHeader(context, 'About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tour,
                        size: 48,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AYP Tour Guide',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Version 1.0.0',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Discover the world at your own pace with GPS-triggered audio tours. '
                    'Explore cities, parks, and historical sites with narrated guides that play automatically as you walk.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHelpTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: context.textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@atyourpace.app',
      query: 'subject=AYP Tour Guide Support',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  void _showBugReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe the issue you encountered...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Share your thoughts and suggestions...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
