import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tour_model.dart';
import '../../data/models/tour_version_model.dart';
import '../../data/models/stop_model.dart';

/// Demo tour data for testing without Firebase
/// These are sample walking tours in San Francisco

final _demoTour1 = TourModel(
  id: 'demo-tour-1',
  creatorId: 'demo-user-001',
  creatorName: 'Demo Guide',
  slug: 'sf-fishermans-wharf-walking-tour',
  category: TourCategory.history,
  tourType: TourType.walking,
  status: TourStatus.approved,
  featured: true,
  startLocation: const GeoPoint(37.8080, -122.4177), // Fisherman's Wharf
  geohash: '9q8yyk',
  city: 'San Francisco',
  country: 'United States',
  liveVersionId: 'v1',
  liveVersion: 1,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 1523,
    totalDownloads: 892,
    averageRating: 4.7,
    totalRatings: 234,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 30)),
  updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  publishedAt: DateTime.now().subtract(const Duration(days: 28)),
);

final _demoTour2 = TourModel(
  id: 'demo-tour-2',
  creatorId: 'demo-user-001',
  creatorName: 'Demo Guide',
  slug: 'sf-golden-gate-park-nature-walk',
  category: TourCategory.nature,
  tourType: TourType.walking,
  status: TourStatus.approved,
  featured: true,
  startLocation: const GeoPoint(37.7694, -122.4862), // Golden Gate Park
  geohash: '9q8yvn',
  city: 'San Francisco',
  country: 'United States',
  liveVersionId: 'v1',
  liveVersion: 1,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 987,
    totalDownloads: 543,
    averageRating: 4.5,
    totalRatings: 156,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 60)),
  updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  publishedAt: DateTime.now().subtract(const Duration(days: 55)),
);

final _demoTour3 = TourModel(
  id: 'demo-tour-3',
  creatorId: 'demo-user-001',
  creatorName: 'Demo Guide',
  slug: 'sf-chinatown-food-tour',
  category: TourCategory.food,
  tourType: TourType.walking,
  status: TourStatus.approved,
  featured: false,
  startLocation: const GeoPoint(37.7941, -122.4078), // Chinatown
  geohash: '9q8yyu',
  city: 'San Francisco',
  country: 'United States',
  liveVersionId: 'v1',
  liveVersion: 1,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 654,
    totalDownloads: 321,
    averageRating: 4.8,
    totalRatings: 89,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 45)),
  updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  publishedAt: DateTime.now().subtract(const Duration(days: 40)),
);

final _demoVersion1 = TourVersionModel(
  id: 'v1',
  tourId: 'demo-tour-1',
  versionNumber: 1,
  versionType: VersionType.live,
  title: "Fisherman's Wharf Walking Tour",
  description:
      "Explore the iconic Fisherman's Wharf and discover its rich maritime history. Visit Pier 39, see the famous sea lions, and learn about the historic fishing fleet that gave this neighborhood its name.",
  coverImageUrl: 'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800',
  duration: '1.5 hours',
  distance: '2.1 km',
  difficulty: TourDifficulty.easy,
  languages: const ['English'],
  route: const TourRoute(
    encodedPolyline: 'mfqeFfqdjVzArDlBnE',
    boundingBox: BoundingBox(
      northeast: GeoPoint(37.8100, -122.4100),
      southwest: GeoPoint(37.8050, -122.4200),
    ),
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 30)),
  updatedAt: DateTime.now().subtract(const Duration(days: 2)),
);

final _demoVersion2 = TourVersionModel(
  id: 'v1',
  tourId: 'demo-tour-2',
  versionNumber: 1,
  versionType: VersionType.live,
  title: 'Golden Gate Park Nature Walk',
  description:
      'Discover the natural beauty of Golden Gate Park, one of the largest urban parks in the world. Walk through botanical gardens, serene lakes, and historic monuments.',
  coverImageUrl: 'https://images.unsplash.com/photo-1449034446853-66c86144b0ad?w=800',
  duration: '2 hours',
  distance: '3.5 km',
  difficulty: TourDifficulty.moderate,
  languages: const ['English', 'Spanish'],
  route: const TourRoute(
    encodedPolyline: 'qxpeFrtejVxBtFpCrH',
    boundingBox: BoundingBox(
      northeast: GeoPoint(37.7720, -122.4800),
      southwest: GeoPoint(37.7650, -122.4950),
    ),
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 60)),
  updatedAt: DateTime.now().subtract(const Duration(days: 5)),
);

