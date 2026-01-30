import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Analytics period types
 */
type AnalyticsPeriod = 'day' | 'week' | 'month' | 'quarter' | 'year' | 'all_time';

/**
 * Scheduled function to aggregate tour analytics.
 * Runs every hour to update daily, weekly, and monthly analytics.
 */
export const aggregateTourAnalytics = functions.pubsub
  .schedule('0 * * * *') // Every hour
  .timeZone('UTC')
  .onRun(async (context) => {
    functions.logger.info('Starting scheduled analytics aggregation');

    try {
      // Get all approved tours
      const toursSnapshot = await db
        .collection('tours')
        .where('status', '==', 'approved')
        .get();

      functions.logger.info(`Processing analytics for ${toursSnapshot.size} tours`);

      const promises = toursSnapshot.docs.map(async (tourDoc) => {
        const tourId = tourDoc.id;
        try {
          await aggregateTourPeriods(tourId);
        } catch (error) {
          functions.logger.error(`Error aggregating analytics for tour ${tourId}:`, error);
        }
      });

      await Promise.all(promises);

      functions.logger.info('Scheduled analytics aggregation completed');
    } catch (error) {
      functions.logger.error('Error in scheduled analytics aggregation:', error);
      throw error;
    }
  });

/**
 * Aggregates analytics for a single tour across all periods.
 */
async function aggregateTourPeriods(tourId: string): Promise<void> {
  const periods: AnalyticsPeriod[] = ['day', 'week', 'month'];

  for (const period of periods) {
    await aggregateAnalyticsForPeriod(tourId, period);
  }
}

/**
 * Aggregates analytics for a specific period.
 */
async function aggregateAnalyticsForPeriod(tourId: string, period: AnalyticsPeriod): Promise<void> {
  const { startDate, endDate, periodId } = getPeriodDates(period);

  // Fetch play events
  const playsSnapshot = await db
    .collectionGroup('tourProgress')
    .where('tourId', '==', tourId)
    .where('startedAt', '>=', admin.firestore.Timestamp.fromDate(startDate))
    .where('startedAt', '<=', admin.firestore.Timestamp.fromDate(endDate))
    .get();

  // Fetch download events
  const downloadsSnapshot = await db
    .collectionGroup('downloads')
    .where('tourId', '==', tourId)
    .where('downloadedAt', '>=', admin.firestore.Timestamp.fromDate(startDate))
    .where('downloadedAt', '<=', admin.firestore.Timestamp.fromDate(endDate))
    .get();

  // Fetch favorites count
  const favoritesSnapshot = await db
    .collectionGroup('favorites')
    .where('tourId', '==', tourId)
    .get();

  // Fetch reviews
  const reviewsSnapshot = await db
    .collection('tours')
    .doc(tourId)
    .collection('reviews')
    .get();

  // Calculate metrics
  const playMetrics = calculatePlayMetrics(playsSnapshot.docs);
  const downloadMetrics = calculateDownloadMetrics(downloadsSnapshot.docs);
  const favoriteMetrics = { total: favoritesSnapshot.size, changeFromPrevious: 0 };
  const feedbackMetrics = calculateFeedbackMetrics(reviewsSnapshot.docs);
  const completionMetrics = calculateCompletionMetrics(playsSnapshot.docs);
  const geographicMetrics = calculateGeographicMetrics(playsSnapshot.docs);
  const timeSeriesData = calculateTimeSeries(playsSnapshot.docs, downloadsSnapshot.docs, startDate, endDate);

  // Store aggregated analytics
  const analyticsRef = db
    .collection('analytics')
    .doc(tourId)
    .collection('periods')
    .doc(periodId);

  await analyticsRef.set({
    tourId,
    period,
    startDate: admin.firestore.Timestamp.fromDate(startDate),
    endDate: admin.firestore.Timestamp.fromDate(endDate),
    plays: playMetrics,
    downloads: downloadMetrics,
    favorites: favoriteMetrics,
    revenue: {
      total: 0,
      transactions: 0,
      averageTransaction: 0,
      byPricingTier: {},
      changeFromPrevious: 0,
    },
    completion: completionMetrics,
    geographic: geographicMetrics,
    timeSeries: timeSeriesData,
    feedback: feedbackMetrics,
    generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    cachedUntil: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 5 * 60 * 1000) // 5 minutes cache
    ),
  }, { merge: true });
}

/**
 * Gets the date range and period ID for a given period.
 */
