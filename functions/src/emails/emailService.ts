import { Resend } from 'resend';
import * as functions from 'firebase-functions';

// Initialize Resend with API key from environment config
const getResend = () => {
  const apiKey = functions.config().resend?.api_key;
  if (!apiKey) {
    functions.logger.warn('Resend API key not configured');
    return null;
  }
  return new Resend(apiKey);
};

// Email configuration
const EMAIL_CONFIG = {
  from: 'At Your Pace <noreply@atyourpace.com>',
  replyTo: 'support@atyourpace.com',
};

const APP_URL = 'https://atyourpace.com';

// Email template styles (inline for email compatibility)
const styles = {
  body: 'margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: #f6f9fc;',
  container: 'max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden;',
  header: 'background-color: #0066FF; padding: 24px; text-align: center;',
  logo: 'color: #ffffff; font-size: 24px; font-weight: bold; margin: 0;',
  content: 'padding: 32px 24px;',
  heading: 'font-size: 24px; color: #1a1a1a; margin: 0 0 16px 0;',
  paragraph: 'font-size: 15px; line-height: 24px; color: #374151; margin: 0 0 16px 0;',
  button: 'display: inline-block; background-color: #0066FF; color: #ffffff; padding: 12px 24px; border-radius: 6px; text-decoration: none; font-weight: 600;',
  footer: 'background-color: #f9fafb; padding: 24px; text-align: center;',
  footerText: 'font-size: 12px; color: #6b7280; margin: 4px 0;',
  link: 'color: #0066FF; text-decoration: none;',
};

interface TourApprovedEmailData {
  creatorName: string;
  creatorEmail: string;
  tourTitle: string;
  tourId: string;
  notes?: string;
}

interface TourRejectedEmailData {
  creatorName: string;
  creatorEmail: string;
  tourTitle: string;
  tourId: string;
  reason: string;
}

interface WelcomeEmailData {
  creatorName: string;
  creatorEmail: string;
}

/**
 * Send tour approved notification email
 */
