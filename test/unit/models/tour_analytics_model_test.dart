import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/tour_analytics_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('TourAnalyticsModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final now = DateTime.now();
        final json = <String, dynamic>{
          'id': 'analytics_1',
          'tourId': 'tour_1',
          'period': 'week',
          'startDate': now.subtract(const Duration(days: 7)).toIso8601String(),
          'endDate': now.toIso8601String(),
          'plays': <String, dynamic>{
            'total': 100,
            'unique': 75,
            'averageDuration': 1800.0,
            'completions': 50,
            'completionRate': 0.5,
            'changeFromPrevious': 10.5,
          },
          'downloads': <String, dynamic>{
            'total': 30,
            'unique': 30,
            'storageUsed': 50000.0,
            'changeFromPrevious': 5.0,
          },
          'favorites': <String, dynamic>{
            'total': 20,
            'changeFromPrevious': 2.0,
          },
          'revenue': <String, dynamic>{
            'total': 0.0,
            'transactions': 0,
            'averageTransaction': 0.0,
            'byPricingTier': <String, dynamic>{},
            'changeFromPrevious': 0.0,
          },
          'completion': <String, dynamic>{
            'completionRate': 0.5,
            'dropOffByStop': <String, dynamic>{},
            'averageCompletionTime': 2700.0,
          },
          'geographic': <String, dynamic>{
            'byCity': <String, dynamic>{},
            'byCountry': <String, dynamic>{},
          },
          'timeSeries': <String, dynamic>{
            'plays': <Map<String, dynamic>>[],
            'downloads': <Map<String, dynamic>>[],
            'favorites': <Map<String, dynamic>>[],
          },
          'feedback': <String, dynamic>{
            'averageRating': 4.5,
            'totalReviews': 15,
            'ratingDistribution': <String, dynamic>{},
          },
          'generatedAt': now.toIso8601String(),
        };

        final analytics = TourAnalyticsModel.fromJson(json);

        expect(analytics.id, equals('analytics_1'));
        expect(analytics.tourId, equals('tour_1'));
        expect(analytics.period, equals(AnalyticsPeriod.week));
        expect(analytics.plays.total, equals(100));
        expect(analytics.downloads.total, equals(30));
        expect(analytics.favorites.total, equals(20));
      });

      test('toJson serializes correctly', () {
        final analytics = createTestTourAnalytics(
          id: 'analytics_1',
          tourId: 'tour_1',
          period: AnalyticsPeriod.month,
        );

        final json = analytics.toJson();

        expect(json['id'], equals('analytics_1'));
        expect(json['tourId'], equals('tour_1'));
        expect(json['period'], equals('month'));
      });

      test('toFirestore removes id field', () {
        final analytics = createTestTourAnalytics(id: 'analytics_1');

        final firestoreData = analytics.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['tourId'], equals('test_tour_1'));
      });
    });

    group('Computed Properties', () {
      test('isCacheValid returns true when cache not expired', () {
        final analytics = createTestTourAnalytics();
        expect(analytics.isCacheValid, isTrue);
      });

      test('periodDisplay returns correct values', () {
        expect(createTestTourAnalytics(period: AnalyticsPeriod.day).periodDisplay, equals('Today'));
        expect(createTestTourAnalytics(period: AnalyticsPeriod.week).periodDisplay, equals('This Week'));
        expect(createTestTourAnalytics(period: AnalyticsPeriod.month).periodDisplay, equals('This Month'));
        expect(createTestTourAnalytics(period: AnalyticsPeriod.allTime).periodDisplay, equals('All Time'));
      });

      test('engagementScore calculates weighted score', () {
        final analytics = createTestTourAnalytics(
          totalPlays: 100,
          completionRate: 0.7,
          totalDownloads: 30,
          averageRating: 4.5,
        );

        // completionScore = 0.7 * 40 = 28
        // playScore = 1 * 20 = 20 (has plays)
        // downloadScore = 1 * 20 = 20 (has downloads)
        // ratingScore = (4.5/5) * 20 = 18
        // Total = 86
        expect(analytics.engagementScore, closeTo(86, 1));
      });
    });

    group('Empty Factory', () {
      test('empty creates analytics with zero values', () {
        final empty = TourAnalyticsModel.empty(
          id: 'empty_1',
          tourId: 'tour_1',
          period: AnalyticsPeriod.day,
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now(),
        );

        expect(empty.plays.total, equals(0));
        expect(empty.downloads.total, equals(0));
        expect(empty.favorites.total, equals(0));
        expect(empty.revenue.total, equals(0));
        expect(empty.completion.completionRate, equals(0));
      });
    });

    group('Enum Handling', () {
      test('all AnalyticsPeriod values serialize to correct JSON strings', () {
        final expectedValues = {
          AnalyticsPeriod.day: 'day',
          AnalyticsPeriod.week: 'week',
          AnalyticsPeriod.month: 'month',
          AnalyticsPeriod.quarter: 'quarter',
          AnalyticsPeriod.year: 'year',
          AnalyticsPeriod.allTime: 'all_time',
          AnalyticsPeriod.custom: 'custom',
        };

        for (final entry in expectedValues.entries) {
          final analytics = createTestTourAnalytics(period: entry.key);
          final json = analytics.toJson();
          expect(json['period'], equals(entry.value));
        }
      });
    });
  });

  group('PlayMetrics', () {
    test('averageDurationFormatted returns formatted time', () {
      const metrics = PlayMetrics(
        total: 100,
        unique: 75,
        averageDuration: 1800,
        completions: 50,
        completionRate: 0.5,
        changeFromPrevious: 10.5,
      );

      expect(metrics.averageDurationFormatted, equals('30m 0s'));
    });

    test('isTrendingUp returns true for positive change', () {
      const metrics = PlayMetrics(
        total: 100,
        unique: 75,
        averageDuration: 1800,
        completions: 50,
        completionRate: 0.5,
        changeFromPrevious: 10.5,
      );

      expect(metrics.isTrendingUp, isTrue);
      expect(metrics.isTrendingDown, isFalse);
    });

    test('trendFormatted returns formatted percentage', () {
      const metrics = PlayMetrics(
        total: 100,
        unique: 75,
        averageDuration: 1800,
        completions: 50,
        completionRate: 0.5,
        changeFromPrevious: 10.5,
      );

      expect(metrics.trendFormatted, equals('+10.5%'));
    });
  });

  group('DownloadMetrics', () {
    test('storageFormatted returns KB for small sizes', () {
      const metrics = DownloadMetrics(
        total: 10,
        unique: 10,
        storageUsed: 500,
        changeFromPrevious: 5.0,
      );

      expect(metrics.storageFormatted, equals('500 KB'));
    });

    test('storageFormatted returns MB for medium sizes', () {
      const metrics = DownloadMetrics(
        total: 10,
        unique: 10,
        storageUsed: 50000,
        changeFromPrevious: 5.0,
      );

      expect(metrics.storageFormatted, equals('48.8 MB'));
    });

    test('storageFormatted returns GB for large sizes', () {
      const metrics = DownloadMetrics(
        total: 10,
        unique: 10,
        storageUsed: 1500000,
        changeFromPrevious: 5.0,
      );

      expect(metrics.storageFormatted, equals('1.43 GB'));
    });
  });

  group('RevenueMetrics', () {
    test('totalFormatted returns formatted currency', () {
      const metrics = RevenueMetrics(
        total: 1234.56,
        transactions: 50,
        averageTransaction: 24.69,
        byPricingTier: {},
        changeFromPrevious: 15.0,
      );

      expect(metrics.totalFormatted, equals('\$1234.56'));
    });

    test('averageFormatted returns formatted currency', () {
      const metrics = RevenueMetrics(
        total: 1234.56,
        transactions: 50,
        averageTransaction: 24.69,
        byPricingTier: {},
        changeFromPrevious: 15.0,
      );

      expect(metrics.averageFormatted, equals('\$24.69'));
    });

    test('hasRevenue returns true when total > 0', () {
      const withRevenue = RevenueMetrics(
        total: 100.0,
        transactions: 10,
        averageTransaction: 10.0,
        byPricingTier: {},
        changeFromPrevious: 0,
      );
      const noRevenue = RevenueMetrics(
        total: 0,
        transactions: 0,
        averageTransaction: 0,
        byPricingTier: {},
        changeFromPrevious: 0,
      );

      expect(withRevenue.hasRevenue, isTrue);
      expect(noRevenue.hasRevenue, isFalse);
    });
  });

  group('CompletionMetrics', () {
    test('completionRateFormatted returns percentage', () {
      const metrics = CompletionMetrics(
        completionRate: 0.756,
        dropOffByStop: {},
        averageCompletionTime: 2700,
      );

      expect(metrics.completionRateFormatted, equals('75.6%'));
    });

    test('averageTimeFormatted returns formatted time', () {
      const metrics = CompletionMetrics(
        completionRate: 0.5,
        dropOffByStop: {},
        averageCompletionTime: 5400,
      );

      expect(metrics.averageTimeFormatted, equals('1h 30m'));
    });

    test('highestDropOffStop returns stop with most drop-offs', () {
      const metrics = CompletionMetrics(
        completionRate: 0.5,
        dropOffByStop: {1: 10, 2: 25, 3: 15},
        averageCompletionTime: 2700,
      );

      expect(metrics.highestDropOffStop, equals(2));
    });

    test('highestDropOffStop returns null when empty', () {
      const metrics = CompletionMetrics(
        completionRate: 0.5,
        dropOffByStop: {},
        averageCompletionTime: 2700,
      );

      expect(metrics.highestDropOffStop, isNull);
    });

    test('isGoodCompletion returns true for >= 70%', () {
      const good = CompletionMetrics(
        completionRate: 0.7,
        dropOffByStop: {},
        averageCompletionTime: 2700,
      );
      const bad = CompletionMetrics(
        completionRate: 0.5,
        dropOffByStop: {},
        averageCompletionTime: 2700,
      );

      expect(good.isGoodCompletion, isTrue);
      expect(bad.isGoodCompletion, isFalse);
    });

    test('hasSignificantDropOff returns true when > 20% at any stop', () {
      const significant = CompletionMetrics(
        completionRate: 0.5,
        dropOffByStop: {1: 10, 2: 25},
        averageCompletionTime: 2700,
      );
      const notSignificant = CompletionMetrics(
        completionRate: 0.5,
        dropOffByStop: {1: 10, 2: 15},
        averageCompletionTime: 2700,
      );

      expect(significant.hasSignificantDropOff, isTrue);
      expect(notSignificant.hasSignificantDropOff, isFalse);
    });
  });

  group('GeographicMetrics', () {
    test('topCities returns top N cities by count', () {
      const metrics = GeographicMetrics(
        byCity: {'Paris': 100, 'London': 50, 'New York': 75, 'Tokyo': 25},
        byCountry: {},
      );

      final top2 = metrics.topCities(2);
      expect(top2.length, equals(2));
      expect(top2[0].key, equals('Paris'));
      expect(top2[1].key, equals('New York'));
    });

    test('topCountries returns top N countries by count', () {
      const metrics = GeographicMetrics(
        byCity: {},
        byCountry: {'France': 100, 'UK': 50, 'USA': 75},
      );

      final top2 = metrics.topCountries(2);
      expect(top2.length, equals(2));
      expect(top2[0].key, equals('France'));
    });

    test('hasData returns true when data exists', () {
      const withData = GeographicMetrics(
        byCity: {'Paris': 100},
        byCountry: {},
      );
      const noData = GeographicMetrics(
        byCity: {},
        byCountry: {},
      );

      expect(withData.hasData, isTrue);
      expect(noData.hasData, isFalse);
    });

    test('uniqueLocations returns city count', () {
      const metrics = GeographicMetrics(
        byCity: {'Paris': 100, 'London': 50},
        byCountry: {},
      );

      expect(metrics.uniqueLocations, equals(2));
    });

    test('uniqueCountries returns country count', () {
      const metrics = GeographicMetrics(
        byCity: {},
        byCountry: {'France': 100, 'UK': 50, 'USA': 75},
      );

      expect(metrics.uniqueCountries, equals(3));
    });
  });

  group('TimeSeriesData', () {
    test('hasData returns true when any series has data', () {
      final withData = TimeSeriesData(
        plays: [TimeSeriesPoint(date: DateTime.now(), value: 10)],
        downloads: const [],
        favorites: const [],
      );
      const noData = TimeSeriesData(
        plays: [],
        downloads: [],
        favorites: [],
      );

      expect(withData.hasData, isTrue);
      expect(noData.hasData, isFalse);
    });

    test('totalPlays sums all play values', () {
      final data = TimeSeriesData(
        plays: [
          TimeSeriesPoint(date: DateTime.now().subtract(const Duration(days: 2)), value: 10),
          TimeSeriesPoint(date: DateTime.now().subtract(const Duration(days: 1)), value: 15),
          TimeSeriesPoint(date: DateTime.now(), value: 20),
        ],
        downloads: const [],
        favorites: const [],
      );

      expect(data.totalPlays, equals(45));
    });
  });

  group('UserFeedbackMetrics', () {
    test('ratingFormatted returns formatted rating', () {
      const metrics = UserFeedbackMetrics(
        averageRating: 4.567,
        totalReviews: 100,
        ratingDistribution: {},
      );

      expect(metrics.ratingFormatted, equals('4.6'));
    });

    test('isGoodRating returns true for >= 4.0', () {
      const good = UserFeedbackMetrics(
        averageRating: 4.0,
        totalReviews: 100,
        ratingDistribution: {},
      );
      const bad = UserFeedbackMetrics(
        averageRating: 3.5,
        totalReviews: 100,
        ratingDistribution: {},
      );

      expect(good.isGoodRating, isTrue);
      expect(bad.isGoodRating, isFalse);
    });

    test('isExcellentRating returns true for >= 4.5', () {
      const excellent = UserFeedbackMetrics(
        averageRating: 4.5,
        totalReviews: 100,
        ratingDistribution: {},
      );

      expect(excellent.isExcellentRating, isTrue);
    });

    test('fiveStarPercentage calculates correct percentage', () {
      const metrics = UserFeedbackMetrics(
        averageRating: 4.5,
        totalReviews: 100,
        ratingDistribution: {5: 50, 4: 30, 3: 15, 2: 3, 1: 2},
      );

      expect(metrics.fiveStarPercentage, equals(50.0));
    });

    test('positivePercentage calculates 4-5 star percentage', () {
      const metrics = UserFeedbackMetrics(
        averageRating: 4.5,
        totalReviews: 100,
        ratingDistribution: {5: 50, 4: 30, 3: 15, 2: 3, 1: 2},
      );

      expect(metrics.positivePercentage, equals(80.0));
    });

    test('negativePercentage calculates 1-2 star percentage', () {
      const metrics = UserFeedbackMetrics(
        averageRating: 4.5,
        totalReviews: 100,
        ratingDistribution: {5: 50, 4: 30, 3: 15, 2: 3, 1: 2},
      );

      expect(metrics.negativePercentage, equals(5.0));
    });
  });

  group('AnalyticsPeriodExtension', () {
    test('displayName returns correct values', () {
      expect(AnalyticsPeriod.day.displayName, equals('Today'));
      expect(AnalyticsPeriod.week.displayName, equals('This Week'));
      expect(AnalyticsPeriod.month.displayName, equals('This Month'));
      expect(AnalyticsPeriod.quarter.displayName, equals('This Quarter'));
      expect(AnalyticsPeriod.year.displayName, equals('This Year'));
      expect(AnalyticsPeriod.allTime.displayName, equals('All Time'));
      expect(AnalyticsPeriod.custom.displayName, equals('Custom'));
    });

    test('shortName returns correct values', () {
      expect(AnalyticsPeriod.day.shortName, equals('1D'));
      expect(AnalyticsPeriod.week.shortName, equals('1W'));
      expect(AnalyticsPeriod.month.shortName, equals('1M'));
      expect(AnalyticsPeriod.quarter.shortName, equals('3M'));
      expect(AnalyticsPeriod.year.shortName, equals('1Y'));
      expect(AnalyticsPeriod.allTime.shortName, equals('All'));
    });

    test('getDateRange returns valid date ranges', () {
      final (start, end) = AnalyticsPeriod.week.getDateRange();

      expect(start.isBefore(end), isTrue);
      expect(end.difference(start).inDays, greaterThanOrEqualTo(6));
    });
  });
}