function getPeriodDates(period: AnalyticsPeriod): {
  startDate: Date;
  endDate: Date;
  periodId: string;
} {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  let startDate: Date;
  let periodId: string;

  switch (period) {
    case 'day':
      startDate = today;
      periodId = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
      break;
    case 'week':
      const dayOfWeek = today.getDay();
      startDate = new Date(today);
      startDate.setDate(today.getDate() - dayOfWeek);
      periodId = `week-${startDate.getFullYear()}-${String(startDate.getMonth() + 1).padStart(2, '0')}-${String(startDate.getDate()).padStart(2, '0')}`;
      break;
    case 'month':
      startDate = new Date(today.getFullYear(), today.getMonth(), 1);
      periodId = `month-${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}`;
      break;
    case 'quarter':
      const quarter = Math.floor(today.getMonth() / 3);
      startDate = new Date(today.getFullYear(), quarter * 3, 1);
      periodId = `quarter-${today.getFullYear()}-Q${quarter + 1}`;
      break;
    case 'year':
      startDate = new Date(today.getFullYear(), 0, 1);
      periodId = `year-${today.getFullYear()}`;
      break;
    case 'all_time':
    default:
      startDate = new Date(2020, 0, 1);
      periodId = 'all-time';
  }

  return { startDate, endDate: now, periodId };
}

/**
 * Calculate play metrics from progress documents.
 */
function calculatePlayMetrics(docs: FirebaseFirestore.QueryDocumentSnapshot[]): object {
  if (docs.length === 0) {
    return {
      total: 0,
      unique: 0,
      averageDuration: 0,
      completions: 0,
      completionRate: 0,
      changeFromPrevious: 0,
    };
  }

  const uniqueUsers = new Set(docs.map(d => d.data().userId));
  const completedPlays = docs.filter(d => d.data().completed === true);

  let totalDuration = 0;
  docs.forEach(d => {
    const duration = d.data().duration;
    if (typeof duration === 'number') {
      totalDuration += duration;
    }
  });

  return {
    total: docs.length,
    unique: uniqueUsers.size,
    averageDuration: docs.length > 0 ? totalDuration / docs.length : 0,
    completions: completedPlays.length,
    completionRate: docs.length > 0 ? completedPlays.length / docs.length : 0,
    changeFromPrevious: 0,
  };
}

/**
 * Calculate download metrics from download documents.
 */
function calculateDownloadMetrics(docs: FirebaseFirestore.QueryDocumentSnapshot[]): object {
  if (docs.length === 0) {
    return {
      total: 0,
      unique: 0,
      storageUsed: 0,
      changeFromPrevious: 0,
    };
  }

  const uniqueUsers = new Set(docs.map(d => d.data().userId));

  let totalStorage = 0;
  docs.forEach(d => {
    const size = d.data().sizeBytes;
    if (typeof size === 'number') {
      totalStorage += size / 1024; // Convert to KB
    }
  });

  return {
    total: docs.length,
    unique: uniqueUsers.size,
    storageUsed: totalStorage,
    changeFromPrevious: 0,
  };
}

/**
 * Calculate feedback metrics from review documents.
 */
function calculateFeedbackMetrics(docs: FirebaseFirestore.QueryDocumentSnapshot[]): object {
  if (docs.length === 0) {
    return {
      averageRating: 0,
      totalReviews: 0,
      ratingDistribution: {},
    };
  }

  const ratingDistribution: { [key: number]: number } = {};
  let totalRating = 0;

  docs.forEach(d => {
    const rating = d.data().rating;
    if (typeof rating === 'number') {
      totalRating += rating;
      ratingDistribution[rating] = (ratingDistribution[rating] || 0) + 1;
    }
  });

  return {
    averageRating: docs.length > 0 ? totalRating / docs.length : 0,
    totalReviews: docs.length,
    ratingDistribution,
  };
}

/**
 * Calculate completion metrics from progress documents.
 */
function calculateCompletionMetrics(docs: FirebaseFirestore.QueryDocumentSnapshot[]): object {
  if (docs.length === 0) {
    return {
      completionRate: 0,
      dropOffByStop: {},
      averageCompletionTime: 0,
    };
  }

  const completedPlays = docs.filter(d => d.data().completed === true);
  const dropOffByStop: { [key: number]: number } = {};

  docs.forEach(d => {
    const data = d.data();
    if (data.completed !== true && typeof data.lastStopIndex === 'number') {
      dropOffByStop[data.lastStopIndex] = (dropOffByStop[data.lastStopIndex] || 0) + 1;
    }
  });

  let totalCompletionTime = 0;
  let completionCount = 0;

  completedPlays.forEach(d => {
    const duration = d.data().duration;
    if (typeof duration === 'number') {
      totalCompletionTime += duration;
      completionCount++;
    }
  });

  return {
    completionRate: docs.length > 0 ? completedPlays.length / docs.length : 0,
    dropOffByStop,
    averageCompletionTime: completionCount > 0 ? totalCompletionTime / completionCount : 0,
  };
}

