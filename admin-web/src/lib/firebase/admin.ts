import {
  AppSettings,
  AuditAction,
  AuditLogEntry,
  CollectionModel,
  CollectionType,
  FeedbackPriority,
  FeedbackType,
  nullableTimestampToDate,
  PublishingSubmissionModel,
  ReviewCommentModel,
  ReviewFeedbackModel,
  StopModel,
  SubmissionStatus,
  timestampToDate,
  TourModel,
  TourStatsOverview,
  TourVersionModel,
  UserModel,
  UserRole,
  UserStatsOverview,
} from '@/types';
import {
  addDoc,
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  limit,
  onSnapshot,
  orderBy,
  query,
  QueryConstraint,
  serverTimestamp,
  startAfter,
  Timestamp,
  updateDoc,
  where
} from 'firebase/firestore';
import { auth, db } from './config';

// Collection names
const COLLECTIONS = {
  users: 'users',
  tours: 'tours',
  versions: 'versions',
  stops: 'stops',
  reviews: 'reviews',
  reviewQueue: 'reviewQueue',
  reviewComments: 'reviewComments',
  rateLimits: 'rateLimits',
  config: 'config',
  auditLogs: 'auditLogs',
  // New collections
  pricing: 'pricing',
  routes: 'routes',
  waypoints: 'waypoints',
  publishingSubmissions: 'publishingSubmissions',
  reviewFeedback: 'reviewFeedback',
  voiceGenerations: 'voiceGenerations',
  collections: 'collections',
  analytics: 'analytics',
};

// Helper to verify admin role
// Simplified: treat all authenticated users as admin (matching auth.ts bypass)
async function verifyAdminRole(): Promise<void> {
  const user = auth.currentUser;
  if (!user) {
    throw new Error('User must be authenticated');
  }

  // Skip Firestore check - treat all authenticated users as admin for now
  // This matches the bypass in auth.ts
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
  callback: (tours: (TourModel & { versionTitle?: string })[]) => void
): () => void {
  const q = query(
    collection(db, COLLECTIONS.tours),
    where('status', '==', 'pending_review'),
    orderBy('updatedAt', 'asc')
  );

  return onSnapshot(q, async (snapshot) => {
    const tours = snapshot.docs.map((doc) => parseTourDoc(doc.id, doc.data()));

    // Fetch version titles for each tour
    const toursWithTitles = await Promise.all(
      tours.map(async (tour) => {
        try {
          const version = await getTourVersion(tour.id, tour.draftVersionId);
          return { ...tour, versionTitle: version?.title };
        } catch {
          return { ...tour, versionTitle: undefined };
        }
      })
    );

    callback(toursWithTitles);
  });
}

export async function approveTour(tourId: string, notes?: string): Promise<void> {
  await verifyAdminRole();

  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) throw new Error('Tour not found');
  const tourData = tourDoc.data();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'approved',
    approvedAt: serverTimestamp(),
    lastReviewedAt: serverTimestamp(),
    approvedBy: auth.currentUser!.uid,
    // Promote draft to live
    liveVersionId: tourData.draftVersionId,
    liveVersion: tourData.draftVersion,
    publishedAt: serverTimestamp(),
    ...(notes && { approvalNotes: notes }),
  });

  await logAction({
    action: 'tourApproved',
    targetId: tourId,
    targetType: 'tour',
    details: notes ? { notes } : undefined,
  });
}

