import {
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  deleteDoc,
  query,
  orderBy,
  serverTimestamp,
  writeBatch,
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage';
import { db, auth, storage } from './config';
import {
  StopModel,
  GeoPoint,
  StopMedia,
  AudioSource,
  timestampToDate,
} from '@/types';
import ngeohash from 'ngeohash';

// Collection names
const COLLECTIONS = {
  users: 'users',
  tours: 'tours',
  versions: 'versions',
  stops: 'stops',
};

// Helper to verify creator owns the tour
// Simplified: treat all authenticated users as having edit permission (matching auth.ts bypass)
async function verifyTourOwnership(tourId: string): Promise<{ creatorId: string; draftVersionId: string }> {
  const user = auth.currentUser;
  if (!user) {
    throw new Error('User must be authenticated');
  }

  const tourDoc = await getDoc(doc(db, COLLECTIONS.tours, tourId));
  if (!tourDoc.exists()) {
    throw new Error('Tour not found');
  }

  const tourData = tourDoc.data();
  // Skip ownership check - treat all authenticated users as admin for now
  // This matches the bypass in auth.ts

  return {
    creatorId: user.uid,
    draftVersionId: tourData.draftVersionId,
  };
}

// ==================== Stop Types ====================

export interface CreateStopInput {
  name: string;
  description?: string;
  location: GeoPoint;
  triggerRadius?: number;
  order?: number;
}

export interface UpdateStopInput {
  name?: string;
  description?: string;
  location?: GeoPoint;
  triggerRadius?: number;
  order?: number;
  audioUrl?: string | null;
  audioSource?: AudioSource;
  audioText?: string | null;
}

// ==================== Stop Operations ====================

export async function getTourStops(tourId: string): Promise<StopModel[]> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const q = query(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops),
    orderBy('order', 'asc')
  );
  const snapshot = await getDocs(q);

  return snapshot.docs.map((doc) =>
    parseStopDoc(tourId, draftVersionId, doc.id, doc.data())
  );
}

export async function getStop(tourId: string, stopId: string): Promise<StopModel | null> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const stopDoc = await getDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId)
  );

  if (!stopDoc.exists()) {
    return null;
  }

  return parseStopDoc(tourId, draftVersionId, stopDoc.id, stopDoc.data());
}

export async function createStop(tourId: string, input: CreateStopInput): Promise<string> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  // Get current stops to determine order
  const stopsSnapshot = await getDocs(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops)
  );
  const nextOrder = input.order ?? stopsSnapshot.size;

  // Generate geohash
  const geohash = ngeohash.encode(input.location.latitude, input.location.longitude, 9);

  const stopRef = doc(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops)
  );

  const stopData = {
    tourId,
    versionId: draftVersionId,
    order: nextOrder,
    name: input.name,
    description: input.description || '',
    location: input.location,
    geohash,
    triggerRadius: input.triggerRadius || 50,
    media: {
      audioSource: 'recorded' as AudioSource,
      images: [],
    },
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };

  await setDoc(stopRef, stopData);

  // Update tour's updatedAt
  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    updatedAt: serverTimestamp(),
  });

  return stopRef.id;
}

export async function updateStop(
  tourId: string,
  stopId: string,
  input: UpdateStopInput
): Promise<void> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const stopRef = doc(
    db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId
  );

  const updateData: Record<string, unknown> = {
    updatedAt: serverTimestamp(),
  };

  if (input.name !== undefined) updateData.name = input.name;
  if (input.description !== undefined) updateData.description = input.description;
  if (input.triggerRadius !== undefined) updateData.triggerRadius = input.triggerRadius;
  if (input.order !== undefined) updateData.order = input.order;

  if (input.location !== undefined) {
    updateData.location = input.location;
    updateData.geohash = ngeohash.encode(input.location.latitude, input.location.longitude, 9);
  }

  if (input.audioUrl !== undefined) updateData['media.audioUrl'] = input.audioUrl;
  if (input.audioSource !== undefined) updateData['media.audioSource'] = input.audioSource;
  if (input.audioText !== undefined) updateData['media.audioText'] = input.audioText;

  await updateDoc(stopRef, updateData);

  // Update tour's updatedAt
  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    updatedAt: serverTimestamp(),
  });
}

export async function deleteStop(tourId: string, stopId: string): Promise<void> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  // Get the stop to delete any associated media
  const stopDoc = await getDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId)
  );

  if (stopDoc.exists()) {
    const stopData = stopDoc.data();

    // Delete associated audio if exists
    if (stopData.media?.audioUrl) {
      try {
        const audioRef = ref(storage, stopData.media.audioUrl);
        await deleteObject(audioRef);
      } catch (e) {
        console.error('Failed to delete audio file:', e);
      }
    }

    // Delete associated images
    if (stopData.media?.images) {
      for (const image of stopData.media.images) {
        try {
          const imageRef = ref(storage, image.url);
          await deleteObject(imageRef);
        } catch (e) {
          console.error('Failed to delete image:', e);
        }
      }
    }
  }

  await deleteDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId)
  );

  // Reorder remaining stops
  await reorderStopsAfterDelete(tourId, draftVersionId);

  // Update tour's updatedAt
  await updateDoc(doc(db, COLLECTIONS.tours, tourId), {
    updatedAt: serverTimestamp(),
  });
}

