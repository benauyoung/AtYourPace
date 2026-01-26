import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

/**
 * Temporary function to seed test data
 * Call via: curl https://us-central1-atyourpace-6a6e5.cloudfunctions.net/seedTestTour
 */
export const seedTestTour = functions.https.onRequest(async (req, res) => {
  try {
    const now = admin.firestore.Timestamp.now();
    const tourId = 'test-tour-001';
    const versionId = 'v1';

    // Check if tour already exists
    const existingTour = await db.collection('tours').doc(tourId).get();
    if (existingTour.exists) {
      res.status(200).json({ message: 'Test tour already exists', tourId });
      return;
    }

    // Create the tour document
    await db.collection('tours').doc(tourId).set({
      creatorId: 'test-creator',
      creatorName: 'Test Creator',
      slug: 'downtown-sf-walking-tour',
      category: 'history',
      tourType: 'walking',
      status: 'approved',
      featured: true,
      startLocation: new admin.firestore.GeoPoint(37.7749, -122.4194),
      geohash: '9q8yy',
      city: 'San Francisco',
      region: 'California',
      country: 'United States',
      liveVersionId: versionId,
      liveVersion: 1,
      draftVersionId: versionId,
      draftVersion: 1,
      stats: {
        totalPlays: 150,
        totalDownloads: 75,
        averageRating: 4.5,
        totalRatings: 25,
        totalRevenue: 0
      },
      createdAt: now,
      updatedAt: now,
      publishedAt: now
    });

    // Create the version document
    await db.collection('tours').doc(tourId).collection('versions').doc(versionId).set({
      versionNumber: 1,
      versionType: 'live',
      title: 'Downtown San Francisco Walking Tour',
      description: 'Explore the historic heart of San Francisco! This walking tour takes you through iconic landmarks, hidden gems, and fascinating stories of the city by the bay.',
      coverImageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800',
      duration: '1.5 hours',
      distance: '2.5 miles',
      difficulty: 'easy',
      languages: ['en'],
      route: {
        encodedPolyline: null,
        boundingBox: {
          northeast: { latitude: 37.7899, longitude: -122.4044 },
          southwest: { latitude: 37.7649, longitude: -122.4344 }
        },
        waypoints: [
          { lat: 37.7749, lng: -122.4194 },
          { lat: 37.7879, lng: -122.4074 },
          { lat: 37.7952, lng: -122.4028 }
        ]
      },
      createdAt: now,
      updatedAt: now
    });

    // Create stop documents
    const stops = [
      {
        order: 0,
        name: 'Union Square',
        description: 'The heart of downtown San Francisco, Union Square has been a gathering place since 1850.',
        location: new admin.firestore.GeoPoint(37.7879, -122.4074),
        geohash: '9q8yyk',
        triggerRadius: 50,
        media: {
          audioUrl: null,
          audioSource: 'recorded',
          audioDuration: null,
          audioText: 'Welcome to Union Square, the vibrant heart of downtown San Francisco.',
          images: []
        }
      },
      {
        order: 1,
        name: 'Chinatown Gate',
        description: 'The famous Dragon Gate marks the entrance to the oldest Chinatown in North America.',
        location: new admin.firestore.GeoPoint(37.7907, -122.4058),
        geohash: '9q8yym',
        triggerRadius: 40,
        media: {
          audioUrl: null,
          audioSource: 'recorded',
          audioDuration: null,
          audioText: 'You are now approaching the iconic Dragon Gate.',
          images: []
        }
      },
      {
        order: 2,
        name: 'Transamerica Pyramid',
        description: 'This distinctive 48-story tower remains the city\'s most recognizable landmark.',
        location: new admin.firestore.GeoPoint(37.7952, -122.4028),
        geohash: '9q8yyr',
        triggerRadius: 60,
        media: {
          audioUrl: null,
          audioSource: 'recorded',
          audioDuration: null,
          audioText: 'Look up! The Transamerica Pyramid soars 853 feet into the sky.',
          images: []
        }
      }
    ];

    const stopsCollection = db.collection('tours').doc(tourId)
      .collection('versions').doc(versionId).collection('stops');

    for (const stop of stops) {
      await stopsCollection.add({
        ...stop,
        createdAt: now,
        updatedAt: now
      });
    }

    res.status(200).json({
      message: 'Test tour created successfully',
      tourId,
      versionId,
      stopsCount: stops.length
    });

  } catch (error) {
    console.error('Error creating test tour:', error);
    res.status(500).json({ error: 'Failed to create test tour', details: String(error) });
  }
});
