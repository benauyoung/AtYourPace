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

    // Sample audio URLs (public domain speech samples from LibriVox / Internet Archive)
    const sampleAudioUrls = [
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ];

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
          audioUrl: sampleAudioUrls[0],
          audioSource: 'recorded',
          audioDuration: 60,
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
          audioUrl: sampleAudioUrls[1],
          audioSource: 'recorded',
          audioDuration: 45,
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
          audioUrl: sampleAudioUrls[2],
          audioSource: 'recorded',
          audioDuration: 50,
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

/**
 * Seed Clamart, France walking tour for European testing
 * Call via: curl https://us-central1-atyourpace-6a6e5.cloudfunctions.net/seedClamartTour
 */
export const seedClamartTour = functions.https.onRequest(async (req, res) => {
  try {
    const now = admin.firestore.Timestamp.now();
    const tourId = 'clamart-historic-tour';
    const versionId = 'v1';

    // Check if tour already exists
    const existingTour = await db.collection('tours').doc(tourId).get();
    if (existingTour.exists) {
      res.status(200).json({ message: 'Clamart tour already exists', tourId });
      return;
    }

    // Create the tour document
    await db.collection('tours').doc(tourId).set({
      creatorId: 'demo-user-001',
      creatorName: 'Demo Guide',
      slug: 'clamart-historic-walking-tour',
      category: 'history',
      tourType: 'walking',
      status: 'approved',
      featured: true,
      startLocation: new admin.firestore.GeoPoint(48.8005, 2.2645),
      geohash: 'u09tun',
      city: 'Clamart',
      region: 'Ile-de-France',
      country: 'France',
      liveVersionId: versionId,
      liveVersion: 1,
      draftVersionId: versionId,
      draftVersion: 1,
      stats: {
        totalPlays: 342,
        totalDownloads: 187,
        averageRating: 4.6,
        totalRatings: 45,
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
      title: 'Historic Clamart Walking Tour',
      description: "Discover the charming town of Clamart, a hidden gem in the southwestern suburbs of Paris. This walking tour takes you through the historic center, featuring a 17th-century chateau turned town hall, a neo-Greek fountain, a medieval church, and a beautiful 19th-century park.",
      coverImageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      duration: '1.5 hours',
      distance: '2.0 km',
      difficulty: 'easy',
      languages: ['en', 'fr'],
      route: {
        encodedPolyline: 'gfqiHcxhM_@dAiBrCkAnB',
        boundingBox: {
          northeast: { latitude: 48.8035, longitude: 2.2690 },
          southwest: { latitude: 48.8000, longitude: 2.2630 }
        },
        waypoints: [
          { lat: 48.8005, lng: 2.2645 },
          { lat: 48.8024, lng: 2.2636 },
          { lat: 48.8026, lng: 2.2640 },
          { lat: 48.8010, lng: 2.2652 },
          { lat: 48.8030, lng: 2.2678 }
        ]
      },
      createdAt: now,
      updatedAt: now
    });

    // Sample audio URLs for testing
    const clamartAudioUrls = [
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    ];

    // Create stop documents
    const stops = [
      {
        order: 0,
        name: 'Avenue Jean Jaures - Start Point',
        description: "Begin your walk at Avenue Jean Jaures, one of Clamart's main arteries named after the famous French socialist leader.",
        location: new admin.firestore.GeoPoint(48.8005, 2.2645),
        geohash: 'u09tun',
        triggerRadius: 30,
        media: {
          audioUrl: clamartAudioUrls[0],
          audioSource: 'elevenlabs',
          audioDuration: 90,
          audioText: "Bienvenue a Clamart! Welcome to our historic walking tour. You are standing on Avenue Jean Jaures, named after the beloved French socialist leader. Clamart has a rich history dating back to prehistoric times. Fun fact: any dish served 'a la Clamart' features peas, as Clamart's peas were the first of the season to reach Paris markets.",
          images: []
        }
      },
      {
        order: 1,
        name: 'Hotel de Ville (Town Hall)',
        description: 'The magnificent Clamart Town Hall is housed in the former Chateau de Barral, a stunning 17th-century neoclassical building.',
        location: new admin.firestore.GeoPoint(48.8024, 2.2636),
        geohash: 'u09tup',
        triggerRadius: 35,
        media: {
          audioUrl: clamartAudioUrls[1],
          audioSource: 'elevenlabs',
          audioDuration: 120,
          audioText: "Before you stands the Hotel de Ville, Clamart's town hall. This is the former Chateau de Barral, built in the 17th century in the neoclassical style. The building became a monument historique in 1929.",
          images: []
        }
      },
      {
        order: 2,
        name: 'Fontaine Thurotte',
        description: "This charming neo-Greek style fountain was installed in 1943, depicting a young shepherd playing the flute near his goat.",
        location: new admin.firestore.GeoPoint(48.8026, 2.2640),
        geohash: 'u09tup',
        triggerRadius: 25,
        media: {
          audioUrl: clamartAudioUrls[2],
          audioSource: 'elevenlabs',
          audioDuration: 100,
          audioText: "The enchanting Fontaine Thurotte was installed in 1943. The sculptor drew inspiration from Paul Landowski, famous for creating the Christ the Redeemer statue in Rio de Janeiro. This was Clamart's first public art acquisition.",
          images: []
        }
      },
      {
        order: 3,
        name: 'Eglise Saint-Pierre Saint-Paul',
        description: "This historic church has roots in the 11th century. Rebuilt after the Hundred Years' War and consecrated in 1523.",
        location: new admin.firestore.GeoPoint(48.8010, 2.2652),
        geohash: 'u09tun',
        triggerRadius: 35,
        media: {
          audioUrl: clamartAudioUrls[3],
          audioSource: 'elevenlabs',
          audioDuration: 130,
          audioText: "The Eglise Saint-Pierre Saint-Paul has a bell tower base dating to the 11th century. The church was consecrated in 1523 after the Hundred Years' War. Inside you'll find the Saint Vincent chapel - patron saint of winegrowers, a reminder of Clamart's viticultural past.",
          images: []
        }
      },
      {
        order: 4,
        name: 'Parc de la Maison Blanche',
        description: 'End your tour at this beautiful 3.7-acre park designed in the 1830s, formerly owned by the Duchess of Galliera.',
        location: new admin.firestore.GeoPoint(48.8030, 2.2678),
        geohash: 'u09tuq',
        triggerRadius: 40,
        media: {
          audioUrl: clamartAudioUrls[4],
          audioSource: 'elevenlabs',
          audioDuration: 110,
          audioText: "We conclude at the Parc de la Maison Blanche, designed in the 1830s. The elegant mansion now serves as a cultural center. Clamart has been home to many artists - Henri Matisse lived here before World War I, and Jean Arp resided here in the 1930s. Merci et au revoir!",
          images: []
        }
      }
    ];

    const stopsCollection = db.collection('tours').doc(tourId)
      .collection('versions').doc(versionId).collection('stops');

    for (const stop of stops) {
      await stopsCollection.add({
        ...stop,
        tourId,
        versionId,
        createdAt: now,
        updatedAt: now
      });
    }

    res.status(200).json({
      message: 'Clamart tour created successfully!',
      tourId,
      versionId,
      location: 'Clamart, France (92140)',
      startPoint: '23 Avenue Jean Jaures',
      stopsCount: stops.length,
      stops: stops.map(s => s.name)
    });

  } catch (error) {
    console.error('Error creating Clamart tour:', error);
    res.status(500).json({ error: 'Failed to create Clamart tour', details: String(error) });
  }
});