final _demoVersion3 = TourVersionModel(
  id: 'v1',
  tourId: 'demo-tour-3',
  versionNumber: 1,
  versionType: VersionType.live,
  title: 'Chinatown Culinary Adventure',
  description:
      "Savor the flavors of San Francisco's historic Chinatown. Visit traditional bakeries, tea shops, and hidden gems that locals love. Learn about the neighborhood's fascinating history.",
  coverImageUrl: 'https://images.unsplash.com/photo-1548531846-cb2d171cadc3?w=800',
  duration: '1 hour',
  distance: '1.2 km',
  difficulty: TourDifficulty.easy,
  languages: const ['English', 'Mandarin'],
  route: const TourRoute(
    encodedPolyline: 'wyreFdbdjVtAnC',
    boundingBox: BoundingBox(
      northeast: GeoPoint(37.7960, -122.4050),
      southwest: GeoPoint(37.7920, -122.4100),
    ),
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 45)),
  updatedAt: DateTime.now().subtract(const Duration(days: 1)),
);

final List<StopModel> _demoStops1 = [
  StopModel(
    id: 'stop-1-1',
    tourId: 'demo-tour-1',
    versionId: 'v1',
    order: 0,
    name: 'Pier 39 Entrance',
    description: 'Start your journey at the iconic Pier 39, the most visited attraction in San Francisco.',
    location: const GeoPoint(37.8087, -122.4098),
    geohash: '9q8yym',
    triggerRadius: 30,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 120,
      audioText: 'Welcome to Pier 39, one of the most visited attractions in San Francisco...',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  StopModel(
    id: 'stop-1-2',
    tourId: 'demo-tour-1',
    versionId: 'v1',
    order: 1,
    name: 'Sea Lion Colony',
    description: 'Watch the famous California sea lions that have made the docks their home since 1990.',
    location: const GeoPoint(37.8095, -122.4106),
    geohash: '9q8yym',
    triggerRadius: 25,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 90,
      audioText: 'Here at K-Dock, you can see hundreds of California sea lions...',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  StopModel(
    id: 'stop-1-3',
    tourId: 'demo-tour-1',
    versionId: 'v1',
    order: 2,
    name: 'Aquarium of the Bay',
    description: 'Learn about the marine life of San Francisco Bay at this unique aquarium.',
    location: const GeoPoint(37.8082, -122.4093),
    geohash: '9q8yym',
    triggerRadius: 30,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 100,
      audioText: 'The Aquarium of the Bay showcases over 20,000 local marine animals...',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  StopModel(
    id: 'stop-1-4',
    tourId: 'demo-tour-1',
    versionId: 'v1',
    order: 3,
    name: 'Historic Ships at Hyde Street Pier',
    description: 'Explore a collection of historic vessels at the San Francisco Maritime National Historical Park.',
    location: const GeoPoint(37.8070, -122.4217),
    geohash: '9q8yyk',
    triggerRadius: 35,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 150,
      audioText: 'Welcome to Hyde Street Pier, home to the largest collection of historic ships on the west coast...',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final List<StopModel> _demoStops2 = [
  StopModel(
    id: 'stop-2-1',
    tourId: 'demo-tour-2',
    versionId: 'v1',
    order: 0,
    name: 'Conservatory of Flowers',
    description: 'Begin at the stunning Victorian greenhouse, the oldest wooden conservatory in North America.',
    location: const GeoPoint(37.7726, -122.4600),
    geohash: '9q8yvu',
    triggerRadius: 40,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 130,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  StopModel(
    id: 'stop-2-2',
    tourId: 'demo-tour-2',
    versionId: 'v1',
    order: 1,
    name: 'Japanese Tea Garden',
    description: 'Visit the oldest public Japanese garden in the United States.',
    location: const GeoPoint(37.7704, -122.4703),
    geohash: '9q8yvn',
    triggerRadius: 30,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 110,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  StopModel(
    id: 'stop-2-3',
    tourId: 'demo-tour-2',
    versionId: 'v1',
    order: 2,
    name: 'Stow Lake',
    description: 'Enjoy the serene beauty of Stow Lake, perfect for a peaceful stroll.',
    location: const GeoPoint(37.7689, -122.4789),
    geohash: '9q8yvh',
    triggerRadius: 35,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 95,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

final List<StopModel> _demoStops3 = [
  StopModel(
    id: 'stop-3-1',
    tourId: 'demo-tour-3',
    versionId: 'v1',
    order: 0,
    name: 'Dragon Gate',
    description: 'Enter through the iconic Dragon Gate, the entrance to the oldest Chinatown in North America.',
    location: const GeoPoint(37.7905, -122.4058),
    geohash: '9q8yyv',
    triggerRadius: 25,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 80,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  StopModel(
    id: 'stop-3-2',
    tourId: 'demo-tour-3',
    versionId: 'v1',
    order: 1,
    name: 'Golden Gate Fortune Cookie Factory',
    description: 'Watch fortune cookies being made by hand at this tiny, family-run factory.',
    location: const GeoPoint(37.7939, -122.4063),
    geohash: '9q8yyu',
    triggerRadius: 20,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 100,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// Demo tour for Clamart, France (testing in Europe)
final _demoTourClamart = TourModel(
  id: 'demo-tour-clamart',
  creatorId: 'demo-user-001',
  creatorName: 'Demo Guide',
  slug: 'clamart-historic-walking-tour',
  category: TourCategory.history,
  tourType: TourType.walking,
  status: TourStatus.approved,
  featured: true,
  startLocation: const GeoPoint(48.8005, 2.2645), // 23 Avenue Jean Jaurès
  geohash: 'u09tun',
  city: 'Clamart',
  region: 'Île-de-France',
  country: 'France',
  liveVersionId: 'v1',
  liveVersion: 1,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 342,
    totalDownloads: 187,
    averageRating: 4.6,
    totalRatings: 45,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 20)),
  updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  publishedAt: DateTime.now().subtract(const Duration(days: 18)),
);

final _demoVersionClamart = TourVersionModel(
  id: 'v1',
  tourId: 'demo-tour-clamart',
  versionNumber: 1,
  versionType: VersionType.live,
  title: 'Historic Clamart Walking Tour',
  description:
      'Discover the charming town of Clamart, a hidden gem in the southwestern suburbs of Paris. This walking tour takes you through the historic center, featuring a 17th-century château turned town hall, a neo-Greek fountain, a medieval church, and a beautiful 19th-century park. Learn about Clamart\'s fascinating history, from its famous peas that fed Paris to its artistic residents like Henri Matisse.',
  coverImageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
  duration: '1.5 hours',
  distance: '2.0 km',
  difficulty: TourDifficulty.easy,
  languages: const ['English', 'French'],
  route: const TourRoute(
    encodedPolyline: 'gfqiHcxhM_@dAiBrCkAnB',
    boundingBox: BoundingBox(
      northeast: GeoPoint(48.8035, 2.2690),
      southwest: GeoPoint(48.8000, 2.2630),
    ),
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 20)),
  updatedAt: DateTime.now().subtract(const Duration(days: 3)),
);

final List<StopModel> _demoStopsClamart = [
  StopModel(
    id: 'stop-clamart-1',
    tourId: 'demo-tour-clamart',
    versionId: 'v1',
    order: 0,
    name: 'Avenue Jean Jaurès - Start Point',
    description:
        'Begin your walk at Avenue Jean Jaurès, one of Clamart\'s main arteries named after the famous French socialist leader Jean Jaurès. This avenue has been the heart of commercial life in Clamart and leads directly to the historic town center.',
    location: const GeoPoint(48.8005, 2.2645),
    geohash: 'u09tun',
    triggerRadius: 30,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 90,
      audioText:
          'Bienvenue à Clamart! Welcome to our historic walking tour. You are standing on Avenue Jean Jaurès, named after the beloved French socialist leader who championed workers\' rights in the early 20th century. Clamart has a rich history dating back to prehistoric times, though the first real settlement was discovered from the 7th century. Fun fact: the town is famous in French gastronomy - any dish served "à la Clamart" features peas, as Clamart\'s peas were the first of the season to reach Paris markets. Let\'s begin our journey into history.',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  StopModel(
    id: 'stop-clamart-2',
    tourId: 'demo-tour-clamart',
    versionId: 'v1',
    order: 1,
    name: 'Hôtel de Ville (Town Hall)',
    description:
        'The magnificent Clamart Town Hall is housed in the former Château de Barral, a stunning 17th-century neoclassical building. Acquired by the town council in 1842, it became a historic monument in 1929. The interior features remarkable 20th-century wall paintings.',
    location: const GeoPoint(48.8024, 2.2636),
    geohash: 'u09tup',
    triggerRadius: 35,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 120,
      audioText:
          'Before you stands the Hôtel de Ville, Clamart\'s town hall, but this elegant building has a much grander origin. This is the former Château de Barral, built in the 17th century in the neoclassical style. Notice the asymmetrical facade of six bays, constructed in beautiful ashlar stone. In the 1840s, Mayor Denis Gogue led the effort to acquire this property for the town. Inside, you\'ll find the Hall of Weddings and Council Chamber, decorated with stunning wall paintings from the 20th century - themselves classified as historic monuments. The building became a monument historique in 1929, preserving this jewel of French architecture for future generations.',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  StopModel(
    id: 'stop-clamart-3',
    tourId: 'demo-tour-clamart',
    versionId: 'v1',
    order: 2,
    name: 'Fontaine Thurotte',
    description:
        'This charming neo-Greek style fountain was installed in 1943, depicting a young shepherd playing the flute near his goat. It was Clamart\'s first public art acquisition, created by sculptor Thurotte who was inspired by Grand Prix de Rome winner Paul Landowski.',
    location: const GeoPoint(48.8026, 2.2640),
    geohash: 'u09tup',
    triggerRadius: 25,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 100,
      audioText:
          'Just steps from the town hall, you\'ll find the enchanting Fontaine Thurotte. Installed in 1943, this neo-Greek style fountain evokes the sylvan and bucolic life that once defined Clamart. Look closely at the sculpture: a young shepherd leans against a tree, peacefully playing his flute while his faithful goat stands nearby. The sculptor, Thurotte, drew inspiration from Paul Landowski, the Grand Prix de Rome winner famous for creating the Christ the Redeemer statue in Rio de Janeiro. This fountain holds special significance as it was Clamart\'s very first public art acquisition, marking the town\'s commitment to beautifying its public spaces.',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  StopModel(
    id: 'stop-clamart-4',
    tourId: 'demo-tour-clamart',
    versionId: 'v1',
    order: 3,
    name: 'Église Saint-Pierre Saint-Paul',
    description:
        'This historic church has roots in the 11th century, with the base of its bell tower dating from that era. Rebuilt after the Hundred Years\' War and consecrated in 1523, it features a Gothic side gate, an 18th-century Tuscan facade, and the Saint Vincent chapel honoring the patron saint of winegrowers.',
    location: const GeoPoint(48.8010, 2.2652),
    geohash: 'u09tun',
    triggerRadius: 35,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 130,
      audioText:
          'The Église Saint-Pierre Saint-Paul stands as a testament to Clamart\'s long Christian heritage. The base of its bell tower dates all the way back to the 11th century, making it one of the oldest structures in the region. However, the church you see today was largely rebuilt after the devastating Hundred Years\' War and was consecrated in 1523. Notice the beautiful flamboyant Gothic style of the side gate, contrasting with the more restrained 18th-century Tuscan-style western facade. Inside, you\'ll discover remarkable stained glass windows and the Saint Vincent chapel. Saint Vincent is the patron saint of winegrowers - a reminder that Clamart was once surrounded by vineyards that produced wine for Paris. The church has been listed as a historic monument since 1928.',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  StopModel(
    id: 'stop-clamart-5',
    tourId: 'demo-tour-clamart',
    versionId: 'v1',
    order: 4,
    name: 'Parc de la Maison Blanche',
    description:
        'End your tour at this beautiful 3.7-acre park designed in the 1830s, formerly owned by the Duchess of Galliera. The elegant Maison Blanche mansion at its heart now serves as a cultural center hosting exhibitions and concerts throughout the year.',
    location: const GeoPoint(48.8030, 2.2678),
    geohash: 'u09tuq',
    triggerRadius: 40,
    media: const StopMedia(
      audioSource: AudioSource.elevenlabs,
      audioDuration: 110,
      audioText:
          'We conclude our tour at the lovely Parc de la Maison Blanche, a green oasis in the heart of Clamart. This 3.7-acre park was designed in the 1830s and was once part of the estate of the Duchess of Galliera. As you stroll through the manicured gardens, past the small lake and charming playgrounds, you\'ll reach the centerpiece: the elegant Maison Blanche mansion. Today, this beautiful building serves as a cultural center, hosting art exhibitions and concerts throughout the year. Clamart has been home to many artists - Henri Matisse lived here before World War I, and the Dada artists Jean Arp and Sophie Taeuber-Arp resided here in the 1930s. Thank you for joining us on this journey through Clamart\'s rich history. Au revoir!',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

// Additional demo tours with different statuses for admin testing
final _demoTour4 = TourModel(
  id: 'demo-tour-4',
  creatorId: 'demo-user-002',
  creatorName: 'Sarah Thompson',
  slug: 'sf-mission-murals',
  category: TourCategory.art,
  tourType: TourType.walking,
  status: TourStatus.pendingReview,
  featured: false,
  startLocation: const GeoPoint(37.7599, -122.4148), // Mission District
  geohash: '9q8yv4',
  city: 'San Francisco',
  country: 'United States',
  liveVersionId: null,
  liveVersion: null,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 0,
    totalDownloads: 0,
    averageRating: 0,
    totalRatings: 0,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 3)),
  updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
);

final _demoTour5 = TourModel(
  id: 'demo-tour-5',
  creatorId: 'demo-user-003',
  creatorName: 'Mike Chen',
  slug: 'sf-ghost-tour',
  category: TourCategory.ghost,
  tourType: TourType.walking,
  status: TourStatus.draft,
  featured: false,
  startLocation: const GeoPoint(37.7875, -122.4324), // Alamo Square
  geohash: '9q8yyg',
  city: 'San Francisco',
  country: 'United States',
  liveVersionId: null,
  liveVersion: null,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 0,
    totalDownloads: 0,
    averageRating: 0,
    totalRatings: 0,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 7)),
  updatedAt: DateTime.now().subtract(const Duration(days: 1)),
);

final _demoTour6 = TourModel(
  id: 'demo-tour-6',
  creatorId: 'demo-user-002',
  creatorName: 'Sarah Thompson',
  slug: 'sf-pacific-heights',
  category: TourCategory.history,
  tourType: TourType.walking,
  status: TourStatus.rejected,
  featured: false,
  startLocation: const GeoPoint(37.7925, -122.4382), // Pacific Heights
  geohash: '9q8yyf',
  city: 'San Francisco',
  country: 'United States',
  liveVersionId: null,
  liveVersion: null,
  draftVersionId: 'v1',
  draftVersion: 1,
  stats: const TourStats(
    totalPlays: 0,
    totalDownloads: 0,
    averageRating: 0,
    totalRatings: 0,
  ),
  createdAt: DateTime.now().subtract(const Duration(days: 14)),
  updatedAt: DateTime.now().subtract(const Duration(days: 10)),
);

// All demo tours for users (only approved)
final List<TourModel> _allDemoTours = [_demoTour1, _demoTour2, _demoTour3, _demoTourClamart];

// All demo tours for admin (all statuses)
final List<TourModel> _allDemoToursAdmin = [
  _demoTour1,
  _demoTour2,
  _demoTour3,
  _demoTourClamart,
  _demoTour4,
  _demoTour5,
  _demoTour6,
];

// Demo versions map
final Map<String, TourVersionModel> _demoVersions = {
  'demo-tour-1:v1': _demoVersion1,
  'demo-tour-2:v1': _demoVersion2,
  'demo-tour-3:v1': _demoVersion3,
  'demo-tour-clamart:v1': _demoVersionClamart,
};

// Demo stops map
final Map<String, List<StopModel>> _demoStopsMap = {
  'demo-tour-1:v1': _demoStops1,
  'demo-tour-2:v1': _demoStops2,
  'demo-tour-3:v1': _demoStops3,
  'demo-tour-clamart:v1': _demoStopsClamart,
};

// Demo providers

/// Featured tours (demo)
final demoFeaturedToursProvider = FutureProvider<List<TourModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
  return _allDemoTours.where((t) => t.featured).toList();
});

/// Nearby tours (demo)
final demoNearbyToursProvider = FutureProvider.family<List<TourModel>,
    ({double lat, double lng, double radiusKm})>((ref, params) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // In demo mode, just return all tours
  return _allDemoTours;
});

/// Tours by category (demo)
final demoToursByCategoryProvider =
    FutureProvider.family<List<TourModel>, TourCategory>((ref, category) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _allDemoTours.where((t) => t.category == category).toList();
});

/// Single tour by ID (demo)
final demoTourByIdProvider =
    FutureProvider.family<TourModel?, String>((ref, tourId) async {
  await Future.delayed(const Duration(milliseconds: 100));
  try {
    return _allDemoTours.firstWhere((t) => t.id == tourId);
  } catch (e) {
    return null;
  }
});

/// Tour version (demo)
final demoTourVersionProvider = FutureProvider.family<TourVersionModel?,
    ({String tourId, String versionId})>((ref, params) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return _demoVersions['${params.tourId}:${params.versionId}'];
});

/// Stops for a version (demo)
final demoStopsProvider = FutureProvider.family<List<StopModel>,
    ({String tourId, String versionId})>((ref, params) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return _demoStopsMap['${params.tourId}:${params.versionId}'] ?? [];
});

/// Creator's tours (demo)
final demoCreatorToursProvider = FutureProvider<List<TourModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _allDemoTours;
});

/// All tours for admin (demo)
final demoAllToursProvider = FutureProvider<List<TourModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _allDemoToursAdmin;
});