/**
 * Calculate geographic metrics from progress documents.
 */
function calculateGeographicMetrics(docs: FirebaseFirestore.QueryDocumentSnapshot[]): object {
  const byCity: { [key: string]: number } = {};
  const byCountry: { [key: string]: number } = {};

  docs.forEach(d => {
    const data = d.data();
    const city = data.city;
    const country = data.country;

    if (typeof city === 'string') {
      byCity[city] = (byCity[city] || 0) + 1;
    }
    if (typeof country === 'string') {
      byCountry[country] = (byCountry[country] || 0) + 1;
    }
  });

  return { byCity, byCountry };
}

/**
 * Calculate time series data from events.
 */
function calculateTimeSeries(
  playDocs: FirebaseFirestore.QueryDocumentSnapshot[],
  downloadDocs: FirebaseFirestore.QueryDocumentSnapshot[],
  startDate: Date,
  endDate: Date
): object {
  const playsByDate: { [key: string]: number } = {};
  const downloadsByDate: { [key: string]: number } = {};

  playDocs.forEach(d => {
    const timestamp = d.data().startedAt;
    if (timestamp) {
      const date = timestamp.toDate();
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
      playsByDate[key] = (playsByDate[key] || 0) + 1;
    }
  });

  downloadDocs.forEach(d => {
    const timestamp = d.data().downloadedAt;
    if (timestamp) {
      const date = timestamp.toDate();
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
      downloadsByDate[key] = (downloadsByDate[key] || 0) + 1;
    }
  });

  const plays = Object.entries(playsByDate)
    .map(([date, value]) => ({ date, value }))
    .sort((a, b) => a.date.localeCompare(b.date));

  const downloads = Object.entries(downloadsByDate)
    .map(([date, value]) => ({ date, value }))
    .sort((a, b) => a.date.localeCompare(b.date));

  return { plays, downloads, favorites: [] };
}

/**
 * HTTP callable function to manually trigger analytics aggregation for a tour.
 */
export const triggerTourAnalytics = functions.https.onCall(async (data, context) => {
  // Verify admin permissions
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const userData = userDoc.data();

  if (userData?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin permission required');
  }

  const { tourId } = data;
  if (!tourId) {
    throw new functions.https.HttpsError('invalid-argument', 'tourId is required');
  }

  functions.logger.info(`Manual analytics aggregation triggered for tour ${tourId}`);

  try {
    await aggregateTourPeriods(tourId);
    return { success: true, message: `Analytics aggregated for tour ${tourId}` };
  } catch (error) {
    functions.logger.error(`Error in manual analytics aggregation:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to aggregate analytics');
  }
});

/**
 * Triggered when tour progress is recorded.
 * Increments analytics counters in real-time.
 */
export const onTourProgressCreated = functions.firestore
  .document('{collection}/{docId}/tourProgress/{progressId}')
  .onCreate(async (snapshot, context) => {
    const progress = snapshot.data();
    const tourId = progress.tourId;

    if (!tourId) return;

    const periodId = getCurrentDayPeriodId();
    const analyticsRef = db
      .collection('analytics')
      .doc(tourId)
      .collection('periods')
      .doc(periodId);

    // Increment play count
    await analyticsRef.set({
      'plays.total': admin.firestore.FieldValue.increment(1),
    }, { merge: true });

    functions.logger.info(`Incremented play count for tour ${tourId}`);
  });

/**
 * Triggered when tour progress is updated (e.g., completed).
 */
export const onTourProgressUpdated = functions.firestore
  .document('{collection}/{docId}/tourProgress/{progressId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const tourId = after.tourId;

    if (!tourId) return;

    // Check if tour was just completed
    if (!before.completed && after.completed) {
      const periodId = getCurrentDayPeriodId();
      const analyticsRef = db
        .collection('analytics')
        .doc(tourId)
        .collection('periods')
        .doc(periodId);

      await analyticsRef.set({
        'plays.completions': admin.firestore.FieldValue.increment(1),
      }, { merge: true });

      functions.logger.info(`Incremented completion count for tour ${tourId}`);
    }
  });

/**
 * Gets the current day's period ID.
 */
function getCurrentDayPeriodId(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
}
