import { Timestamp } from 'firebase/firestore';

// Enums
export type UserRole = 'user' | 'creator' | 'admin';
export type TriggerMode = 'geofence' | 'manual';
export type TourType = 'walking' | 'driving';
export type TourStatus = 'draft' | 'pending_review' | 'approved' | 'rejected' | 'hidden';
export type TourCategory = 'history' | 'nature' | 'ghost' | 'food' | 'art' | 'architecture' | 'other';
export type VersionType = 'draft' | 'live' | 'archived';
export type TourDifficulty = 'easy' | 'moderate' | 'challenging';
export type AudioSource = 'recorded' | 'elevenlabs' | 'uploaded';

export type AuditAction =
  | 'tourApproved'
  | 'tourRejected'
  | 'tourHidden'
  | 'tourUnhidden'
  | 'tourFeatured'
  | 'tourUnfeatured'
  | 'userRoleChanged'
  | 'userBanned'
  | 'userUnbanned'
  | 'settingsUpdated';

// User Types
export interface CreatorProfile {
  bio: string;
  verified: boolean;
  totalTours: number;
  totalDownloads: number;
}

export interface UserPreferences {
  autoPlayAudio: boolean;
  triggerMode: TriggerMode;
  offlineEnabled: boolean;
  preferredVoice?: string;
}

export interface UserModel {
  uid: string;
  email: string;
  displayName: string;
  photoUrl?: string;
  role: UserRole;
  creatorProfile?: CreatorProfile;
  preferences: UserPreferences;
  createdAt: Date;
  updatedAt: Date;
  banned?: boolean;
  bannedAt?: Date;
  bannedBy?: string;
  banReason?: string;
}

// Tour Types
export interface GeoPoint {
  latitude: number;
  longitude: number;
}

export interface TourStats {
  totalPlays: number;
  totalDownloads: number;
  averageRating: number;
  totalRatings: number;
  totalRevenue: number;
}

export interface TourModel {
  id: string;
  creatorId: string;
  creatorName: string;
  slug?: string;
  category: TourCategory;
  tourType: TourType;
  status: TourStatus;
  featured: boolean;
  startLocation: GeoPoint;
  geohash: string;
  city?: string;
  region?: string;
  country?: string;
  liveVersionId?: string;
  liveVersion?: number;
  draftVersionId: string;
  draftVersion: number;
  stats: TourStats;
  createdAt: Date;
  updatedAt: Date;
  publishedAt?: Date;
  lastReviewedAt?: Date;
  approvedAt?: Date;
  approvedBy?: string;
  approvalNotes?: string;
  rejectedAt?: Date;
  rejectedBy?: string;
  rejectionReason?: string;
  hiddenAt?: Date;
  hiddenBy?: string;
  hideReason?: string;
  featuredAt?: Date;
  featuredBy?: string;
}

// Tour Version Types
export interface RouteWaypoint {
  lat: number;
  lng: number;
}

export interface BoundingBox {
  northeast: GeoPoint;
  southwest: GeoPoint;
}

export interface TourRoute {
  encodedPolyline?: string;
  boundingBox?: BoundingBox;
  waypoints: RouteWaypoint[];
}

export interface TourVersionModel {
  id: string;
  tourId: string;
  versionNumber: number;
  versionType: VersionType;
  title: string;
  description: string;
  coverImageUrl?: string;
  duration?: string;
  distance?: string;
  difficulty: TourDifficulty;
  languages: string[];
  route?: TourRoute;
  submittedAt?: Date;
  reviewedAt?: Date;
  reviewedBy?: string;
  reviewNotes?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Stop Types
export interface StopImage {
  url: string;
  caption?: string;
  order: number;
}

export interface StopMedia {
  audioUrl?: string;
  audioSource: AudioSource;
  audioDuration?: number;
  audioText?: string;
  voiceId?: string;
  images: StopImage[];
  videoUrl?: string;
}

export interface StopNavigation {
  arrivalInstruction?: string;
  parkingInfo?: string;
  direction?: string;
}

export interface StopModel {
  id: string;
  tourId: string;
  versionId: string;
  order: number;
  name: string;
  description: string;
  location: GeoPoint;
  geohash: string;
  triggerRadius: number;
  media: StopMedia;
  navigation?: StopNavigation;
  createdAt: Date;
  updatedAt: Date;
}

// Review Comment Types
export interface ReviewCommentModel {
  id: string;
  tourId: string;
  versionId: string;
  stopId: string;
  authorId: string;
  authorName: string;
  authorEmail: string;
  content: string;
  resolved: boolean;
  resolvedAt?: Date;
  resolvedBy?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Audit Log Types
export interface AuditLogEntry {
  id: string;
  adminId: string;
  adminEmail: string;
  action: AuditAction;
  targetId?: string;
  targetType?: string;
  details?: Record<string, unknown>;
  timestamp: Date;
}

// App Settings Types
export interface AppSettings {
  maintenanceMode: boolean;
  registrationEnabled: boolean;
  maxToursPerCreator: number;
  elevenLabsQuota: number;
  minAppVersion: string;
  latestAppVersion: string;
}

// Dashboard Stats
export interface TourStatsOverview {
  totalTours: number;
  draftTours: number;
  pendingTours: number;
  liveTours: number;
  featuredTours: number;
  rejectedTours: number;
  hiddenTours: number;
}

export interface UserStatsOverview {
  totalUsers: number;
  regularUsers: number;
  creators: number;
  admins: number;
  bannedUsers: number;
}

// Helper to convert Firestore Timestamp to Date
export function timestampToDate(value: unknown): Date {
  if (value instanceof Timestamp) {
    return value.toDate();
  }
  if (typeof value === 'string') {
    return new Date(value);
  }
  if (typeof value === 'number') {
    return new Date(value);
  }
  return new Date();
}

// Helper to convert nullable Firestore Timestamp to Date
export function nullableTimestampToDate(value: unknown): Date | undefined {
  if (value === null || value === undefined) {
    return undefined;
  }
  return timestampToDate(value);
}

// Display helpers
export const categoryDisplayNames: Record<TourCategory, string> = {
  history: 'History',
  nature: 'Nature',
  ghost: 'Ghost Tour',
  food: 'Food & Drink',
  art: 'Art',
  architecture: 'Architecture',
  other: 'Other',
};

export const statusDisplayNames: Record<TourStatus, string> = {
  draft: 'Draft',
  pending_review: 'Pending Review',
  approved: 'Approved',
  rejected: 'Rejected',
  hidden: 'Hidden',
};

export const roleDisplayNames: Record<UserRole, string> = {
  user: 'User',
  creator: 'Creator',
  admin: 'Admin',
};

export const actionDisplayNames: Record<AuditAction, string> = {
  tourApproved: 'Approved tour',
  tourRejected: 'Rejected tour',
  tourHidden: 'Hid tour',
  tourUnhidden: 'Unhid tour',
  tourFeatured: 'Featured tour',
  tourUnfeatured: 'Unfeatured tour',
  userRoleChanged: 'Changed user role',
  userBanned: 'Banned user',
  userUnbanned: 'Unbanned user',
  settingsUpdated: 'Updated settings',
};
