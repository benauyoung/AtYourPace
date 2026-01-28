import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

enum LegalDocumentType {
  termsOfService,
  privacyPolicy,
}

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentType documentType;

  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });

  @override
  Widget build(BuildContext context) {
    final title = documentType == LegalDocumentType.termsOfService
        ? 'Terms of Service'
        : 'Privacy Policy';

    final content = documentType == LegalDocumentType.termsOfService
        ? _termsOfServiceContent
        : _privacyPolicyContent;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: January 2026',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ...content.map((section) => _buildSection(context, section)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, _LegalSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.content,
            style: context.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection {
  final String title;
  final String content;

  const _LegalSection({required this.title, required this.content});
}

const _termsOfServiceContent = [
  _LegalSection(
    title: '1. Acceptance of Terms',
    content: '''By downloading, installing, or using the AYP Tour Guide application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, please do not use the App.''',
  ),
  _LegalSection(
    title: '2. Description of Service',
    content: '''AYP Tour Guide provides GPS-triggered audio tours that allow users to explore locations with narrated content. The App includes features for discovering tours, playing audio at specific locations, and tracking tour progress.''',
  ),
  _LegalSection(
    title: '3. User Accounts',
    content: '''You may be required to create an account to access certain features. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to provide accurate and complete information when creating your account.''',
  ),
  _LegalSection(
    title: '4. User Content',
    content: '''Users who create tours ("Creators") grant AYP a non-exclusive, worldwide, royalty-free license to use, display, and distribute their content through the App. Creators are solely responsible for their content and must ensure they have the rights to use any audio, images, or text included in their tours.''',
  ),
  _LegalSection(
    title: '5. Acceptable Use',
    content: '''You agree not to:
- Use the App for any unlawful purpose
- Upload content that is offensive, harmful, or infringes on others' rights
- Attempt to interfere with the App's operation
- Create multiple accounts to abuse the platform
- Misuse the rating and review system''',
  ),
  _LegalSection(
    title: '6. Location Services',
    content: '''The App uses your device's location to trigger audio at specific points during tours. By using the App, you consent to the collection and use of location data as described in our Privacy Policy. You can disable location services, but some features may not function properly.''',
  ),
  _LegalSection(
    title: '7. Intellectual Property',
    content: '''The App and its original content (excluding user-generated content) are owned by AYP and are protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, or distribute any part of the App without our prior written consent.''',
  ),
  _LegalSection(
    title: '8. Disclaimer of Warranties',
    content: '''The App is provided "as is" without warranties of any kind. We do not guarantee the accuracy of tour content or that the App will be error-free. Use the App at your own risk and always be aware of your surroundings when following tour directions.''',
  ),
  _LegalSection(
    title: '9. Limitation of Liability',
    content: '''AYP shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App. This includes but is not limited to personal injury, property damage, or lost data.''',
  ),
  _LegalSection(
    title: '10. Changes to Terms',
    content: '''We may modify these Terms at any time. Continued use of the App after changes constitutes acceptance of the modified Terms. We will notify users of significant changes through the App or via email.''',
  ),
  _LegalSection(
    title: '11. Contact',
    content: '''For questions about these Terms, please contact us at support@atyourpace.app''',
  ),
];

const _privacyPolicyContent = [
  _LegalSection(
    title: '1. Information We Collect',
    content: '''We collect the following types of information:

- Account Information: Email address, display name, and profile photo
- Location Data: GPS coordinates during active tour playback
- Usage Data: Tours viewed, completed, and rated
- Device Information: Device type, operating system, and app version
- Content: Reviews, ratings, and any content you create as a tour creator''',
  ),
  _LegalSection(
    title: '2. How We Use Your Information',
    content: '''We use your information to:

- Provide and improve the App's functionality
- Trigger audio at appropriate tour locations
- Track your progress through tours
- Display personalized tour recommendations
- Enable creator analytics
- Communicate important updates and notifications
- Ensure platform safety and prevent abuse''',
  ),
  _LegalSection(
    title: '3. Location Data',
    content: '''Location data is only collected when the App is actively in use during tour playback. We do not track your location when the App is closed. Location data is used to:

- Trigger audio at specific tour stops
- Calculate distance to upcoming stops
- Provide navigation assistance
- Improve geofence accuracy''',
  ),
  _LegalSection(
    title: '4. Data Sharing',
    content: '''We do not sell your personal information. We may share data with:

- Service providers (cloud hosting, analytics) under strict confidentiality agreements
- Other users (only your public profile and reviews)
- Law enforcement when required by law
- In connection with a merger or acquisition''',
  ),
  _LegalSection(
    title: '5. Data Retention',
    content: '''We retain your data for as long as your account is active. You can request deletion of your account and associated data at any time. Some data may be retained for legal or legitimate business purposes.''',
  ),
  _LegalSection(
    title: '6. Data Security',
    content: '''We implement industry-standard security measures to protect your data, including encryption in transit and at rest, secure authentication, and regular security audits. However, no method of transmission over the internet is 100% secure.''',
  ),
  _LegalSection(
    title: '7. Your Rights',
    content: '''You have the right to:

- Access your personal data
- Correct inaccurate data
- Delete your account and data
- Export your data
- Opt out of marketing communications
- Withdraw consent for location tracking''',
  ),
  _LegalSection(
    title: '8. Children\'s Privacy',
    content: '''The App is not intended for children under 13. We do not knowingly collect personal information from children. If you believe we have collected such information, please contact us immediately.''',
  ),
  _LegalSection(
    title: '9. Changes to Privacy Policy',
    content: '''We may update this Privacy Policy periodically. We will notify you of material changes through the App or via email. Your continued use after changes indicates acceptance.''',
  ),
  _LegalSection(
    title: '10. Contact',
    content: '''For privacy-related questions or to exercise your rights, contact us at privacy@atyourpace.app''',
  ),
];
