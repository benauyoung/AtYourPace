import { resend, EMAIL_CONFIG, isEmailEnabled } from './client';
import {
  TourApprovedEmailData,
  TourRejectedEmailData,
  WelcomeEmailData,
} from './client';
import { TourApprovedEmail } from './templates/tour-approved';
import { TourRejectedEmail } from './templates/tour-rejected';
import { WelcomeCreatorEmail } from './templates/welcome-creator';

// Result type for email operations
interface SendEmailResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

/**
 * Send tour approved notification email
 */
export async function sendTourApprovedEmail(
  data: TourApprovedEmailData
): Promise<SendEmailResult> {
  if (!isEmailEnabled() || !resend) {
    console.warn('Email is not enabled. Skipping tour approved email.');
    return { success: false, error: 'Email service not configured' };
  }

  try {
    const { data: result, error } = await resend.emails.send({
      from: `${EMAIL_CONFIG.from.name} <${EMAIL_CONFIG.from.email}>`,
      to: data.creatorEmail,
      replyTo: EMAIL_CONFIG.replyTo,
      subject: `Great news! "${data.tourTitle}" has been approved`,
      react: TourApprovedEmail({
        creatorName: data.creatorName,
        tourTitle: data.tourTitle,
        tourId: data.tourId,
        notes: data.notes,
      }),
    });

    if (error) {
      console.error('Failed to send tour approved email:', error);
      return { success: false, error: error.message };
    }

    console.log('Tour approved email sent:', result?.id);
    return { success: true, messageId: result?.id };
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error';
    console.error('Error sending tour approved email:', errorMessage);
    return { success: false, error: errorMessage };
  }
}

/**
 * Send tour rejected notification email
 */
export async function sendTourRejectedEmail(
  data: TourRejectedEmailData
): Promise<SendEmailResult> {
  if (!isEmailEnabled() || !resend) {
    console.warn('Email is not enabled. Skipping tour rejected email.');
    return { success: false, error: 'Email service not configured' };
  }

  try {
    const { data: result, error } = await resend.emails.send({
      from: `${EMAIL_CONFIG.from.name} <${EMAIL_CONFIG.from.email}>`,
      to: data.creatorEmail,
      replyTo: EMAIL_CONFIG.replyTo,
      subject: `Changes requested for "${data.tourTitle}"`,
      react: TourRejectedEmail({
        creatorName: data.creatorName,
        tourTitle: data.tourTitle,
        tourId: data.tourId,
        reason: data.reason,
        stopComments: data.stopComments,
      }),
    });

    if (error) {
      console.error('Failed to send tour rejected email:', error);
      return { success: false, error: error.message };
    }

    console.log('Tour rejected email sent:', result?.id);
    return { success: true, messageId: result?.id };
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error';
    console.error('Error sending tour rejected email:', errorMessage);
    return { success: false, error: errorMessage };
  }
}

/**
 * Send welcome email to new creator
 */
export async function sendWelcomeEmail(
  data: WelcomeEmailData
): Promise<SendEmailResult> {
  if (!isEmailEnabled() || !resend) {
    console.warn('Email is not enabled. Skipping welcome email.');
    return { success: false, error: 'Email service not configured' };
  }

  try {
    const { data: result, error } = await resend.emails.send({
      from: `${EMAIL_CONFIG.from.name} <${EMAIL_CONFIG.from.email}>`,
      to: data.creatorEmail,
      replyTo: EMAIL_CONFIG.replyTo,
      subject: 'Welcome to At Your Pace - Start creating amazing tours!',
      react: WelcomeCreatorEmail({
        creatorName: data.creatorName,
      }),
    });

    if (error) {
      console.error('Failed to send welcome email:', error);
      return { success: false, error: error.message };
    }

    console.log('Welcome email sent:', result?.id);
    return { success: true, messageId: result?.id };
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error';
    console.error('Error sending welcome email:', errorMessage);
    return { success: false, error: errorMessage };
  }
}
