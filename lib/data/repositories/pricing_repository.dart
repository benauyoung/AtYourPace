import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/pricing_model.dart';

/// Repository for managing tour pricing data.
class PricingRepository {
  final FirebaseFirestore _firestore;

  PricingRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Gets the pricing document reference for a tour.
  DocumentReference<Map<String, dynamic>> _pricingRef(
    String tourId,
    String pricingId,
  ) {
    return _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.pricing)
        .doc(pricingId);
  }

  /// Gets the pricing collection reference for a tour.
  CollectionReference<Map<String, dynamic>> _pricingCollectionRef(
    String tourId,
  ) {
    return _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.pricing);
  }

  /// Creates a new pricing record for a tour.
  Future<PricingModel> create({
    required String tourId,
    required PricingModel pricing,
  }) async {
    final docRef = _pricingCollectionRef(tourId).doc();
    final now = DateTime.now();

    final pricingWithId = pricing.copyWith(
      id: docRef.id,
      tourId: tourId,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(pricingWithId.toFirestore());
    return pricingWithId;
  }

  /// Gets a pricing record by ID.
  Future<PricingModel?> get({
    required String tourId,
    required String pricingId,
  }) async {
    final doc = await _pricingRef(tourId, pricingId).get();
    if (!doc.exists) return null;
    return PricingModel.fromFirestore(doc);
  }

  /// Gets the active pricing for a tour (usually there's only one).
  Future<PricingModel?> getActivePricing(String tourId) async {
    final snapshot = await _pricingCollectionRef(tourId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return PricingModel.fromFirestore(snapshot.docs.first);
  }

  /// Updates a pricing record.
  Future<PricingModel> update({
    required String tourId,
    required String pricingId,
    required PricingModel pricing,
  }) async {
    final updated = pricing.copyWith(
      updatedAt: DateTime.now(),
    );

    await _pricingRef(tourId, pricingId).update(updated.toFirestore());
    return updated;
  }

  /// Updates specific fields of a pricing record.
  Future<void> updateFields({
    required String tourId,
    required String pricingId,
    required Map<String, dynamic> fields,
  }) async {
    await _pricingRef(tourId, pricingId).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a pricing record.
  Future<void> delete({
    required String tourId,
    required String pricingId,
  }) async {
    await _pricingRef(tourId, pricingId).delete();
  }

  /// Sets a tour to free pricing.
  Future<PricingModel> setFreePricing(String tourId) async {
    final existing = await getActivePricing(tourId);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        type: PricingType.free,
        price: null,
        updatedAt: now,
      );
      await _pricingRef(tourId, existing.id).update(updated.toFirestore());
      return updated;
    }

    return create(
      tourId: tourId,
      pricing: PricingModel(
        id: '',
        tourId: tourId,
        type: PricingType.free,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Sets a tour to paid pricing.
  Future<PricingModel> setPaidPricing({
    required String tourId,
    required double price,
    String currency = 'EUR',
  }) async {
    final existing = await getActivePricing(tourId);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        type: PricingType.paid,
        price: price,
        currency: currency,
        updatedAt: now,
      );
      await _pricingRef(tourId, existing.id).update(updated.toFirestore());
      return updated;
    }

    return create(
      tourId: tourId,
      pricing: PricingModel(
        id: '',
        tourId: tourId,
        type: PricingType.paid,
        price: price,
        currency: currency,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Sets pay-what-you-want pricing.
  Future<PricingModel> setPayWhatYouWantPricing({
    required String tourId,
    double? suggestedPrice,
    double? minimumPrice,
    String currency = 'EUR',
  }) async {
    final existing = await getActivePricing(tourId);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        type: PricingType.payWhatYouWant,
        allowPayWhatYouWant: true,
        suggestedPrice: suggestedPrice,
        minimumPrice: minimumPrice,
        currency: currency,
        updatedAt: now,
      );
      await _pricingRef(tourId, existing.id).update(updated.toFirestore());
      return updated;
    }

    return create(
      tourId: tourId,
      pricing: PricingModel(
        id: '',
        tourId: tourId,
        type: PricingType.payWhatYouWant,
        allowPayWhatYouWant: true,
        suggestedPrice: suggestedPrice,
        minimumPrice: minimumPrice,
        currency: currency,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Adds a pricing tier.
  Future<PricingModel> addTier({
    required String tourId,
    required String pricingId,
    required PricingTier tier,
  }) async {
    final pricing = await get(tourId: tourId, pricingId: pricingId);
    if (pricing == null) {
      throw Exception('Pricing not found');
    }

    final updatedTiers = [...pricing.tiers, tier];
    final updated = pricing.copyWith(
      tiers: updatedTiers,
      updatedAt: DateTime.now(),
    );

    await _pricingRef(tourId, pricingId).update(updated.toFirestore());
    return updated;
  }

  /// Removes a pricing tier by ID.
  Future<PricingModel> removeTier({
    required String tourId,
    required String pricingId,
    required String tierId,
  }) async {
    final pricing = await get(tourId: tourId, pricingId: pricingId);
    if (pricing == null) {
      throw Exception('Pricing not found');
    }

    final updatedTiers = pricing.tiers.where((t) => t.id != tierId).toList();
    final updated = pricing.copyWith(
      tiers: updatedTiers,
      updatedAt: DateTime.now(),
    );

    await _pricingRef(tourId, pricingId).update(updated.toFirestore());
    return updated;
  }

  /// Watches pricing changes for a tour.
  Stream<PricingModel?> watchPricing(String tourId) {
    return _pricingCollectionRef(tourId).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return PricingModel.fromFirestore(snapshot.docs.first);
    });
  }
}
