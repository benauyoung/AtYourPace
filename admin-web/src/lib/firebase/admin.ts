import {
  collection,
  doc,
  getDoc,
  getDocs,
  updateDoc,
  addDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  deleteField,
  serverTimestamp,
  Timestamp,
  onSnapshot,
  QueryConstraint,
} from 'firebase/firestore';
import { db, auth } from './config';
import {
  UserModel,
  TourModel,
  TourVersionModel,
  StopModel,
  AuditLogEntry,
  AuditAction,
  UserRole,
  TourStatsOverview,
  UserStatsOverview,
  AppSettings,
  timestampToDate,
  nullableTimestampToDate,
} from '@/types';

// Collection names
const COLLECTIONS = {
  users: 'users',
  tours: 'tours',
  versions: 'versions',
  stops: 'stops',
  reviews: 'reviews',
  reviewQueue: 'reviewQueue',
  rateLimits: 'rateLimits',
  config: 'config',
  auditLogs: 'auditLogs',
};

// Helper to verify admin role
async function verifyAdminRole(): Promise<void> {
  const user = auth.currentUser;
  if (!user) {
    throw new Error('User must be authenticated');
  }

  const userDoc = await getDoc(doc(db, COLLECTIONS.users, user.uid));
  if (!userDoc.exists()) {
    throw new Error('User not found');
  }

  const userData = userDoc.data();
  if (userData.role !== 'admin') {
    throw new Error('Admin permission required');
  }
}

// Helper to log admin actions
async function logAction(params: {
  action: AuditAction;
  targetId?: string;
  targetType?: string;
  details?: Record<string, unknown>;
}): Promise<void> {
  const user = auth.currentUser;
  if (!user) return;

  try {
    await addDoc(collection(db, COLLECTIONS.auditLogs), {
      adminId: user.uid,
      adminEmail: user.email || 'Unknown',
      action: params.action,
      ...(params.targetId && { targetId: params.targetId }),
      ...(params.targetType && { targetType: params.targetType }),
      ...(params.details && { details: params.details }),
      timestamp: serverTimestamp(),
    });
  } catch (e) {
    console.error('Failed to log action:', e);
  }
}

// ==================== User Operations ====================

export async function getCurrentUserData(): Promise<UserModel | null> {
  const user = auth.currentUser;
  if (!user) return null;

  const userDoc = await getDoc(doc(db, COLLECTIONS.users, user.uid));
  if (!userDoc.exists()) return null;

  return parseUserDoc(userDoc.id, userDoc.data());
}

export async function getUsers(filters?: {
  role?: UserRole;
  searchQuery?: string;
  limitCount?: number;
}): Promise<UserModel[]> {
  await verifyAdminRole();

  const constraints: QueryConstraint[] = [];

  if (filters?.role) {
    constraints.push(where('role', '==', filters.role));
  }

  constraints.push(orderBy('createdAt', 'desc'));

  if (filters?.limitCount) {
    constraints.push(limit(filters.limitCount));
  }

  const q = query(collection(db, COLLECTIONS.users), ...constraints);
  const snapshot = await getDocs(q);

  let users = snapshot.docs.map((doc) => parseUserDoc(doc.id, doc.data()));

  if (filters?.searchQuery) {
    const search = filters.searchQuery.toLowerCase();
    users = users.filter(
      (u) =>
        u.email.toLowerCase().includes(search) ||
        u.displayName.toLowerCase().includes(search)
    );
  }

  return users;
}

export async function updateUserRole(
  userId: string,
  role: UserRole,
  reason?: string
): Promise<void> {
  await verifyAdminRole();

  const userDoc = await getDoc(doc(db, COLLECTIONS.users, userId));
  const previousRole = userDoc.data()?.role;

  await updateDoc(doc(db, COLLECTIONS.users, userId), {
    role,
    roleUpdatedAt: serverTimestamp(),
    roleUpdatedBy: auth.currentUser!.uid,
  });

  await logAction({
    action: 'userRoleChanged',
    targetId: userId,
    targetType: 'user',
    details: {
      previousRole,
      newRole: role,
      ...(reason && { reason }),
    },
  });
}

export async function banUser(userId: string, reason?: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.users, userId), {
    banned: true,
    bannedAt: serverTimestamp(),
    bannedBy: auth.currentUser!.uid,
    ...(reason && { banReason: reason }),
  });

  await logAction({
    action: 'userBanned',
    targetId: userId,
    targetType: 'user',
    details: reason ? { reason } : undefined,
  });
}

export async function unbanUser(userId: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.users, userId), {
    banned: false,
    bannedAt: deleteField(),
    bannedBy: deleteField(),
    banReason: deleteField(),
  });

  await logAction({
    action: 'userUnbanned',
    targetId: userId,
    targetType: 'user',
  });
}

