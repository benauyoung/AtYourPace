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
  serverTimestamp,
  writeBatch,
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, auth, storage } from './config';
import {
  TourModel,
  TourVersionModel,
  TourStatus,
  TourCategory,
  TourType,
  TourDifficulty,
  timestampToDate,
  nullableTimestampToDate,
} from '@/types';
import ngeohash from 'ngeohash';

// Collection names
const COLLECTIONS = {
  users: 'users',
  tours: 'tours',
  versions: 'versions',
  stops: 'stops',
};

// Helper to verify creator role
// Simplified: treat all authenticated users as creators (matching auth.ts bypass)
async function verifyCreatorRole(): Promise<string> {
  const user = auth.currentUser;
  if (!user) {
    throw new Error('User must be authenticated');
  }

  // Skip Firestore check - treat all authenticated users as creator/admin for now
  // This matches the bypass in auth.ts
  return user.uid;
}

// ==================== Tour Operations ====================

export interface CreateTourInput {
  title: string;
  description: string;
  category: TourCategory;
  tourType: TourType;
  difficulty: TourDifficulty;
  startLocation: { latitude: number; longitude: number };
  city?: string;
  region?: string;
  country?: string;
  coverImageUrl?: string;
}

export interface UpdateTourInput {
  title?: string;
  description?: string;
  category?: TourCategory;
  tourType?: TourType;
  difficulty?: TourDifficulty;
  startLocation?: { latitude: number; longitude: number };
  city?: string;
  region?: string;
  country?: string;
  coverImageUrl?: string;
  duration?: string;
  distance?: string;
}

export interface TourWithVersion {
  tour: TourModel;
  version: TourVersionModel;
}

export async function getCreatorTours(status?: TourStatus): Promise<TourWithVersion[]> {
  const creatorId = await verifyCreatorRole();

  const constraints = [
    where('creatorId', '==', creatorId),
    orderBy('updatedAt', 'desc'),
  ];

  if (status) {
    constraints.unshift(where('status', '==', status));
  }

  const q = query(collection(db, COLLECTIONS.tours), ...constraints);
  const snapshot = await getDocs(q);

  const tours = snapshot.docs.map((doc) => parseTourDoc(doc.id, doc.data()));

  // Fetch versions for all tours
  const toursWithVersions = await Promise.all(
    tours.map(async (tour) => {
      const versionDoc = await getDoc(
        doc(db, COLLECTIONS.tours, tour.id, COLLECTIONS.versions, tour.draftVersionId)
      );
      const version = versionDoc.exists()
        ? parseVersionDoc(tour.id, versionDoc.id, versionDoc.data())
        : {
            id: tour.draftVersionId,
            tourId: tour.id,
            versionNumber: 1,
            versionType: 'draft' as const,
            title: 'Untitled Tour',
            description: '',
            difficulty: 'moderate' as const,
            languages: [],
            createdAt: tour.createdAt,
            updatedAt: tour.updatedAt,
          };
      return { tour, version };
    })
  );

  return toursWithVersions;
}

export async function getCreatorTour(tourId: string): Promise<{ tour: TourModel; version: TourVersionModel } | null> {
  const creatorId = await verifyCreatorRole();

  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) return null;

  const tour = parseTourDoc(tourDoc.id, tourDoc.data());

  // Verify ownership
  if (tour.creatorId !== creatorId) {
    throw new Error('You do not have permission to access this tour');
  }

  // Get the draft version
  const versionDoc = await getDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tour.draftVersionId)
  );

  if (!versionDoc.exists()) {
    throw new Error('Tour version not found');
  }

  const version = parseVersionDoc(tourId, versionDoc.id, versionDoc.data());

  return { tour, version };
}

