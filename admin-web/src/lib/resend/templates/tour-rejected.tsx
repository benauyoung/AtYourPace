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

interface StopComment {
  stopName: string;
  comments: string[];
}

interface TourRejectedEmailProps {
  creatorName: string;
  tourTitle: string;
  tourId: string;
  reason: string;
  stopComments?: StopComment[];
}

const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://atyourpace.com';

export const TourRejectedEmail: React.FC<TourRejectedEmailProps> = ({
  creatorName = 'Creator',
  tourTitle = 'Your Tour',
  tourId = '',
  reason = 'Your tour needs some changes before it can be approved.',
  stopComments = [],
}) => {
  const previewText = `Changes requested for "${tourTitle}"`;
  const hasStopComments = stopComments && stopComments.length > 0;

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

          {/* Status Banner */}
          <Section style={warningBanner}>
            <Text style={warningIcon}>!</Text>
            <Heading style={bannerHeading}>Changes Requested</Heading>
          </Section>

          {/* Main Content */}
          <Section style={content}>
            <Text style={greeting}>Hi {creatorName},</Text>

            <Text style={paragraph}>
              Thank you for submitting <strong>&quot;{tourTitle}&quot;</strong> for review.
              After careful consideration, our team has determined that some changes
              are needed before your tour can be published.
            </Text>

            {/* Rejection Reason */}
            <Section style={reasonSection}>
              <Text style={reasonLabel}>Feedback from our review team:</Text>
              <Text style={reasonText}>{reason}</Text>
            </Section>

            {/* Stop Comments */}
            {hasStopComments && (
              <Section style={commentsSection}>
                <Text style={commentsHeading}>Stop-specific feedback:</Text>
                {stopComments.map((stop, index) => (
                  <Section key={index} style={stopSection}>
                    <Text style={stopName}>{stop.stopName}</Text>
                    <ul style={commentsList}>
                      {stop.comments.map((comment, commentIndex) => (
                        <li key={commentIndex} style={commentItem}>
                          {comment}
                        </li>
                      ))}
                    </ul>
                  </Section>
                ))}
              </Section>
            )}

            <Text style={paragraph}>
              <strong>Don&apos;t worry!</strong> You can make the necessary changes and
              resubmit your tour for review. Here&apos;s how:
            </Text>

            <ol style={stepsList}>
              <li style={stepItem}>Go to your tour editor</li>
              <li style={stepItem}>Make the requested changes</li>
              <li style={stepItem}>Review all your content one more time</li>
              <li style={stepItem}>Click &quot;Submit for Review&quot; when ready</li>
            </ol>

            <Section style={buttonSection}>
              <Button
                style={primaryButton}
                href={`${baseUrl}/tour/${tourId}/edit`}
              >
                Edit My Tour
              </Button>
            </Section>

            <Hr style={hr} />

            <Text style={helpText}>
              <strong>Need help?</strong> If you have questions about the feedback
              or need clarification, please don&apos;t hesitate to reach out to our
              support team.
            </Text>

            <Section style={supportSection}>
              <Link href="mailto:support@atyourpace.com" style={supportLink}>
                Contact Support
              </Link>
            </Section>

            <Text style={signoff}>
              We appreciate your effort and look forward to seeing your updated tour!
              <br />
              <br />
              Best regards,
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

export default TourRejectedEmail;

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

const warningBanner = {
  backgroundColor: '#f59e0b',
  padding: '32px 24px',
  textAlign: 'center' as const,
};

const warningIcon = {
  fontSize: '48px',
  color: '#ffffff',
  fontWeight: 'bold' as const,
  margin: '0 0 8px 0',
  width: '48px',
  height: '48px',
  borderRadius: '50%',
  border: '3px solid #ffffff',
  display: 'inline-block' as const,
  lineHeight: '42px',
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

const reasonSection = {
  backgroundColor: '#fef3c7',
  borderLeft: '4px solid #f59e0b',
  padding: '16px',
  marginBottom: '24px',
  borderRadius: '0 4px 4px 0',
};

const reasonLabel = {
  fontSize: '13px',
  fontWeight: '600' as const,
  color: '#92400e',
  marginBottom: '8px',
};

const reasonText = {
  fontSize: '14px',
  color: '#374151',
  margin: '0',
  whiteSpace: 'pre-wrap' as const,
};

const commentsSection = {
  backgroundColor: '#f9fafb',
  borderRadius: '8px',
  padding: '16px',
  marginBottom: '24px',
};

const commentsHeading = {
  fontSize: '14px',
  fontWeight: '600' as const,
  color: '#1f2937',
  marginBottom: '12px',
};

const stopSection = {
  marginBottom: '16px',
};

const stopName = {
  fontSize: '13px',
  fontWeight: '600' as const,
  color: '#0066FF',
  backgroundColor: '#eff6ff',
  display: 'inline-block' as const,
  padding: '4px 8px',
  borderRadius: '4px',
  marginBottom: '8px',
};

const commentsList = {
  margin: '0',
  paddingLeft: '20px',
};

const commentItem = {
  fontSize: '13px',
  lineHeight: '20px',
  color: '#4b5563',
  marginBottom: '4px',
};

const stepsList = {
  paddingLeft: '20px',
  marginBottom: '24px',
};

const stepItem = {
  fontSize: '14px',
  lineHeight: '28px',
  color: '#374151',
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
  padding: '12px 32px',
  display: 'inline-block' as const,
};

const hr = {
  borderColor: '#e5e7eb',
  margin: '24px 0',
};

const helpText = {
  fontSize: '14px',
  lineHeight: '22px',
  color: '#374151',
  marginBottom: '12px',
};

const supportSection = {
  textAlign: 'center' as const,
  marginBottom: '24px',
};

const supportLink = {
  color: '#0066FF',
  fontSize: '14px',
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