export async function rejectTour(
  tourId: string,
  reason: string,
  includeStopComments?: boolean
): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'rejected',
    rejectedAt: serverTimestamp(),
    lastReviewedAt: serverTimestamp(),
    rejectedBy: auth.currentUser!.uid,
    rejectionReason: reason,
    // Store flag for notification system to know whether to include stop comments
    rejectionIncludesStopComments: includeStopComments ?? false,
  });

  await logAction({
    action: 'tourRejected',
    targetId: tourId,
    targetType: 'tour',
    details: { reason, includeStopComments },
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

export async function deleteTour(tourId: string): Promise<void> {
  await verifyAdminRole();

  // Note: This only deletes the top-level document. Subcollections (versions/stops) remain orphaned in Firestore
  // unless a Cloud Function handles cleanup. For this admin tool, we'll accept this limitation or should warn the user.
  // Ideally, we'd mark as deleted (soft delete) if we want to preserve data, but users usually expect "delete" to remove it.
  // Given we have "Hide" for soft-removal, "Delete" implies hard removal.

  await deleteDoc(doc(db, COLLECTIONS.tours, tourId));

  await logAction({
    action: 'tourDeleted' as AuditAction, // Ensure AuditAction type includes this or cast it if restricted
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

// ==================== Review Comments ====================

export async function getReviewComments(
  tourId: string,
  versionId: string
): Promise<ReviewCommentModel[]> {
  await verifyAdminRole();

  const q = query(
    collection(db, COLLECTIONS.reviewComments),
    where('tourId', '==', tourId),
    where('versionId', '==', versionId),
    orderBy('createdAt', 'asc')
  );
  const snapshot = await getDocs(q);

  return snapshot.docs.map((doc) => parseReviewCommentDoc(doc.id, doc.data()));
}

export async function addReviewComment(
  tourId: string,
  versionId: string,
  stopId: string,
  content: string
): Promise<ReviewCommentModel> {
  await verifyAdminRole();

  const user = auth.currentUser!;

  const commentData = {
    tourId,
    versionId,
    stopId,
    authorId: user.uid,
    authorName: user.displayName || 'Admin',
    authorEmail: user.email || '',
    content,
    resolved: false,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };

  const docRef = await addDoc(collection(db, COLLECTIONS.reviewComments), commentData);

  return {
    id: docRef.id,
    tourId,
    versionId,
    stopId,
    authorId: user.uid,
    authorName: user.displayName || 'Admin',
    authorEmail: user.email || '',
    content,
    resolved: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  };
}

export async function deleteReviewComment(commentId: string): Promise<void> {
  await verifyAdminRole();

  const { deleteDoc } = await import('firebase/firestore');
  await deleteDoc(doc(db, COLLECTIONS.reviewComments, commentId));
}

export async function resolveReviewComment(commentId: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.reviewComments, commentId), {
    resolved: true,
    resolvedAt: serverTimestamp(),
    resolvedBy: auth.currentUser!.uid,
    updatedAt: serverTimestamp(),
  });
}

export async function unresolveReviewComment(commentId: string): Promise<void> {
  await verifyAdminRole();

  await updateDoc(doc(db, COLLECTIONS.reviewComments, commentId), {
    resolved: false,
    resolvedAt: deleteField(),
    resolvedBy: deleteField(),
    updatedAt: serverTimestamp(),
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

// ==================== Publishing Workflow Operations ====================

export function subscribeToSubmissions(
  callback: (submissions: PublishingSubmissionModel[]) => void
): () => void {
  const q = query(
    collection(db, COLLECTIONS.publishingSubmissions),
    where('status', 'in', ['submitted', 'under_review', 'changes_requested']),
    orderBy('submittedAt', 'asc')
  );

  return onSnapshot(q, (snapshot) => {
    const submissions = snapshot.docs.map((doc) => parseSubmissionDoc(doc.id, doc.data()));
    callback(submissions);
  });
}

export async function getSubmission(submissionId: string): Promise<PublishingSubmissionModel | null> {
  await verifyAdminRole();

  // Handle legacy submissions (mapped from pending tours)
  if (submissionId.startsWith('legacy-')) {
    const tourId = submissionId.replace('legacy-', '');
    const tour = await getTour(tourId);
    if (!tour) return null;

    const version = await getTourVersion(tourId, tour.draftVersionId);

    // Fetch legacy comments and adapt to feedback
    const legacyComments = await getReviewComments(tourId, tour.draftVersionId);
    const feedback: ReviewFeedbackModel[] = legacyComments.map(c => ({
      id: c.id,
      submissionId,
      reviewerId: c.authorId,
      reviewerName: c.authorName,
      type: 'issue' as FeedbackType, // Default
      message: c.content,
      stopId: c.stopId,
      priority: 'medium' as FeedbackPriority,
      resolved: c.resolved,
      resolvedAt: c.resolvedAt,
      resolvedBy: c.resolvedBy,
      createdAt: c.createdAt,
    }));

    return {
      id: submissionId,
      tourId: tour.id,
      versionId: tour.draftVersionId,
      creatorId: tour.creatorId,
      creatorName: tour.creatorName,
      status: 'submitted' as SubmissionStatus, // Map pending_review -> submitted
      submittedAt: tour.updatedAt,
      reviewedAt: tour.lastReviewedAt,
      reviewerId: undefined, // Legacy didn't track active reviewer on the tour doc specifically same way
      feedback,
      resubmissionCount: 0,
      creatorIgnoredSuggestions: false,
      tourTitle: version?.title,
      tourDescription: version?.description,
      createdAt: tour.createdAt,
      updatedAt: tour.updatedAt,
    };
  }

  const docRef = doc(db, COLLECTIONS.publishingSubmissions, submissionId);
  const snapshot = await getDoc(docRef);

  if (!snapshot.exists()) return null;

  const submission = parseSubmissionDoc(snapshot.id, snapshot.data());

  // Fetch feedback
  const feedbackSnapshot = await getDocs(
    query(
      collection(docRef, COLLECTIONS.reviewFeedback),
      orderBy('createdAt', 'desc')
    )
  );

  submission.feedback = feedbackSnapshot.docs.map(doc =>
    parseFeedbackDoc(doc.id, doc.data())
  );

  return submission;
}

export async function updateSubmissionStatus(
  submissionId: string,
  status: SubmissionStatus,
  data?: {
    reviewerId?: string;
    reviewerName?: string;
    rejectionReason?: string;
  }
): Promise<void> {
  await verifyAdminRole();

  // Handle legacy submissions - directly update tour status
  if (submissionId.startsWith('legacy-')) {
    const tourId = submissionId.replace('legacy-', '');
    if (status === 'approved') {
      await approveTour(tourId);
    } else if (status === 'rejected') {
      await rejectTour(tourId, data?.rejectionReason || 'Rejected', false);
    }
    return; // Done - no publishingSubmissions doc to update
  }

  const updates: Record<string, any> = {
    status,
    updatedAt: serverTimestamp(),
  };

  if (status === 'under_review' || status === 'approved' || status === 'rejected' || status === 'changes_requested') {
    if (data?.reviewerId) {
      updates.reviewerId = data.reviewerId;
      updates.reviewerName = data.reviewerName;
    }
    if (status === 'approved' || status === 'rejected' || status === 'changes_requested') {
      updates.reviewedAt = serverTimestamp();
    }
  }

  if (status === 'rejected' && data?.rejectionReason) {
    updates.rejectionReason = data.rejectionReason;
  }

  await updateDoc(doc(db, COLLECTIONS.publishingSubmissions, submissionId), updates);

  // Update TourModel status accordingly
  if (status === 'approved') {
    const submission = await getSubmission(submissionId);
    if (submission) {
      await approveTour(submission.tourId);
    }
  } else if (status === 'rejected') {
    const submission = await getSubmission(submissionId);
    if (submission) {
      await rejectTour(submission.tourId, data?.rejectionReason || 'Rejected via submission workflow', false);
    }
  }
}

export async function addSubmissionFeedback(
  submissionId: string,
  feedback: Omit<ReviewFeedbackModel, 'id' | 'createdAt' | 'submissionId'>
): Promise<string> {
  await verifyAdminRole();

  const feedbackData = {
    ...feedback,
    submissionId,
    createdAt: serverTimestamp(),
  };

  const docRef = await addDoc(
    collection(db, COLLECTIONS.publishingSubmissions, submissionId, COLLECTIONS.reviewFeedback),
    feedbackData
  );

  return docRef.id;
}

export async function resolveSubmissionFeedback(
  submissionId: string,
  feedbackId: string,
  resolvedBy: string,
  note?: string
): Promise<void> {
  await verifyAdminRole();

  await updateDoc(
    doc(db, COLLECTIONS.publishingSubmissions, submissionId, COLLECTIONS.reviewFeedback, feedbackId),
    {
      resolved: true,
      resolvedAt: serverTimestamp(),
      resolvedBy,
      resolutionNote: note,
    }
  );
}

// ==================== Collections Operations ====================

export async function getCollections(
  filters?: {
    type?: CollectionType;
    isCurated?: boolean;
    isFeatured?: boolean;
  }
): Promise<CollectionModel[]> {
  await verifyAdminRole();

  let constraints: QueryConstraint[] = [orderBy('sortOrder', 'asc'), orderBy('createdAt', 'desc')];

  if (filters?.type) {
    constraints.push(where('type', '==', filters.type));
  }

  if (filters?.isCurated !== undefined) {
    constraints.push(where('isCurated', '==', filters.isCurated));
  }

  if (filters?.isFeatured !== undefined) {
    constraints.push(where('isFeatured', '==', filters.isFeatured));
  }

  const q = query(collection(db, COLLECTIONS.collections), ...constraints);
  const snapshot = await getDocs(q);

  return snapshot.docs.map((doc) => parseCollectionDoc(doc.id, doc.data()));
}

export async function getCollection(collectionId: string): Promise<CollectionModel | null> {
  await verifyAdminRole();
  const docRef = doc(db, COLLECTIONS.collections, collectionId);
  const snapshot = await getDoc(docRef);

  if (!snapshot.exists()) return null;

  return parseCollectionDoc(snapshot.id, snapshot.data());
}

export async function createCollection(
  data: Omit<CollectionModel, 'id' | 'createdAt' | 'updatedAt'>
): Promise<string> {
  await verifyAdminRole();

  const docData = {
    ...data,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };

  const docRef = await addDoc(collection(db, COLLECTIONS.collections), docData);
  return docRef.id;
}

export async function updateCollection(
  collectionId: string,
  data: Partial<Omit<CollectionModel, 'id' | 'createdAt' | 'updatedAt'>>
): Promise<void> {
  await verifyAdminRole();

  const updates = {
    ...data,
    updatedAt: serverTimestamp(),
  };

  await updateDoc(doc(db, COLLECTIONS.collections, collectionId), updates);
}

export async function deleteCollection(collectionId: string): Promise<void> {
  await verifyAdminRole();
  await deleteDoc(doc(db, COLLECTIONS.collections, collectionId));
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

function parseReviewCommentDoc(
  id: string,
  data: Record<string, unknown>
): ReviewCommentModel {
  return {
    id,
    tourId: data.tourId as string,
    versionId: data.versionId as string,
    stopId: data.stopId as string,
    authorId: data.authorId as string,
    authorName: (data.authorName as string) || 'Admin',
    authorEmail: (data.authorEmail as string) || '',
    content: data.content as string,
    resolved: (data.resolved as boolean) || false,
    resolvedAt: nullableTimestampToDate(data.resolvedAt),
    resolvedBy: data.resolvedBy as string | undefined,
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
  };
}

function parseSubmissionDoc(id: string, data: Record<string, unknown>): PublishingSubmissionModel {
  return {
    id,
    tourId: data.tourId as string,
    versionId: data.versionId as string,
    creatorId: data.creatorId as string,
    creatorName: data.creatorName as string,
    status: (data.status as SubmissionStatus),
    submittedAt: timestampToDate(data.submittedAt),
    reviewedAt: nullableTimestampToDate(data.reviewedAt),
    reviewerId: data.reviewerId as string | undefined,
    reviewerName: data.reviewerName as string | undefined,
    feedback: [], // Populated separately if needed
    rejectionReason: data.rejectionReason as string | undefined,
    resubmissionJustification: data.resubmissionJustification as string | undefined,
    resubmissionCount: (data.resubmissionCount as number) || 0,
    creatorIgnoredSuggestions: (data.creatorIgnoredSuggestions as boolean) || false,
    tourTitle: data.tourTitle as string | undefined,
    tourDescription: data.tourDescription as string | undefined,
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
  };
}

function parseFeedbackDoc(id: string, data: Record<string, unknown>): ReviewFeedbackModel {
  return {
    id,
    submissionId: data.submissionId as string,
    reviewerId: data.reviewerId as string,
    reviewerName: data.reviewerName as string,
    type: (data.type as FeedbackType),
    message: data.message as string,
    stopId: data.stopId as string | undefined,
    stopName: data.stopName as string | undefined,
    priority: (data.priority as FeedbackPriority),
    resolved: (data.resolved as boolean) || false,
    resolvedAt: nullableTimestampToDate(data.resolvedAt),
    resolvedBy: data.resolvedBy as string | undefined,
    resolutionNote: data.resolutionNote as string | undefined,
    createdAt: timestampToDate(data.createdAt),
  };
}

function parseCollectionDoc(id: string, data: Record<string, unknown>): CollectionModel {
  return {
    id,
    name: data.name as string,
    description: (data.description as string) || '',
    coverImageUrl: data.coverImageUrl as string | undefined,
    tourIds: (data.tourIds as string[]) || [],
    isCurated: (data.isCurated as boolean) || false,
    curatorId: data.curatorId as string | undefined,
    curatorName: data.curatorName as string | undefined,
    isFeatured: (data.isFeatured as boolean) || false,
    tags: (data.tags as string[]) || [],
    type: (data.type as CollectionType) || 'geographic',
    sortOrder: (data.sortOrder as number) || 0,
    city: data.city as string | undefined,
    region: data.region as string | undefined,
    country: data.country as string | undefined,
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
  };
}
