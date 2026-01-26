// Resend email integration
export { resend, EMAIL_CONFIG, isEmailEnabled } from './client';
export type {
  TourApprovedEmailData,
  TourRejectedEmailData,
  WelcomeEmailData,
} from './client';

export {
  sendTourApprovedEmail,
  sendTourRejectedEmail,
  sendWelcomeEmail,
} from './send-emails';

// Re-export templates for testing/preview
export * from './templates';