export async function sendTourApprovedEmail(data: TourApprovedEmailData): Promise<boolean> {
  const resend = getResend();
  if (!resend) {
    functions.logger.warn('Resend not configured, skipping tour approved email');
    return false;
  }

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="${styles.body}">
  <div style="${styles.container}">
    <div style="${styles.header}">
      <p style="${styles.logo}">At Your Pace</p>
    </div>

    <div style="background-color: #22c55e; padding: 32px 24px; text-align: center;">
      <span style="font-size: 48px; color: #ffffff;">&#10003;</span>
      <h1 style="color: #ffffff; font-size: 28px; font-weight: bold; margin: 8px 0 0 0;">Tour Approved!</h1>
    </div>

    <div style="${styles.content}">
      <p style="${styles.paragraph}">Hi ${data.creatorName},</p>

      <p style="${styles.paragraph}">
        Great news! Your tour <strong>"${data.tourTitle}"</strong> has been reviewed and approved.
        It's now live and available for users to discover and enjoy.
      </p>

      ${data.notes ? `
      <div style="background-color: #f0f9ff; border-left: 4px solid #0066FF; padding: 16px; margin-bottom: 24px; border-radius: 0 4px 4px 0;">
        <p style="font-size: 13px; font-weight: 600; color: #0066FF; margin: 0 0 4px 0;">Reviewer Notes:</p>
        <p style="font-size: 14px; color: #374151; margin: 0; font-style: italic;">${data.notes}</p>
      </div>
      ` : ''}

      <p style="${styles.paragraph}">
        Your tour is now visible in the app and can be found by users searching for experiences in your area.
      </p>

      <div style="text-align: center; margin: 24px 0;">
        <a href="${APP_URL}/my-tours" style="${styles.button}">View My Tours</a>
      </div>

      <p style="${styles.paragraph}">
        Thank you for contributing to the At Your Pace community!
      </p>

      <p style="${styles.paragraph}">
        Happy touring,<br>
        The At Your Pace Team
      </p>
    </div>

    <div style="${styles.footer}">
      <p style="${styles.footerText}">
        <a href="${APP_URL}/help" style="${styles.link}">Help Center</a> |
        <a href="${APP_URL}/settings" style="${styles.link}">Notification Settings</a>
      </p>
      <p style="${styles.footerText}">&copy; ${new Date().getFullYear()} At Your Pace. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
  `;

  try {
    const { error } = await resend.emails.send({
      from: EMAIL_CONFIG.from,
      to: data.creatorEmail,
      replyTo: EMAIL_CONFIG.replyTo,
      subject: `Great news! "${data.tourTitle}" has been approved`,
      html,
    });

    if (error) {
      functions.logger.error('Failed to send tour approved email:', error);
      return false;
    }

    functions.logger.info(`Tour approved email sent to ${data.creatorEmail}`);
    return true;
  } catch (err) {
    functions.logger.error('Error sending tour approved email:', err);
    return false;
  }
}

/**
 * Send tour rejected notification email
 */
export async function sendTourRejectedEmail(data: TourRejectedEmailData): Promise<boolean> {
  const resend = getResend();
  if (!resend) {
    functions.logger.warn('Resend not configured, skipping tour rejected email');
    return false;
  }

  // Escape HTML in the reason to prevent XSS
  const escapedReason = data.reason
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>');

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="${styles.body}">
  <div style="${styles.container}">
    <div style="${styles.header}">
      <p style="${styles.logo}">At Your Pace</p>
    </div>

    <div style="background-color: #f59e0b; padding: 32px 24px; text-align: center;">
      <span style="font-size: 48px; color: #ffffff; font-weight: bold; width: 48px; height: 48px; border-radius: 50%; border: 3px solid #ffffff; display: inline-block; line-height: 42px;">!</span>
      <h1 style="color: #ffffff; font-size: 28px; font-weight: bold; margin: 8px 0 0 0;">Changes Requested</h1>
    </div>

    <div style="${styles.content}">
      <p style="${styles.paragraph}">Hi ${data.creatorName},</p>

      <p style="${styles.paragraph}">
        Thank you for submitting <strong>"${data.tourTitle}"</strong> for review.
        After careful consideration, our team has determined that some changes are needed before your tour can be published.
      </p>

      <div style="background-color: #fef3c7; border-left: 4px solid #f59e0b; padding: 16px; margin-bottom: 24px; border-radius: 0 4px 4px 0;">
        <p style="font-size: 13px; font-weight: 600; color: #92400e; margin: 0 0 8px 0;">Feedback from our review team:</p>
        <p style="font-size: 14px; color: #374151; margin: 0;">${escapedReason}</p>
      </div>

      <p style="${styles.paragraph}">
        <strong>Don't worry!</strong> You can make the necessary changes and resubmit your tour for review.
      </p>

      <div style="text-align: center; margin: 24px 0;">
        <a href="${APP_URL}/tour/${data.tourId}/edit" style="${styles.button}">Edit My Tour</a>
      </div>

      <p style="font-size: 14px; line-height: 22px; color: #374151; margin-bottom: 12px;">
        <strong>Need help?</strong> If you have questions about the feedback or need clarification,
        please don't hesitate to reach out to our support team at
        <a href="mailto:support@atyourpace.com" style="${styles.link}">support@atyourpace.com</a>.
      </p>

      <p style="${styles.paragraph}">
        We appreciate your effort and look forward to seeing your updated tour!<br><br>
        Best regards,<br>
        The At Your Pace Team
      </p>
    </div>

    <div style="${styles.footer}">
      <p style="${styles.footerText}">
        <a href="${APP_URL}/help" style="${styles.link}">Help Center</a> |
        <a href="${APP_URL}/settings" style="${styles.link}">Notification Settings</a>
      </p>
      <p style="${styles.footerText}">&copy; ${new Date().getFullYear()} At Your Pace. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
  `;

  try {
    const { error } = await resend.emails.send({
      from: EMAIL_CONFIG.from,
      to: data.creatorEmail,
      replyTo: EMAIL_CONFIG.replyTo,
      subject: `Changes requested for "${data.tourTitle}"`,
      html,
    });

    if (error) {
      functions.logger.error('Failed to send tour rejected email:', error);
      return false;
    }

    functions.logger.info(`Tour rejected email sent to ${data.creatorEmail}`);
    return true;
  } catch (err) {
    functions.logger.error('Error sending tour rejected email:', err);
    return false;
  }
}