// ==================== Tour Operations ====================

export async function getTours(filters?: {
  status?: string;
  category?: string;
  featured?: boolean;
  searchQuery?: string;
  limitCount?: number;
}): Promise<TourModel[]> {
  await verifyAdminRole();

  const constraints: QueryConstraint[] = [];

  if (filters?.status) {
    constraints.push(where('status', '==', filters.status));
  }

  if (filters?.category) {
    constraints.push(where('category', '==', filters.category));
  }

  if (filters?.featured !== undefined) {
    constraints.push(where('featured', '==', filters.featured));
  }

  constraints.push(orderBy('createdAt', 'desc'));

  if (filters?.limitCount) {
    constraints.push(limit(filters.limitCount));
  }

  const q = query(collection(db, COLLECTIONS.tours), ...constraints);
  const snapshot = await getDocs(q);

  let tours = snapshot.docs.map((doc) => parseTourDoc(doc.id, doc.data()));

  if (filters?.searchQuery) {
    const search = filters.searchQuery.toLowerCase();
    tours = tours.filter(
      (t) =>
        t.creatorName.toLowerCase().includes(search) ||
        t.city?.toLowerCase().includes(search) ||
        t.country?.toLowerCase().includes(search)
    );
  }

  return tours;
}

export async function getTour(tourId: string): Promise<TourModel | null> {
  await verifyAdminRole();

  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) return null;

  return parseTourDoc(tourDoc.id, tourDoc.data());
}

export async function getTourVersion(
  tourId: string,
  versionId: string
): Promise<TourVersionModel | null> {
  await verifyAdminRole();

  const versionDoc = await getDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, versionId)
  );
  if (!versionDoc.exists()) return null;

  return parseVersionDoc(tourId, versionDoc.id, versionDoc.data());
}

export async function getTourStops(
  tourId: string,
  versionId: string
): Promise<StopModel[]> {
  await verifyAdminRole();

  const q = query(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, versionId, COLLECTIONS.stops),
    orderBy('order', 'asc')
  );
  const snapshot = await getDocs(q);

  return snapshot.docs.map((doc) =>
    parseStopDoc(tourId, versionId, doc.id, doc.data())
  );
}

export async function getPendingTours(): Promise<TourModel[]> {
  await verifyAdminRole();

  const q = query(
    collection(db, COLLECTIONS.tours),
    where('status', '==', 'pending_review'),
    orderBy('updatedAt', 'asc')
  );
  const snapshot = await getDocs(q);

  return snapshot.docs.map((doc) => parseTourDoc(doc.id, doc.data()));
}

export function subscribeToPendingTours(
  callback: (tours: TourModel[]) => void
): () => void {
  const q = query(
    collection(db, COLLECTIONS.tours),
    where('status', '==', 'pending_review'),
    orderBy('updatedAt', 'asc')
  );

  return onSnapshot(q, (snapshot) => {
    const tours = snapshot.docs.map((doc) => parseTourDoc(doc.id, doc.data()));
    callback(tours);
  });
}

export async function approveTour(tourId: string, notes?: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'approved',
    approvedAt: serverTimestamp(),
    lastReviewedAt: serverTimestamp(),
    approvedBy: auth.currentUser!.uid,
    ...(notes && { approvalNotes: notes }),
  });

  await logAction({
    action: 'tourApproved',
    targetId: tourId,
    targetType: 'tour',
    details: notes ? { notes } : undefined,
  });
}

export async function rejectTour(tourId: string, reason: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'rejected',
    rejectedAt: serverTimestamp(),
    lastReviewedAt: serverTimestamp(),
    rejectedBy: auth.currentUser!.uid,
    rejectionReason: reason,
  });

  await logAction({
    action: 'tourRejected',
    targetId: tourId,
    targetType: 'tour',
    details: { reason },
  });
}

export async function hideTour(tourId: string, reason?: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'hidden',
    hiddenAt: serverTimestamp(),
    hiddenBy: auth.currentUser!.uid,
    ...(reason && { hideReason: reason }),
  });

  await logAction({
    action: 'tourHidden',
    targetId: tourId,
    targetType: 'tour',
    details: reason ? { reason } : undefined,
  });
}

export async function unhideTour(tourId: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'approved',
    hiddenAt: deleteField(),
    hiddenBy: deleteField(),
    hideReason: deleteField(),
  });

  await logAction({
    action: 'tourUnhidden',
    targetId: tourId,
    targetType: 'tour',
  });
}

