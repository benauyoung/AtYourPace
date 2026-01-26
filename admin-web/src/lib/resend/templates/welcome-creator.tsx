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

interface WelcomeCreatorEmailProps {
  creatorName: string;
}

const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://atyourpace.com';

export const WelcomeCreatorEmail: React.FC<WelcomeCreatorEmailProps> = ({
  creatorName = 'Creator',
}) => {
  const previewText = 'Welcome to At Your Pace - Start creating amazing tours!';

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

          {/* Welcome Banner */}
          <Section style={welcomeBanner}>
            <Text style={waveEmoji}>&#128075;</Text>
            <Heading style={bannerHeading}>Welcome to At Your Pace!</Heading>
            <Text style={bannerSubtext}>You&apos;re now a tour creator</Text>
          </Section>

          {/* Main Content */}
          <Section style={content}>
            <Text style={greeting}>Hi {creatorName},</Text>

            <Text style={paragraph}>
              We&apos;re thrilled to have you join our community of tour creators! Whether
              you&apos;re sharing the hidden gems of your hometown or guiding visitors
              through historic landmarks, you&apos;re about to help people experience
              the world at their own pace.
            </Text>

            <Section style={buttonSection}>
              <Button
                style={primaryButton}
                href={`${baseUrl}/tour/new`}
              >
                Create Your First Tour
              </Button>
            </Section>

            <Hr style={hr} />

            <Text style={sectionHeading}>Getting Started</Text>

            <Section style={stepCard}>
              <Text style={stepNumber}>1</Text>
              <div>
                <Text style={stepTitle}>Plan Your Tour</Text>
                <Text style={stepDescription}>
                  Think about the story you want to tell. What makes your tour unique?
                  What will visitors discover?
                </Text>
              </div>
            </Section>

            <Section style={stepCard}>
              <Text style={stepNumber}>2</Text>
              <div>
                <Text style={stepTitle}>Add Your Stops</Text>
                <Text style={stepDescription}>
                  Use our interactive map to place your tour stops. Drag and drop
                  to arrange them in the perfect order.
                </Text>
              </div>
            </Section>

            <Section style={stepCard}>
              <Text style={stepNumber}>3</Text>
              <div>
                <Text style={stepTitle}>Record Audio</Text>
                <Text style={stepDescription}>
                  Record narration directly in your browser, upload audio files,
                  or use our AI voice generator to bring your tour to life.
                </Text>
              </div>
            </Section>

            <Section style={stepCard}>
              <Text style={stepNumber}>4</Text>
              <div>
                <Text style={stepTitle}>Add Photos</Text>
                <Text style={stepDescription}>
                  Upload images for each stop to give visitors a visual preview
                  of what they&apos;ll experience.
                </Text>
              </div>
            </Section>

            <Section style={stepCard}>
              <Text style={stepNumber}>5</Text>
              <div>
                <Text style={stepTitle}>Submit for Review</Text>
                <Text style={stepDescription}>
                  Preview your tour and submit it for review. Our team will check
                  it and get it published quickly.
                </Text>
              </div>
            </Section>

            <Hr style={hr} />

            <Text style={sectionHeading}>Creator Tips</Text>

            <ul style={tipsList}>
              <li style={tipItem}>
                <strong>Quality audio matters:</strong> Find a quiet space when recording.
                Clear narration makes all the difference.
              </li>
              <li style={tipItem}>
                <strong>Tell a story:</strong> Don&apos;t just list facts. Share personal
                anecdotes and local insights that guidebooks miss.
              </li>
              <li style={tipItem}>
                <strong>Test your route:</strong> Walk through your tour to ensure the
                timing and distances feel right.
              </li>
              <li style={tipItem}>
                <strong>Keep stops focused:</strong> Aim for 2-5 minutes of audio per
                stop. Short and engaging beats long and exhaustive.
              </li>
            </ul>

            <Hr style={hr} />

            <Section style={resourcesSection}>
              <Text style={sectionHeading}>Helpful Resources</Text>
              <Text style={resourceLink}>
                <Link href={`${baseUrl}/help/creator-guide`} style={link}>
                  Creator Guide
                </Link>
                {' - Complete walkthrough of all features'}
              </Text>
              <Text style={resourceLink}>
                <Link href={`${baseUrl}/help/audio-tips`} style={link}>
                  Audio Recording Tips
                </Link>
                {' - Get professional-quality narration'}
              </Text>
              <Text style={resourceLink}>
                <Link href={`${baseUrl}/help/faq`} style={link}>
                  FAQs
                </Link>
                {' - Answers to common questions'}
              </Text>
            </Section>

            <Text style={signoff}>
              We can&apos;t wait to see what you create!
              <br />
              <br />
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

export default WelcomeCreatorEmail;

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

const welcomeBanner = {
  background: 'linear-gradient(135deg, #0066FF 0%, #3b82f6 100%)',
  padding: '48px 24px',
  textAlign: 'center' as const,
};

const waveEmoji = {
  fontSize: '48px',
  margin: '0 0 12px 0',
};

const bannerHeading = {
  color: '#ffffff',
  fontSize: '32px',
  fontWeight: 'bold' as const,
  margin: '0 0 8px 0',
};

const bannerSubtext = {
  color: 'rgba(255,255,255,0.9)',
  fontSize: '18px',
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

const buttonSection = {
  textAlign: 'center' as const,
  marginTop: '24px',
  marginBottom: '24px',
};

const primaryButton = {
  backgroundColor: '#0066FF',
  borderRadius: '6px',
  color: '#ffffff',
  fontSize: '16px',
  fontWeight: '600' as const,
  textDecoration: 'none',
  textAlign: 'center' as const,
  padding: '14px 32px',
  display: 'inline-block' as const,
};

const hr = {
  borderColor: '#e5e7eb',
  margin: '24px 0',
};

const sectionHeading = {
  fontSize: '18px',
  fontWeight: '600' as const,
  color: '#1f2937',
  marginBottom: '16px',
};

const stepCard = {
  display: 'flex' as const,
  marginBottom: '16px',
  padding: '16px',
  backgroundColor: '#f9fafb',
  borderRadius: '8px',
};

const stepNumber = {
  width: '32px',
  height: '32px',
  backgroundColor: '#0066FF',
  color: '#ffffff',
  borderRadius: '50%',
  textAlign: 'center' as const,
  lineHeight: '32px',
  fontSize: '14px',
  fontWeight: 'bold' as const,
  marginRight: '16px',
  flexShrink: 0,
};

const stepTitle = {
  fontSize: '15px',
  fontWeight: '600' as const,
  color: '#1f2937',
  margin: '0 0 4px 0',
};

const stepDescription = {
  fontSize: '14px',
  lineHeight: '20px',
  color: '#6b7280',
  margin: '0',
};

const tipsList = {
  paddingLeft: '0',
  listStyle: 'none' as const,
};

const tipItem = {
  fontSize: '14px',
  lineHeight: '22px',
  color: '#374151',
  marginBottom: '12px',
  paddingLeft: '24px',
  position: 'relative' as const,
};

const resourcesSection = {
  backgroundColor: '#f0f9ff',
  padding: '20px',
  borderRadius: '8px',
  marginBottom: '24px',
};

const resourceLink = {
  fontSize: '14px',
  lineHeight: '24px',
  color: '#374151',
  margin: '0 0 8px 0',
};

const link = {
  color: '#0066FF',
  fontWeight: '500' as const,
  textDecoration: 'none',
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
