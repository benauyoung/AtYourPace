const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createTestTour() {
  const now = admin.firestore.Timestamp.now();

  // Tour ID and Version ID
  const tourId = 'test-tour-001';
  const versionId = 'v1';

  // Create the tour document
  const tourData = {
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
  };

  // Create the version document
  const versionData = {
    versionNumber: 1,
    versionType: 'live',
    title: 'Downtown San Francisco Walking Tour',
    description: 'Explore the historic heart of San Francisco! This walking tour takes you through iconic landmarks, hidden gems, and fascinating stories of the city by the bay. Perfect for first-time visitors and locals alike.',
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
        { lat: 37.7855, lng: -122.4064 }
      ]
    },
    createdAt: now,
    updatedAt: now
  };

  // Create stop documents
  const stops = [
    {
      order: 0,
      name: 'Union Square',
      description: 'The heart of downtown San Francisco, Union Square has been a gathering place since 1850. Named for pro-Union Civil War rallies held here.',
      location: new admin.firestore.GeoPoint(37.7879, -122.4074),
      geohash: '9q8yyk',
      triggerRadius: 50,
      media: {
        audioUrl: null,
        audioSource: 'recorded',
        audioDuration: null,
        audioText: 'Welcome to Union Square, the vibrant heart of downtown San Francisco. This iconic plaza has been the city\'s premier shopping and cultural destination for over 150 years.',
        images: []
      },
      createdAt: now,
      updatedAt: now
    },
    {
      order: 1,
      name: 'Chinatown Gate',
      description: 'The famous Dragon Gate marks the entrance to the oldest Chinatown in North America and the largest Chinatown outside of Asia.',
      location: new admin.firestore.GeoPoint(37.7907, -122.4058),
      geohash: '9q8yym',
      triggerRadius: 40,
      media: {
        audioUrl: null,
        audioSource: 'recorded',
        audioDuration: null,
        audioText: 'You\'re now approaching the iconic Dragon Gate, the grand entrance to San Francisco\'s Chinatown. Established in 1848, this is the oldest Chinatown in North America.',
        images: []
      },
      createdAt: now,
      updatedAt: now
    },
    {
      order: 2,
      name: 'Transamerica Pyramid',
      description: 'This distinctive 48-story tower was the tallest building in San Francisco from 1972 to 2017 and remains the city\'s most recognizable landmark.',
      location: new admin.firestore.GeoPoint(37.7952, -122.4028),
      geohash: '9q8yyr',
      triggerRadius: 60,
      media: {
        audioUrl: null,
        audioSource: 'recorded',
        audioDuration: null,
        audioText: 'Look up! The Transamerica Pyramid soars 853 feet into the San Francisco sky. When it was completed in 1972, many San Franciscans were skeptical of its unusual shape.',
        images: []
      },
      createdAt: now,
      updatedAt: now
    }
  ];

  try {
    // Create tour document
    await db.collection('tours').doc(tourId).set(tourData);
    console.log('Created tour document:', tourId);

    // Create version document
    await db.collection('tours').doc(tourId).collection('versions').doc(versionId).set(versionData);
    console.log('Created version document:', versionId);

    // Create stop documents
    for (const stop of stops) {
      const stopRef = db.collection('tours').doc(tourId).collection('versions').doc(versionId).collection('stops').doc();
      await stopRef.set({
        ...stop,
        tourId: tourId,
        versionId: versionId
      });
      console.log('Created stop:', stop.name);
    }

    console.log('\nTest tour created successfully!');
    console.log('Tour ID:', tourId);
    console.log('Location: San Francisco, CA');
    console.log('Stops:', stops.length);

  } catch (error) {
    console.error('Error creating test tour:', error);
  }

  process.exit(0);
}

createTestTour();