/**
 * Send welcome email to new creator
 */
export async function sendWelcomeEmail(data: WelcomeEmailData): Promise<boolean> {
  const resend = getResend();
  if (!resend) {
    functions.logger.warn('Resend not configured, skipping welcome email');
    return false;
  }

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="${styles.body}">
  <div style="${styles.container}">
    <div style="${styles.header}">
      <p style="${styles.logo}">At Your Pace</p>
    </div>

    <div style="background: linear-gradient(135deg, #0066FF 0%, #3b82f6 100%); padding: 48px 24px; text-align: center;">
      <span style="font-size: 48px; margin-bottom: 12px; display: block;">&#128075;</span>
      <h1 style="color: #ffffff; font-size: 32px; font-weight: bold; margin: 0 0 8px 0;">Welcome to At Your Pace!</h1>
      <p style="color: rgba(255,255,255,0.9); font-size: 18px; margin: 0;">You're now a tour creator</p>
    </div>

    <div style="${styles.content}">
      <p style="${styles.paragraph}">Hi ${data.creatorName},</p>

      <p style="${styles.paragraph}">
        We're thrilled to have you join our community of tour creators! Whether you're sharing
        the hidden gems of your hometown or guiding visitors through historic landmarks,
        you're about to help people experience the world at their own pace.
      </p>

      <div style="text-align: center; margin: 24px 0;">
        <a href="${APP_URL}/tour/new" style="${styles.button}">Create Your First Tour</a>
      </div>

      <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;">

      <h2 style="font-size: 18px; font-weight: 600; color: #1f2937; margin-bottom: 16px;">Getting Started</h2>

      <ol style="padding-left: 20px; margin-bottom: 24px;">
        <li style="font-size: 14px; line-height: 28px; color: #374151;"><strong>Plan Your Tour</strong> - Think about the story you want to tell</li>
        <li style="font-size: 14px; line-height: 28px; color: #374151;"><strong>Add Your Stops</strong> - Use our interactive map to place tour stops</li>
        <li style="font-size: 14px; line-height: 28px; color: #374151;"><strong>Record Audio</strong> - Record narration or use AI voice generation</li>
        <li style="font-size: 14px; line-height: 28px; color: #374151;"><strong>Add Photos</strong> - Upload images for visual preview</li>
        <li style="font-size: 14px; line-height: 28px; color: #374151;"><strong>Submit for Review</strong> - Our team will review and publish quickly</li>
      </ol>

      <p style="${styles.paragraph}">
        We can't wait to see what you create!<br><br>
        Happy touring,<br>
        The At Your Pace Team
      </p>
    </div>

    <div style="${styles.footer}">
      <p style="${styles.footerText}">
        <a href="${APP_URL}/help" style="${styles.link}">Help Center</a> |
        <a href="${APP_URL}/settings" style="${styles.link}">Notification Settings</a>
      </p>
      <p style="${styles.footerText}">&copy; ${new Date().getFullYear()} At Your Pace. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
  `;

  try {
    const { error } = await resend.emails.send({
      from: EMAIL_CONFIG.from,
      to: data.creatorEmail,
      replyTo: EMAIL_CONFIG.replyTo,
      subject: 'Welcome to At Your Pace - Start creating amazing tours!',
      html,
    });

    if (error) {
      functions.logger.error('Failed to send welcome email:', error);
      return false;
    }

    functions.logger.info(`Welcome email sent to ${data.creatorEmail}`);
    return true;
  } catch (err) {
    functions.logger.error('Error sending welcome email:', err);
    return false;
  }
}