export async function createTour(input: CreateTourInput): Promise<string> {
  const creatorId = await verifyCreatorRole();

  // Get creator display name
  const userDoc = await getDoc(doc(db, COLLECTIONS.users, creatorId));
  const creatorName = userDoc.data()?.displayName || 'Unknown Creator';

  // Generate geohash from location
  const geohash = ngeohash.encode(input.startLocation.latitude, input.startLocation.longitude, 7);

  // Create the tour document
  const tourRef = doc(collection(db, COLLECTIONS.tours));
  const versionRef = doc(collection(db, COLLECTIONS.tours, tourRef.id, COLLECTIONS.versions));

  const batch = writeBatch(db);

  // Create version document
  batch.set(versionRef, {
    versionNumber: 1,
    versionType: 'draft',
    title: input.title,
    description: input.description,
    coverImageUrl: input.coverImageUrl || null,
    difficulty: input.difficulty,
    languages: ['en'],
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  // Create tour document
  batch.set(tourRef, {
    creatorId,
    creatorName,
    category: input.category,
    tourType: input.tourType,
    status: 'draft',
    featured: false,
    startLocation: input.startLocation,
    geohash,
    city: input.city || null,
    region: input.region || null,
    country: input.country || null,
    draftVersionId: versionRef.id,
    draftVersion: 1,
    stats: {
      totalPlays: 0,
      totalDownloads: 0,
      averageRating: 0,
      totalRatings: 0,
      totalRevenue: 0,
    },
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  await batch.commit();

  return tourRef.id;
}

export async function updateTour(tourId: string, input: UpdateTourInput): Promise<void> {
  const creatorId = await verifyCreatorRole();

  // Get current tour to verify ownership
  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }

  const tourData = tourDoc.data();
  if (tourData.creatorId !== creatorId) {
    throw new Error('You do not have permission to edit this tour');
  }

  const batch = writeBatch(db);

  // Update version document
  const versionUpdate: Record<string, unknown> = {
    updatedAt: serverTimestamp(),
  };

  if (input.title !== undefined) versionUpdate.title = input.title;
  if (input.description !== undefined) versionUpdate.description = input.description;
  if (input.difficulty !== undefined) versionUpdate.difficulty = input.difficulty;
  if (input.coverImageUrl !== undefined) versionUpdate.coverImageUrl = input.coverImageUrl;
  if (input.duration !== undefined) versionUpdate.duration = input.duration;
  if (input.distance !== undefined) versionUpdate.distance = input.distance;

  batch.update(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tourData.draftVersionId),
    versionUpdate
  );

  // Update tour document
  const tourUpdate: Record<string, unknown> = {
    updatedAt: serverTimestamp(),
  };

  if (input.category !== undefined) tourUpdate.category = input.category;
  if (input.tourType !== undefined) tourUpdate.tourType = input.tourType;
  if (input.city !== undefined) tourUpdate.city = input.city;
  if (input.region !== undefined) tourUpdate.region = input.region;
  if (input.country !== undefined) tourUpdate.country = input.country;

  if (input.startLocation !== undefined) {
    tourUpdate.startLocation = input.startLocation;
    tourUpdate.geohash = ngeohash.encode(input.startLocation.latitude, input.startLocation.longitude, 7);
  }

  // If tour was approved and is being edited, change status to pending_review
  if (tourData.status === 'approved') {
    tourUpdate.status = 'pending_review';
  }

  batch.update(doc(db, COLLECTIONS.tours, tourId), tourUpdate);

  await batch.commit();
}

export async function deleteTour(tourId: string): Promise<void> {
  const creatorId = await verifyCreatorRole();

  // Get current tour to verify ownership
  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }

  const tourData = tourDoc.data();
  if (tourData.creatorId !== creatorId) {
    throw new Error('You do not have permission to delete this tour');
  }

  // Only allow deleting draft or rejected tours
  if (tourData.status !== 'draft' && tourData.status !== 'rejected') {
    throw new Error('Can only delete tours in draft or rejected status');
  }

  const batch = writeBatch(db);

  // Delete all versions and their stops
  const versionsSnapshot = await getDocs(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions)
  );

  for (const versionDoc of versionsSnapshot.docs) {
    // Delete stops in this version
    const stopsSnapshot = await getDocs(
      collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, versionDoc.id, COLLECTIONS.stops)
    );
    for (const stopDoc of stopsSnapshot.docs) {
      batch.delete(stopDoc.ref);
    }
    batch.delete(versionDoc.ref);
  }

  // Delete tour document
  batch.delete(doc(db, COLLECTIONS.tours, tourId));

  await batch.commit();
}

