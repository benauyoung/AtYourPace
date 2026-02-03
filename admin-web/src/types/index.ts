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
export type PricingType = 'free' | 'paid' | 'subscription' | 'pay_what_you_want';
export type SubmissionStatus = 'draft' | 'submitted' | 'under_review' | 'changes_requested' | 'approved' | 'rejected' | 'withdrawn';
export type FeedbackType = 'issue' | 'suggestion' | 'compliment' | 'required';
export type FeedbackPriority = 'low' | 'medium' | 'high' | 'critical';
export type VoiceGenerationStatus = 'pending' | 'processing' | 'completed' | 'failed';
export type CollectionType = 'geographic' | 'thematic' | 'seasonal' | 'custom';
export type RouteSnapMode = 'none' | 'roads' | 'walking' | 'manual';
export type AnalyticsPeriod = 'day' | 'week' | 'month' | 'quarter' | 'year' | 'all_time' | 'custom';

export type AuditAction =
  | 'tourApproved'
  | 'tourRejected'
  | 'tourHidden'
  | 'tourUnhidden'
  | 'tourFeatured'
  | 'tourUnfeatured'
  | 'tourDeleted'
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

// Pricing Types
export interface PricingTier {
  id: string;
  name: string;
  price: number;
  description: string;
  features: string[];
  sortOrder: number;
}

export interface PricingModel {
  id: string;
  tourId: string;
  type: PricingType;
  price?: number;
  currency: string;
  allowPayWhatYouWant: boolean;
  suggestedPrice?: number;
  minimumPrice?: number;
  tiers: PricingTier[];
  createdAt: Date;
  updatedAt: Date;
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

// Route Types
export interface RouteWaypoint {
  lat: number;
  lng: number;
}

// Legacy TourRoute interface (kept for compatibility if needed, but RouteModel is preferred)
export interface TourRoute {
  encodedPolyline?: string;
  boundingBox?: BoundingBox;
  waypoints: RouteWaypoint[];
}

export interface RouteModel {
  id: string;
  tourId: string;
  versionId: string;
  waypoints: WaypointModel[]; // Utilizing the shared WaypointModel
  routePolyline: GeoPoint[]; // LatLng list
  snapMode: RouteSnapMode;
  totalDistance: number;
  estimatedDuration: number;
  metadata?: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}

export interface WaypointModel {
  id: string;
  tourId: string;
  routeId: string;
  order: number;
  location: GeoPoint;
  triggerRadius: number;
  isStop: boolean;
  stopId?: string; // If this waypoint is a stop
  createdAt: Date;
  updatedAt: Date;
}

export interface BoundingBox {
  northeast: GeoPoint;
  southwest: GeoPoint;
}

// Tour Version Types
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
  route?: TourRoute; // Keeping generic for now, might migrate to routeId reference
  routeId?: string; // Reference to RouteModel
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

// Publishing & Feedback Types
export interface ReviewFeedbackModel {
  id: string;
  submissionId: string;
  reviewerId: string;
  reviewerName: string;
  type: FeedbackType;
  message: string;
  stopId?: string;
  stopName?: string;
  priority: FeedbackPriority;
  resolved: boolean;
  resolvedAt?: Date;
  resolvedBy?: string;
  resolutionNote?: string;
  createdAt: Date;
}

export interface PublishingSubmissionModel {
  id: string;
  tourId: string;
  versionId: string;
  creatorId: string;
  creatorName: string;
  status: SubmissionStatus;
  submittedAt: Date;
  reviewedAt?: Date;
  reviewerId?: string;
  reviewerName?: string;
  feedback: ReviewFeedbackModel[];
  rejectionReason?: string;
  resubmissionJustification?: string;
  resubmissionCount: number;
  creatorIgnoredSuggestions: boolean;
  tourTitle?: string;
  tourDescription?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Collection Types
export interface CollectionModel {
  id: string;
  name: string;
  description: string;
  coverImageUrl?: string;
  tourIds: string[];
  isCurated: boolean;
  curatorId?: string;
  curatorName?: string;
  isFeatured: boolean;
  tags: string[];
  type: CollectionType;
  sortOrder: number;
  city?: string;
  region?: string;
  country?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Voice Generation Types
export interface VoiceOption {
  id: string;
  name: string;
  description: string;
  accent: string;
  gender: string;
  previewUrl: string;
  elevenLabsId: string;
}

export interface VoiceGenerationHistory {
  script: string;
  voiceId: string;
  audioUrl: string;
  audioDuration: number;
  generatedAt: Date;
}

export interface VoiceGenerationModel {
  id: string;
  stopId: string;
  tourId: string;
  script: string;
  voiceId: string;
  voiceName: string;
  audioUrl?: string;
  audioDuration?: number;
  status: VoiceGenerationStatus;
  errorMessage?: string;
  regenerationCount: number;
  history: VoiceGenerationHistory[];
  createdAt: Date;
  updatedAt: Date;
}

// Analytics Types
export interface TimeSeriesPoint {
  date: Date;
  value: number;
}

export interface PlayMetrics {
  total: number;
  unique: number;
  averageDuration: number;
  completions: number;
  completionRate: number;
  changeFromPrevious: number;
}

export interface DownloadMetrics {
  total: number;
  unique: number;
  storageUsed: number;
  changeFromPrevious: number;
}

export interface FavoriteMetrics {
  total: number;
  changeFromPrevious: number;
}

export interface RevenueMetrics {
  total: number;
  transactions: number;
  averageTransaction: number;
  byPricingTier: Record<string, number>;
  changeFromPrevious: number;
}

export interface CompletionMetrics {
  completionRate: number;
  dropOffByStop: Record<number, number>;
  averageCompletionTime: number;
}

export interface GeographicMetrics {
  byCity: Record<string, number>;
  byCountry: Record<string, number>;
}

export interface TimeSeriesData {
  plays: TimeSeriesPoint[];
  downloads: TimeSeriesPoint[];
  favorites: TimeSeriesPoint[];
}

export interface UserFeedbackMetrics {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: Record<number, number>;
}

export interface TourAnalyticsModel {
  id: string;
  tourId: string;
  period: AnalyticsPeriod;
  startDate: Date;
  endDate: Date;
  plays: PlayMetrics;
  downloads: DownloadMetrics;
  favorites: FavoriteMetrics;
  revenue: RevenueMetrics;
  completion: CompletionMetrics;
  geographic: GeographicMetrics;
  timeSeries: TimeSeriesData;
  feedback: UserFeedbackMetrics;
  generatedAt: Date;
  cachedUntil?: Date;
}

// Review Comment Types (Legacy? Or still used in basic reviews)
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
  if (value && typeof value === 'object' && 'toDate' in value) {
    return (value as Timestamp).toDate();
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
  tourDeleted: 'Deleted tour',
  userRoleChanged: 'Changed user role',
  userBanned: 'Banned user',
  userUnbanned: 'Unbanned user',
  settingsUpdated: 'Updated settings',
};
