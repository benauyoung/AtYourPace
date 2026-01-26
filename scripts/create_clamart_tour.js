const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createClamartTour() {
  const now = admin.firestore.Timestamp.now();

  // Tour ID and Version ID
  const tourId = 'clamart-historic-tour';
  const versionId = 'v1';

  // Check if tour already exists
  const existingTour = await db.collection('tours').doc(tourId).get();
  if (existingTour.exists) {
    console.log('Clamart tour already exists, skipping creation.');
    process.exit(0);
  }

  // Create the tour document
  const tourData = {
    creatorId: 'demo-user-001',
    creatorName: 'Demo Guide',
    slug: 'clamart-historic-walking-tour',
    category: 'history',
    tourType: 'walking',
    status: 'approved',
    featured: true,
    startLocation: new admin.firestore.GeoPoint(48.8005, 2.2645), // 23 Avenue Jean Jaures
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
  };

  // Create the version document
  const versionData = {
    versionNumber: 1,
    versionType: 'live',
    title: 'Historic Clamart Walking Tour',
    description: "Discover the charming town of Clamart, a hidden gem in the southwestern suburbs of Paris. This walking tour takes you through the historic center, featuring a 17th-century chateau turned town hall, a neo-Greek fountain, a medieval church, and a beautiful 19th-century park. Learn about Clamart's fascinating history, from its famous peas that fed Paris to its artistic residents like Henri Matisse.",
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
  };

  // Create stop documents
  const stops = [
    {
      order: 0,
      name: 'Avenue Jean Jaures - Start Point',
      description: "Begin your walk at Avenue Jean Jaures, one of Clamart's main arteries named after the famous French socialist leader Jean Jaures. This avenue has been the heart of commercial life in Clamart and leads directly to the historic town center.",
      location: new admin.firestore.GeoPoint(48.8005, 2.2645),
      geohash: 'u09tun',
      triggerRadius: 30,
      media: {
        audioUrl: null,
        audioSource: 'elevenlabs',
        audioDuration: 90,
        audioText: "Bienvenue a Clamart! Welcome to our historic walking tour. You are standing on Avenue Jean Jaures, named after the beloved French socialist leader who championed workers' rights in the early 20th century. Clamart has a rich history dating back to prehistoric times, though the first real settlement was discovered from the 7th century. Fun fact: the town is famous in French gastronomy - any dish served 'a la Clamart' features peas, as Clamart's peas were the first of the season to reach Paris markets. Let's begin our journey into history.",
        images: []
      }
    },
    {
      order: 1,
      name: 'Hotel de Ville (Town Hall)',
      description: 'The magnificent Clamart Town Hall is housed in the former Chateau de Barral, a stunning 17th-century neoclassical building. Acquired by the town council in 1842, it became a historic monument in 1929. The interior features remarkable 20th-century wall paintings.',
      location: new admin.firestore.GeoPoint(48.8024, 2.2636),
      geohash: 'u09tup',
      triggerRadius: 35,
      media: {
        audioUrl: null,
        audioSource: 'elevenlabs',
        audioDuration: 120,
        audioText: "Before you stands the Hotel de Ville, Clamart's town hall, but this elegant building has a much grander origin. This is the former Chateau de Barral, built in the 17th century in the neoclassical style. Notice the asymmetrical facade of six bays, constructed in beautiful ashlar stone. In the 1840s, Mayor Denis Gogue led the effort to acquire this property for the town. Inside, you'll find the Hall of Weddings and Council Chamber, decorated with stunning wall paintings from the 20th century - themselves classified as historic monuments. The building became a monument historique in 1929, preserving this jewel of French architecture for future generations.",
        images: []
      }
    },
    {
      order: 2,
      name: 'Fontaine Thurotte',
      description: "This charming neo-Greek style fountain was installed in 1943, depicting a young shepherd playing the flute near his goat. It was Clamart's first public art acquisition, created by sculptor Thurotte who was inspired by Grand Prix de Rome winner Paul Landowski.",
      location: new admin.firestore.GeoPoint(48.8026, 2.2640),
      geohash: 'u09tup',
      triggerRadius: 25,
      media: {
        audioUrl: null,
        audioSource: 'elevenlabs',
        audioDuration: 100,
        audioText: "Just steps from the town hall, you'll find the enchanting Fontaine Thurotte. Installed in 1943, this neo-Greek style fountain evokes the sylvan and bucolic life that once defined Clamart. Look closely at the sculpture: a young shepherd leans against a tree, peacefully playing his flute while his faithful goat stands nearby. The sculptor, Thurotte, drew inspiration from Paul Landowski, the Grand Prix de Rome winner famous for creating the Christ the Redeemer statue in Rio de Janeiro. This fountain holds special significance as it was Clamart's very first public art acquisition, marking the town's commitment to beautifying its public spaces.",
        images: []
      }
    },
    {
      order: 3,
      name: 'Eglise Saint-Pierre Saint-Paul',
      description: "This historic church has roots in the 11th century, with the base of its bell tower dating from that era. Rebuilt after the Hundred Years' War and consecrated in 1523, it features a Gothic side gate, an 18th-century Tuscan facade, and the Saint Vincent chapel honoring the patron saint of winegrowers.",
      location: new admin.firestore.GeoPoint(48.8010, 2.2652),
      geohash: 'u09tun',
      triggerRadius: 35,
      media: {
        audioUrl: null,
        audioSource: 'elevenlabs',
        audioDuration: 130,
        audioText: "The Eglise Saint-Pierre Saint-Paul stands as a testament to Clamart's long Christian heritage. The base of its bell tower dates all the way back to the 11th century, making it one of the oldest structures in the region. However, the church you see today was largely rebuilt after the devastating Hundred Years' War and was consecrated in 1523. Notice the beautiful flamboyant Gothic style of the side gate, contrasting with the more restrained 18th-century Tuscan-style western facade. Inside, you'll discover remarkable stained glass windows and the Saint Vincent chapel. Saint Vincent is the patron saint of winegrowers - a reminder that Clamart was once surrounded by vineyards that produced wine for Paris. The church has been listed as a historic monument since 1928.",
        images: []
      }
    },
    {
      order: 4,
      name: 'Parc de la Maison Blanche',
      description: 'End your tour at this beautiful 3.7-acre park designed in the 1830s, formerly owned by the Duchess of Galliera. The elegant Maison Blanche mansion at its heart now serves as a cultural center hosting exhibitions and concerts throughout the year.',
      location: new admin.firestore.GeoPoint(48.8030, 2.2678),
      geohash: 'u09tuq',
      triggerRadius: 40,
      media: {
        audioUrl: null,
        audioSource: 'elevenlabs',
        audioDuration: 110,
        audioText: "We conclude our tour at the lovely Parc de la Maison Blanche, a green oasis in the heart of Clamart. This 3.7-acre park was designed in the 1830s and was once part of the estate of the Duchess of Galliera. As you stroll through the manicured gardens, past the small lake and charming playgrounds, you'll reach the centerpiece: the elegant Maison Blanche mansion. Today, this beautiful building serves as a cultural center, hosting art exhibitions and concerts throughout the year. Clamart has been home to many artists - Henri Matisse lived here before World War I, and the Dada artists Jean Arp and Sophie Taeuber-Arp resided here in the 1930s. Thank you for joining us on this journey through Clamart's rich history. Au revoir!",
        images: []
      }
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
        versionId: versionId,
        createdAt: now,
        updatedAt: now
      });
      console.log('Created stop:', stop.name);
    }

    console.log('\n========================================');
    console.log('Clamart tour created successfully!');
    console.log('========================================');
    console.log('Tour ID:', tourId);
    console.log('Location: Clamart, France (92140)');
    console.log('Start: 23 Avenue Jean Jaures');
    console.log('Stops:', stops.length);
    console.log('');
    console.log('Stops:');
    stops.forEach((stop, i) => {
      console.log(`  ${i + 1}. ${stop.name}`);
    });

  } catch (error) {
    console.error('Error creating Clamart tour:', error);
  }

  process.exit(0);
}

createClamartTour();
