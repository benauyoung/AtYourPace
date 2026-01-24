import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';
import 'package:ayp_tour_guide/presentation/providers/favorites_provider.dart';
import 'package:ayp_tour_guide/presentation/providers/tour_providers.dart';
import 'package:ayp_tour_guide/presentation/widgets/tour/tour_card.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('TourCard', () {
    late TourModel testTour;
    late TourVersionModel testVersion;

    setUp(() {
      testTour = createTestTour(
        id: 'tour_1',
        city: 'San Francisco',
        country: 'USA',
        category: TourCategory.history,
        tourType: TourType.walking,
        featured: false,
      );
      testVersion = createTestTourVersion(
        id: 'v1',
        tourId: 'tour_1',
        title: 'Golden Gate Tour',
        coverImageUrl: null, // No image to avoid network calls
      );
    });

    Widget buildTestWidget({
      TourModel? tour,
      VoidCallback? onTap,
      bool showStats = true,
      bool showFavoriteButton = false,
      List<Override> overrides = const [],
    }) {
      final useTour = tour ?? testTour;
      return ProviderScope(
        overrides: [
          // Override version provider to return test data synchronously
          tourVersionProvider((tourId: useTour.id, versionId: useTour.draftVersionId))
              .overrideWith((ref) => testVersion),
          // Override favorites provider
          isTourFavoritedProvider(useTour.id).overrideWith((ref) => false),
          ...overrides,
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TourCard(
                tour: useTour,
                onTap: onTap,
                showStats: showStats,
                showFavoriteButton: showFavoriteButton,
              ),
            ),
          ),
        ),
      );
    }

    group('Display', () {
      testWidgets('displays tour title from version', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Golden Gate Tour'), findsOneWidget);
      });

      testWidgets('displays location info', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('San Francisco, USA'), findsOneWidget);
      });

      testWidgets('displays creator name', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.textContaining('by Test Creator'), findsOneWidget);
      });

      testWidgets('displays category chip', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('History'), findsOneWidget);
      });

      testWidgets('displays tour type chip', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Walking'), findsOneWidget);
      });

      testWidgets('displays placeholder when no cover image', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should find the category icon as placeholder (history = account_balance)
        expect(find.byIcon(Icons.account_balance), findsWidgets);
      });
    });

    group('Featured Badge', () {
      testWidgets('shows featured badge when tour is featured', (tester) async {
        final featuredTour = createTestTour(
          id: 'tour_2',
          featured: true,
        );

        await tester.pumpWidget(buildTestWidget(
          tour: featuredTour,
          overrides: [
            tourVersionProvider((tourId: featuredTour.id, versionId: featuredTour.draftVersionId))
                .overrideWith((ref) => testVersion),
            isTourFavoritedProvider(featuredTour.id).overrideWith((ref) => false),
          ],
        ));
        await tester.pumpAndSettle();

        expect(find.text('Featured'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsWidgets);
      });

      testWidgets('hides featured badge when tour is not featured', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Featured'), findsNothing);
      });
    });

    group('Favorite Button', () {
      testWidgets('shows favorite button when showFavoriteButton is true', (tester) async {
        await tester.pumpWidget(buildTestWidget(showFavoriteButton: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('hides favorite button when showFavoriteButton is false', (tester) async {
        await tester.pumpWidget(buildTestWidget(showFavoriteButton: false));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite_border), findsNothing);
        expect(find.byIcon(Icons.favorite), findsNothing);
      });

      testWidgets('shows filled heart when favorited', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          showFavoriteButton: true,
          overrides: [
            tourVersionProvider((tourId: testTour.id, versionId: testTour.draftVersionId))
                .overrideWith((ref) => testVersion),
            isTourFavoritedProvider(testTour.id).overrideWith((ref) => true),
          ],
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });
    });

    group('Stats Display', () {
      testWidgets('shows stats when showStats is true', (tester) async {
        final tourWithStats = createTestTour(
          id: 'tour_3',
        ).copyWith(
          stats: const TourStats(
            totalPlays: 1500,
            totalDownloads: 500,
            averageRating: 4.5,
            totalRatings: 100,
          ),
        );

        await tester.pumpWidget(buildTestWidget(
          tour: tourWithStats,
          showStats: true,
          overrides: [
            tourVersionProvider((tourId: tourWithStats.id, versionId: tourWithStats.draftVersionId))
                .overrideWith((ref) => testVersion),
            isTourFavoritedProvider(tourWithStats.id).overrideWith((ref) => false),
          ],
        ));
        await tester.pumpAndSettle();

        // Should show rating and play count
        expect(find.text('4.5'), findsOneWidget);
        expect(find.text('1.5K'), findsOneWidget);
      });

      testWidgets('hides stats when showStats is false', (tester) async {
        await tester.pumpWidget(buildTestWidget(showStats: false));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.play_arrow), findsNothing);
      });
    });

    group('Interaction', () {
      testWidgets('calls onTap when card is tapped', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(buildTestWidget(
          onTap: () => tapped = true,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TourCard));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('does not crash when onTap is null', (tester) async {
        await tester.pumpWidget(buildTestWidget(onTap: null));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TourCard));
        await tester.pumpAndSettle();

        // No crash = success
      });
    });

    group('Loading State', () {
      testWidgets('shows card while version loads', (tester) async {
        // Use a Completer to simulate a pending async load without real timers
        final completer = Completer<TourVersionModel>();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            tourVersionProvider((tourId: testTour.id, versionId: testTour.draftVersionId))
                .overrideWith((ref) => completer.future),
            isTourFavoritedProvider(testTour.id).overrideWith((ref) => false),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TourCard(tour: testTour),
              ),
            ),
          ),
        ));
        await tester.pump();

        // Card should still be visible while loading
        expect(find.byType(Card), findsOneWidget);

        // Complete the future to clean up
        completer.complete(testVersion);
        await tester.pumpAndSettle();
      });
    });

    group('Error Handling', () {
      testWidgets('shows fallback title when version fails to load', (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            tourVersionProvider((tourId: testTour.id, versionId: testTour.draftVersionId))
                .overrideWith((ref) async {
              throw Exception('Failed to load');
            }),
            isTourFavoritedProvider(testTour.id).overrideWith((ref) => false),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TourCard(tour: testTour),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Should show city as fallback
        expect(find.text('San Francisco'), findsOneWidget);
      });
    });
  });

  group('CompactTourCard', () {
    late TourModel testTour;
    late TourVersionModel testVersion;

    setUp(() {
      testTour = createTestTour(id: 'tour_1', city: 'Paris');
      testVersion = createTestTourVersion(
        id: 'v1',
        tourId: 'tour_1',
        title: 'Paris Walking Tour',
      );
    });

    testWidgets('displays tour title', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          tourVersionProvider((tourId: testTour.id, versionId: testTour.draftVersionId))
              .overrideWith((ref) => testVersion),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CompactTourCard(tour: testTour),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Paris Walking Tour'), findsOneWidget);
    });

    testWidgets('displays creator name', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          tourVersionProvider((tourId: testTour.id, versionId: testTour.draftVersionId))
              .overrideWith((ref) => testVersion),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CompactTourCard(tour: testTour),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(testTour.creatorName), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(ProviderScope(
        overrides: [
          tourVersionProvider((tourId: testTour.id, versionId: testTour.draftVersionId))
              .overrideWith((ref) => testVersion),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CompactTourCard(
              tour: testTour,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CompactTourCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