export async function featureTour(tourId: string, featured: boolean): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    featured,
    ...(featured
      ? { featuredAt: serverTimestamp(), featuredBy: auth.currentUser!.uid }
      : { featuredAt: deleteField(), featuredBy: deleteField() }),
  });

  await logAction({
    action: featured ? 'tourFeatured' : 'tourUnfeatured',
    targetId: tourId,
    targetType: 'tour',
  });
}

// ==================== Statistics ====================

export async function getTourStats(): Promise<TourStatsOverview> {
  await verifyAdminRole();

  const snapshot = await getDocs(collection(db, COLLECTIONS.tours));

  const stats: TourStatsOverview = {
    totalTours: snapshot.size,
    draftTours: 0,
    pendingTours: 0,
    liveTours: 0,
    featuredTours: 0,
    rejectedTours: 0,
    hiddenTours: 0,
  };

  snapshot.docs.forEach((doc) => {
    const data = doc.data();
    const status = data.status as string;
    const featured = data.featured as boolean;

    switch (status) {
      case 'draft':
        stats.draftTours++;
        break;
      case 'pending_review':
        stats.pendingTours++;
        break;
      case 'approved':
        stats.liveTours++;
        break;
      case 'rejected':
        stats.rejectedTours++;
        break;
      case 'hidden':
        stats.hiddenTours++;
        break;
    }

    if (featured) {
      stats.featuredTours++;
    }
  });

  return stats;
}

export async function getUserStats(): Promise<UserStatsOverview> {
  await verifyAdminRole();

  const snapshot = await getDocs(collection(db, COLLECTIONS.users));

  const stats: UserStatsOverview = {
    totalUsers: snapshot.size,
    regularUsers: 0,
    creators: 0,
    admins: 0,
    bannedUsers: 0,
  };

  snapshot.docs.forEach((doc) => {
    const data = doc.data();
    const role = data.role as string;
    const banned = data.banned as boolean;

    switch (role) {
      case 'user':
        stats.regularUsers++;
        break;
      case 'creator':
        stats.creators++;
        break;
      case 'admin':
        stats.admins++;
        break;
    }

    if (banned) {
      stats.bannedUsers++;
    }
  });

  return stats;
}

// ==================== Audit Logs ====================

export async function getAuditLogs(filters?: {
  adminId?: string;
  action?: AuditAction;
  targetId?: string;
  limitCount?: number;
  startAfterTimestamp?: Date;
}): Promise<AuditLogEntry[]> {
  await verifyAdminRole();

  const constraints: QueryConstraint[] = [orderBy('timestamp', 'desc')];

  if (filters?.adminId) {
    constraints.push(where('adminId', '==', filters.adminId));
  }

  if (filters?.action) {
    constraints.push(where('action', '==', filters.action));
  }

  if (filters?.targetId) {
    constraints.push(where('targetId', '==', filters.targetId));
  }

  if (filters?.startAfterTimestamp) {
    constraints.push(startAfter(Timestamp.fromDate(filters.startAfterTimestamp)));
  }

  constraints.push(limit(filters?.limitCount || 50));

  const q = query(collection(db, COLLECTIONS.auditLogs), ...constraints);
  const snapshot = await getDocs(q);

  return snapshot.docs.map((doc) => parseAuditLogDoc(doc.id, doc.data()));
}

// ==================== Settings ====================

export async function getAppSettings(): Promise<AppSettings> {
  await verifyAdminRole();

  const settingsDoc = await getDoc(doc(db, COLLECTIONS.config, 'appSettings'));

  if (!settingsDoc.exists()) {
    return {
      maintenanceMode: false,
      registrationEnabled: true,
      maxToursPerCreator: 10,
      elevenLabsQuota: 100,
      minAppVersion: '1.0.0',
      latestAppVersion: '1.0.0',
    };
  }

  const data = settingsDoc.data();
  return {
    maintenanceMode: data.maintenanceMode ?? false,
    registrationEnabled: data.registrationEnabled ?? true,
    maxToursPerCreator: data.maxToursPerCreator ?? 10,
    elevenLabsQuota: data.elevenLabsQuota ?? 100,
    minAppVersion: data.minAppVersion ?? '1.0.0',
    latestAppVersion: data.latestAppVersion ?? '1.0.0',
  };
}

export async function updateAppSettings(
  settings: Partial<AppSettings>
): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.config, 'appSettings'), {
    ...settings,
    updatedAt: serverTimestamp(),
    updatedBy: auth.currentUser!.uid,
  });

  await logAction({
    action: 'settingsUpdated',
    details: settings as Record<string, unknown>,
  });
}

// ==================== Parsers ====================

