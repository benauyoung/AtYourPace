import { Resend } from 'resend';

// Initialize Resend client
// RESEND_API_KEY should be set in environment variables
const resendApiKey = process.env.RESEND_API_KEY;

if (!resendApiKey) {
  console.warn('RESEND_API_KEY is not set. Email functionality will be disabled.');
}

export const resend = resendApiKey ? new Resend(resendApiKey) : null;

// Email configuration
export const EMAIL_CONFIG = {
  from: {
    name: 'At Your Pace',
    email: 'noreply@atyourpace.com',
  },
  replyTo: 'support@atyourpace.com',
};

// Helper to check if email is enabled
export function isEmailEnabled(): boolean {
  return resend !== null;
}

// Type definitions for email payloads
export interface TourApprovedEmailData {
  creatorName: string;
  creatorEmail: string;
  tourTitle: string;
  tourId: string;
  notes?: string;
}

export interface TourRejectedEmailData {
  creatorName: string;
  creatorEmail: string;
  tourTitle: string;
  tourId: string;
  reason: string;
  stopComments?: Array<{
    stopName: string;
    comments: string[];
  }>;
}

export interface WelcomeEmailData {
  creatorName: string;
  creatorEmail: string;
}