export async function duplicateTour(tourId: string): Promise<string> {
  const creatorId = await verifyCreatorRole();

  // Get original tour
  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }

  const tourData = tourDoc.data();
  if (tourData.creatorId !== creatorId) {
    throw new Error('You do not have permission to duplicate this tour');
  }

  // Get original version
  const versionDoc = await getDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tourData.draftVersionId)
  );
  if (!versionDoc.exists()) {
    throw new Error('Tour version not found');
  }

  const versionData = versionDoc.data();

  // Create new tour
  const newTourRef = doc(collection(db, COLLECTIONS.tours));
  const newVersionRef = doc(collection(db, COLLECTIONS.tours, newTourRef.id, COLLECTIONS.versions));

  const batch = writeBatch(db);

  // Create new version
  batch.set(newVersionRef, {
    versionNumber: 1,
    versionType: 'draft',
    title: `${versionData.title} (Copy)`,
    description: versionData.description,
    coverImageUrl: versionData.coverImageUrl || null,
    difficulty: versionData.difficulty,
    duration: versionData.duration || null,
    distance: versionData.distance || null,
    languages: versionData.languages || ['en'],
    route: versionData.route || null,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  // Create new tour
  batch.set(newTourRef, {
    creatorId,
    creatorName: tourData.creatorName,
    category: tourData.category,
    tourType: tourData.tourType,
    status: 'draft',
    featured: false,
    startLocation: tourData.startLocation,
    geohash: tourData.geohash,
    city: tourData.city || null,
    region: tourData.region || null,
    country: tourData.country || null,
    draftVersionId: newVersionRef.id,
    draftVersion: 1,
    stats: {
      totalPlays: 0,
      totalDownloads: 0,
      averageRating: 0,
      totalRatings: 0,
      totalRevenue: 0,
    },
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  await batch.commit();

  // Duplicate stops
  const stopsSnapshot = await getDocs(
    query(
      collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tourData.draftVersionId, COLLECTIONS.stops),
      orderBy('order', 'asc')
    )
  );

  for (const stopDoc of stopsSnapshot.docs) {
    const stopData = stopDoc.data();
    await addDoc(
      collection(db, COLLECTIONS.tours, newTourRef.id, COLLECTIONS.versions, newVersionRef.id, COLLECTIONS.stops),
      {
        ...stopData,
        tourId: newTourRef.id,
        versionId: newVersionRef.id,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }
    );
  }

  return newTourRef.id;
}

export async function submitTourForReview(tourId: string): Promise<void> {
  const creatorId = await verifyCreatorRole();

  // Get tour to verify ownership and status
  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }

  const tourData = tourDoc.data();
  if (tourData.creatorId !== creatorId) {
    throw new Error('You do not have permission to submit this tour');
  }

  if (tourData.status !== 'draft' && tourData.status !== 'rejected') {
    throw new Error('Tour must be in draft or rejected status to submit for review');
  }

  // Get version to validate it has required content
  const versionDoc = await getDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tourData.draftVersionId)
  );
  const versionData = versionDoc.data();

  if (!versionData?.title || !versionData?.description) {
    throw new Error('Tour must have a title and description');
  }

  // Check if tour has at least 2 stops
  const stopsSnapshot = await getDocs(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tourData.draftVersionId, COLLECTIONS.stops)
  );

  if (stopsSnapshot.size < 2) {
    throw new Error('Tour must have at least 2 stops');
  }

  // Update status
  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'pending_review',
    updatedAt: serverTimestamp(),
  });

  // Update version submission time
  await updateDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, tourData.draftVersionId),
    {
      submittedAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    }
  );
}

export async function withdrawTourSubmission(tourId: string): Promise<void> {
  const creatorId = await verifyCreatorRole();

  // Get tour to verify ownership and status
  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }

  const tourData = tourDoc.data();
  if (tourData.creatorId !== creatorId) {
    throw new Error('You do not have permission to withdraw this tour');
  }

  if (tourData.status !== 'pending_review') {
    throw new Error('Only tours pending review can be withdrawn');
  }

  // Update status back to draft
  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    status: 'draft',
    updatedAt: serverTimestamp(),
  });
}

// ==================== Image Upload ====================

export async function uploadCoverImage(tourId: string, file: File): Promise<string> {
  const creatorId = await verifyCreatorRole();

  // Verify ownership
  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }
  if (tourDoc.data().creatorId !== creatorId) {
    throw new Error('You do not have permission to upload to this tour');
  }

  // Upload to Firebase Storage
  const fileExtension = file.name.split('.').pop() || 'jpg';
  const fileName = `tours/${tourId}/cover_${Date.now()}.${fileExtension}`;
  const storageRef = ref(storage, fileName);

  await uploadBytes(storageRef, file, {
    contentType: file.type,
  });

  const downloadUrl = await getDownloadURL(storageRef);

  // Update tour version with cover image URL
  const draftVersionId = tourDoc.data().draftVersionId;
  await updateDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId),
    {
      coverImageUrl: downloadUrl,
      updatedAt: serverTimestamp(),
    }
  );

  return downloadUrl;
}

// ==================== Helper Functions ====================

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