function parseUserDoc(id: string, data: Record<string, unknown>): UserModel {
  return {
    uid: id,
    email: data.email as string,
    displayName: data.displayName as string,
    photoUrl: data.photoUrl as string | undefined,
    role: (data.role as UserRole) || 'user',
    creatorProfile: data.creatorProfile as UserModel['creatorProfile'],
    preferences: (data.preferences as UserModel['preferences']) || {
      autoPlayAudio: true,
      triggerMode: 'geofence',
      offlineEnabled: true,
    },
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
    banned: data.banned as boolean | undefined,
    bannedAt: nullableTimestampToDate(data.bannedAt),
    bannedBy: data.bannedBy as string | undefined,
    banReason: data.banReason as string | undefined,
  };
}

function parseTourDoc(id: string, data: Record<string, unknown>): TourModel {
  const startLocation = data.startLocation as { latitude: number; longitude: number } | undefined;
  return {
    id,
    creatorId: data.creatorId as string,
    creatorName: data.creatorName as string,
    slug: data.slug as string | undefined,
    category: (data.category as TourModel['category']) || 'other',
    tourType: (data.tourType as TourModel['tourType']) || 'walking',
    status: (data.status as TourModel['status']) || 'draft',
    featured: (data.featured as boolean) || false,
    startLocation: startLocation || { latitude: 0, longitude: 0 },
    geohash: data.geohash as string,
    city: data.city as string | undefined,
    region: data.region as string | undefined,
    country: data.country as string | undefined,
    liveVersionId: data.liveVersionId as string | undefined,
    liveVersion: data.liveVersion as number | undefined,
    draftVersionId: data.draftVersionId as string,
    draftVersion: (data.draftVersion as number) || 1,
    stats: (data.stats as TourModel['stats']) || {
      totalPlays: 0,
      totalDownloads: 0,
      averageRating: 0,
      totalRatings: 0,
      totalRevenue: 0,
    },
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
    publishedAt: nullableTimestampToDate(data.publishedAt),
    lastReviewedAt: nullableTimestampToDate(data.lastReviewedAt),
    approvedAt: nullableTimestampToDate(data.approvedAt),
    approvedBy: data.approvedBy as string | undefined,
    approvalNotes: data.approvalNotes as string | undefined,
    rejectedAt: nullableTimestampToDate(data.rejectedAt),
    rejectedBy: data.rejectedBy as string | undefined,
    rejectionReason: data.rejectionReason as string | undefined,
    hiddenAt: nullableTimestampToDate(data.hiddenAt),
    hiddenBy: data.hiddenBy as string | undefined,
    hideReason: data.hideReason as string | undefined,
    featuredAt: nullableTimestampToDate(data.featuredAt),
    featuredBy: data.featuredBy as string | undefined,
  };
}

function parseVersionDoc(
  tourId: string,
  id: string,
  data: Record<string, unknown>
): TourVersionModel {
  return {
    id,
    tourId,
    versionNumber: (data.versionNumber as number) || 1,
    versionType: (data.versionType as TourVersionModel['versionType']) || 'draft',
    title: data.title as string,
    description: data.description as string,
    coverImageUrl: data.coverImageUrl as string | undefined,
    duration: data.duration as string | undefined,
    distance: data.distance as string | undefined,
    difficulty: (data.difficulty as TourVersionModel['difficulty']) || 'moderate',
    languages: (data.languages as string[]) || [],
    route: data.route as TourVersionModel['route'],
    submittedAt: nullableTimestampToDate(data.submittedAt),
    reviewedAt: nullableTimestampToDate(data.reviewedAt),
    reviewedBy: data.reviewedBy as string | undefined,
    reviewNotes: data.reviewNotes as string | undefined,
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
  };
}

function parseStopDoc(
  tourId: string,
  versionId: string,
  id: string,
  data: Record<string, unknown>
): StopModel {
  const location = data.location as { latitude: number; longitude: number } | undefined;
  return {
    id,
    tourId,
    versionId,
    order: (data.order as number) || 0,
    name: data.name as string,
    description: (data.description as string) || '',
    location: location || { latitude: 0, longitude: 0 },
    geohash: data.geohash as string,
    triggerRadius: (data.triggerRadius as number) || 30,
    media: (data.media as StopModel['media']) || {
      audioSource: 'recorded',
      images: [],
    },
    navigation: data.navigation as StopModel['navigation'],
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
  };
}

function parseAuditLogDoc(
  id: string,
  data: Record<string, unknown>
): AuditLogEntry {
  return {
    id,
    adminId: data.adminId as string,
    adminEmail: (data.adminEmail as string) || 'Unknown',
    action: data.action as AuditAction,
    targetId: data.targetId as string | undefined,
    targetType: data.targetType as string | undefined,
    details: data.details as Record<string, unknown> | undefined,
    timestamp: timestampToDate(data.timestamp),
  };
}