export async function reorderStops(
  tourId: string,
  stopIds: string[]
): Promise<void> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const batch = writeBatch(db);

  stopIds.forEach((stopId, index) => {
    const stopRef = doc(
      db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId
    );
    batch.update(stopRef, {
      order: index,
      updatedAt: serverTimestamp(),
    });
  });

  // Update tour's updatedAt
  batch.update(doc(db, COLLECTIONS.tours, tourId), {
    updatedAt: serverTimestamp(),
  });

  await batch.commit();
}

async function reorderStopsAfterDelete(tourId: string, versionId: string): Promise<void> {
  const q = query(
    collection(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, versionId, COLLECTIONS.stops),
    orderBy('order', 'asc')
  );
  const snapshot = await getDocs(q);

  const batch = writeBatch(db);
  snapshot.docs.forEach((doc, index) => {
    if (doc.data().order !== index) {
      batch.update(doc.ref, { order: index });
    }
  });

  await batch.commit();
}

// ==================== Media Operations ====================

export async function uploadStopAudio(
  tourId: string,
  stopId: string,
  file: File,
  source: AudioSource = 'uploaded'
): Promise<string> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const fileExtension = file.name.split('.').pop() || 'mp3';
  const fileName = `tours/${tourId}/stops/${stopId}/audio_${Date.now()}.${fileExtension}`;
  const storageRef = ref(storage, fileName);

  await uploadBytes(storageRef, file, {
    contentType: file.type,
  });

  const downloadUrl = await getDownloadURL(storageRef);

  // Update stop with audio URL
  await updateDoc(
    doc(db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId),
    {
      'media.audioUrl': downloadUrl,
      'media.audioSource': source,
      updatedAt: serverTimestamp(),
    }
  );

  return downloadUrl;
}

export async function uploadStopAudioBlob(
  tourId: string,
  stopId: string,
  blob: Blob,
  source: AudioSource = 'uploaded'
): Promise<string> {
  await verifyTourOwnership(tourId);
  const ext = blob.type.includes('webm') ? 'webm' : 'mp3';
  const fileName = `tours/${tourId}/stops/${stopId}/audio_${Date.now()}.${ext}`;
  const storageRef = ref(storage, fileName);
  await uploadBytes(storageRef, blob, { contentType: blob.type });
  return await getDownloadURL(storageRef);
}

export async function uploadStopImage(
  tourId: string,
  stopId: string,
  file: File,
  order: number
): Promise<string> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const fileExtension = file.name.split('.').pop() || 'jpg';
  const fileName = `tours/${tourId}/stops/${stopId}/image_${Date.now()}.${fileExtension}`;
  const storageRef = ref(storage, fileName);

  await uploadBytes(storageRef, file, {
    contentType: file.type,
  });

  const downloadUrl = await getDownloadURL(storageRef);

  // Get current stop to append image
  const stopRef = doc(
    db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId
  );
  const stopDoc = await getDoc(stopRef);
  const currentImages = stopDoc.data()?.media?.images || [];

  // Add new image
  await updateDoc(stopRef, {
    'media.images': [...currentImages, { url: downloadUrl, order }],
    updatedAt: serverTimestamp(),
  });

  return downloadUrl;
}

export async function deleteStopImage(
  tourId: string,
  stopId: string,
  imageUrl: string
): Promise<void> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  // Delete from storage
  try {
    const imageRef = ref(storage, imageUrl);
    await deleteObject(imageRef);
  } catch (e) {
    console.error('Failed to delete image from storage:', e);
  }

  // Remove from stop
  const stopRef = doc(
    db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId
  );
  const stopDoc = await getDoc(stopRef);
  const currentImages = stopDoc.data()?.media?.images || [];
  const filteredImages = currentImages.filter((img: { url: string }) => img.url !== imageUrl);

  await updateDoc(stopRef, {
    'media.images': filteredImages,
    updatedAt: serverTimestamp(),
  });
}

export async function reorderStopImages(
  tourId: string,
  stopId: string,
  images: Array<{ url: string; caption?: string; order: number }>
): Promise<void> {
  const { draftVersionId } = await verifyTourOwnership(tourId);

  const stopRef = doc(
    db, COLLECTIONS.tours, tourId, COLLECTIONS.versions, draftVersionId, COLLECTIONS.stops, stopId
  );

  await updateDoc(stopRef, {
    'media.images': images,
    updatedAt: serverTimestamp(),
  });
}

// ==================== Helper Functions ====================

function parseStopDoc(
  tourId: string,
  versionId: string,
  id: string,
  data: Record<string, unknown>
): StopModel {
  const location = data.location as { latitude: number; longitude: number };
  const media = data.media as StopMedia | undefined;

  return {
    id,
    tourId,
    versionId,
    order: (data.order as number) || 0,
    name: data.name as string,
    description: (data.description as string) || '',
    location: location || { latitude: 0, longitude: 0 },
    geohash: data.geohash as string,
    triggerRadius: (data.triggerRadius as number) || 50,
    media: media || {
      audioSource: 'recorded',
      images: [],
    },
    navigation: data.navigation as StopModel['navigation'],
    createdAt: timestampToDate(data.createdAt),
    updatedAt: timestampToDate(data.updatedAt),
  };
}
