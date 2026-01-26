import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Hr,
  Html,
  Link,
  Preview,
  Section,
  Text,
} from '@react-email/components';
import * as React from 'react';

interface TourApprovedEmailProps {
  creatorName: string;
  tourTitle: string;
  tourId: string;
  notes?: string;
}

const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://atyourpace.com';

export const TourApprovedEmail: React.FC<TourApprovedEmailProps> = ({
  creatorName = 'Creator',
  tourTitle = 'Your Tour',
  tourId = '',
  notes,
}) => {
  const previewText = `Great news! "${tourTitle}" has been approved`;
  const tourLink = tourId ? `${baseUrl}/tour/${tourId}/preview` : `${baseUrl}/my-tours`;

  return (
    <Html>
      <Head />
      <Preview>{previewText}</Preview>
      <Body style={main}>
        <Container style={container}>
          {/* Logo/Header */}
          <Section style={logoSection}>
            <Text style={logo}>At Your Pace</Text>
          </Section>

          {/* Success Banner */}
          <Section style={successBanner}>
            <Text style={checkmark}>&#10003;</Text>
            <Heading style={bannerHeading}>Tour Approved!</Heading>
          </Section>

          {/* Main Content */}
          <Section style={content}>
            <Text style={greeting}>Hi {creatorName},</Text>

            <Text style={paragraph}>
              Great news! Your tour <strong>&quot;{tourTitle}&quot;</strong> has been
              reviewed and approved. It&apos;s now live and available for users to discover
              and enjoy.
            </Text>

            {notes && (
              <Section style={notesSection}>
                <Text style={notesLabel}>Reviewer Notes:</Text>
                <Text style={notesText}>{notes}</Text>
              </Section>
            )}

            <Text style={paragraph}>
              Your tour is now visible in the app and can be found by users searching
              for experiences in your area. You can view your tour&apos;s performance
              and analytics in your creator dashboard.
            </Text>

            <Section style={buttonSection}>
              <Button
                style={primaryButton}
                href={tourLink}
              >
                View My Tour
              </Button>
              <Button
                style={secondaryButton}
                href={`${baseUrl}/analytics`}
              >
                View Analytics
              </Button>
            </Section>

            <Hr style={hr} />

            <Text style={paragraph}>
              <strong>What&apos;s next?</strong>
            </Text>
            <ul style={list}>
              <li style={listItem}>Share your tour with friends and on social media</li>
              <li style={listItem}>Monitor your tour&apos;s performance in the analytics dashboard</li>
              <li style={listItem}>Consider creating more tours to build your portfolio</li>
              <li style={listItem}>Respond to user reviews to build your reputation</li>
            </ul>

            <Text style={paragraph}>
              Thank you for contributing to the At Your Pace community. We can&apos;t
              wait to see what you create next!
            </Text>

            <Text style={signoff}>
              Happy touring,
              <br />
              The At Your Pace Team
            </Text>
          </Section>

          {/* Footer */}
          <Section style={footer}>
            <Text style={footerText}>
              <Link href={`${baseUrl}/help`} style={footerLink}>
                Help Center
              </Link>
              {' | '}
              <Link href={`${baseUrl}/settings`} style={footerLink}>
                Notification Settings
              </Link>
            </Text>
            <Text style={footerText}>
              &copy; {new Date().getFullYear()} At Your Pace. All rights reserved.
            </Text>
          </Section>
        </Container>
      </Body>
    </Html>
  );
};

export default TourApprovedEmail;

// Styles
const main = {
  backgroundColor: '#f6f9fc',
  fontFamily:
    '-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Ubuntu,sans-serif',
};

const container = {
  backgroundColor: '#ffffff',
  margin: '0 auto',
  marginBottom: '64px',
  borderRadius: '8px',
  overflow: 'hidden' as const,
  maxWidth: '600px',
};

const logoSection = {
  backgroundColor: '#0066FF',
  padding: '24px',
  textAlign: 'center' as const,
};

const logo = {
  color: '#ffffff',
  fontSize: '24px',
  fontWeight: 'bold' as const,
  margin: '0',
};

const successBanner = {
  backgroundColor: '#22c55e',
  padding: '32px 24px',
  textAlign: 'center' as const,
};

const checkmark = {
  fontSize: '48px',
  color: '#ffffff',
  margin: '0 0 8px 0',
};

const bannerHeading = {
  color: '#ffffff',
  fontSize: '28px',
  fontWeight: 'bold' as const,
  margin: '0',
};

const content = {
  padding: '32px 24px',
};

const greeting = {
  fontSize: '18px',
  fontWeight: '600' as const,
  color: '#1a1a1a',
  marginBottom: '16px',
};

const paragraph = {
  fontSize: '15px',
  lineHeight: '24px',
  color: '#374151',
  marginBottom: '16px',
};

const notesSection = {
  backgroundColor: '#f0f9ff',
  borderLeft: '4px solid #0066FF',
  padding: '16px',
  marginBottom: '24px',
  borderRadius: '0 4px 4px 0',
};

const notesLabel = {
  fontSize: '13px',
  fontWeight: '600' as const,
  color: '#0066FF',
  marginBottom: '4px',
};

const notesText = {
  fontSize: '14px',
  color: '#374151',
  margin: '0',
  fontStyle: 'italic' as const,
};

const buttonSection = {
  textAlign: 'center' as const,
  marginTop: '24px',
  marginBottom: '24px',
};

const primaryButton = {
  backgroundColor: '#0066FF',
  borderRadius: '6px',
  color: '#ffffff',
  fontSize: '15px',
  fontWeight: '600' as const,
  textDecoration: 'none',
  textAlign: 'center' as const,
  padding: '12px 24px',
  marginRight: '12px',
  display: 'inline-block' as const,
};

const secondaryButton = {
  backgroundColor: '#ffffff',
  border: '1px solid #0066FF',
  borderRadius: '6px',
  color: '#0066FF',
  fontSize: '15px',
  fontWeight: '600' as const,
  textDecoration: 'none',
  textAlign: 'center' as const,
  padding: '12px 24px',
  display: 'inline-block' as const,
};

const hr = {
  borderColor: '#e5e7eb',
  margin: '24px 0',
};

const list = {
  paddingLeft: '20px',
  marginBottom: '16px',
};

const listItem = {
  fontSize: '14px',
  lineHeight: '24px',
  color: '#374151',
  marginBottom: '8px',
};

const signoff = {
  fontSize: '15px',
  lineHeight: '24px',
  color: '#374151',
  marginTop: '24px',
};

const footer = {
  backgroundColor: '#f9fafb',
  padding: '24px',
  textAlign: 'center' as const,
};

const footerText = {
  fontSize: '12px',
  color: '#6b7280',
  margin: '4px 0',
};

const footerLink = {
  color: '#0066FF',
  textDecoration: 'none',
};
