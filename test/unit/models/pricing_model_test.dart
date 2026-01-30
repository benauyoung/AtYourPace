import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/pricing_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('PricingModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = {
          'id': 'pricing_1',
          'tourId': 'tour_1',
          'type': 'free',
          'currency': 'EUR',
          'allowPayWhatYouWant': false,
          'tiers': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final pricing = PricingModel.fromJson(json);

        expect(pricing.id, equals('pricing_1'));
        expect(pricing.tourId, equals('tour_1'));
        expect(pricing.type, equals(PricingType.free));
        expect(pricing.currency, equals('EUR'));
        expect(pricing.allowPayWhatYouWant, isFalse);
      });

      test('fromJson handles paid pricing with price', () {
        final json = {
          'id': 'pricing_1',
          'tourId': 'tour_1',
          'type': 'paid',
          'price': 9.99,
          'currency': 'USD',
          'allowPayWhatYouWant': false,
          'tiers': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final pricing = PricingModel.fromJson(json);

        expect(pricing.type, equals(PricingType.paid));
        expect(pricing.price, equals(9.99));
        expect(pricing.currency, equals('USD'));
      });

      test('fromJson handles pay_what_you_want type', () {
        final json = {
          'id': 'pricing_1',
          'tourId': 'tour_1',
          'type': 'pay_what_you_want',
          'suggestedPrice': 10.0,
          'minimumPrice': 5.0,
          'currency': 'EUR',
          'allowPayWhatYouWant': true,
          'tiers': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final pricing = PricingModel.fromJson(json);

        expect(pricing.type, equals(PricingType.payWhatYouWant));
        expect(pricing.suggestedPrice, equals(10.0));
        expect(pricing.minimumPrice, equals(5.0));
      });

      test('toJson serializes correctly', () {
        final pricing = createTestPricing(
          id: 'pricing_1',
          tourId: 'tour_1',
          type: PricingType.paid,
          price: 9.99,
          currency: 'USD',
        );

        final json = pricing.toJson();

        expect(json['id'], equals('pricing_1'));
        expect(json['tourId'], equals('tour_1'));
        expect(json['type'], equals('paid'));
        expect(json['price'], equals(9.99));
        expect(json['currency'], equals('USD'));
      });

      test('toFirestore removes id field', () {
        final pricing = createTestPricing(id: 'pricing_1');

        final firestoreData = pricing.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['tourId'], equals('test_tour_1'));
      });
    });

    group('Computed Properties', () {
      test('isFree returns true for free type', () {
        final pricing = createTestPricing(type: PricingType.free);
        expect(pricing.isFree, isTrue);
        expect(pricing.isPaid, isFalse);
      });

      test('isPaid returns true for paid type', () {
        final pricing = createTestPricing(type: PricingType.paid, price: 9.99);
        expect(pricing.isPaid, isTrue);
        expect(pricing.isFree, isFalse);
      });

      test('isSubscription returns true for subscription type', () {
        final pricing = createTestPricing(type: PricingType.subscription);
        expect(pricing.isSubscription, isTrue);
      });

      test('isPayWhatYouWant returns true for pay_what_you_want type', () {
        final pricing = createTestPricing(type: PricingType.payWhatYouWant);
        expect(pricing.isPayWhatYouWant, isTrue);
      });

      test('displayPrice returns Free for free pricing', () {
        final pricing = createTestPricing(type: PricingType.free);
        expect(pricing.displayPrice, equals('Free'));
      });

      test('displayPrice returns formatted price for paid pricing', () {
        final pricing = createTestPricing(
          type: PricingType.paid,
          price: 9.99,
          currency: 'EUR',
        );
        expect(pricing.displayPrice, equals('EUR 9.99'));
      });

      test('priceRange returns formatted range for pay_what_you_want', () {
        final pricing = createTestPricing(
          type: PricingType.payWhatYouWant,
          minimumPrice: 5.0,
          suggestedPrice: 10.0,
          currency: 'EUR',
        );
        expect(pricing.priceRange, equals('EUR 5.00 - 10.00'));
      });

      test('priceRange returns Pay what you want when no prices set', () {
        final pricing = createTestPricing(type: PricingType.payWhatYouWant);
        expect(pricing.priceRange, equals('Pay what you want'));
      });
    });

    group('Enum Handling', () {
      test('all PricingType values serialize correctly', () {
        for (final type in PricingType.values) {
          final pricing = createTestPricing(type: type);
          final json = pricing.toJson();
          final restored = PricingModel.fromJson(json);
          expect(restored.type, equals(type));
        }
      });
    });
  });

  group('PricingTier', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'tier_1',
        'name': 'Basic',
        'price': 9.99,
        'description': 'Basic tier',
        'features': ['Feature 1', 'Feature 2'],
        'sortOrder': 0,
      };

      final tier = PricingTier.fromJson(json);

      expect(tier.id, equals('tier_1'));
      expect(tier.name, equals('Basic'));
      expect(tier.price, equals(9.99));
      expect(tier.description, equals('Basic tier'));
      expect(tier.features.length, equals(2));
      expect(tier.sortOrder, equals(0));
    });

    test('displayPrice formats correctly', () {
      const tier = PricingTier(
        id: 'tier_1',
        name: 'Premium',
        price: 19.99,
        description: 'Premium tier',
      );

      expect(tier.displayPrice, equals('\$19.99'));
    });
  });

  group('PricingTypeExtension', () {
    test('displayName returns correct values', () {
      expect(PricingType.free.displayName, equals('Free'));
      expect(PricingType.paid.displayName, equals('Paid'));
      expect(PricingType.subscription.displayName, equals('Subscription'));
      expect(PricingType.payWhatYouWant.displayName, equals('Pay What You Want'));
    });

    test('description returns correct values', () {
      expect(PricingType.free.description, contains('free'));
      expect(PricingType.paid.description, contains('purchase'));
      expect(PricingType.subscription.description, contains('subscription'));
      expect(PricingType.payWhatYouWant.description, contains('choose'));
    });
  });
}
