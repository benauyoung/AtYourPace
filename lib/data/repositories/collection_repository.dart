import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/collection_model.dart';

/// Repository for managing tour collections.
class CollectionRepository {
  final FirebaseFirestore _firestore;

  CollectionRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Gets the collections reference.
  CollectionReference<Map<String, dynamic>> get _collectionsRef =>
      _firestore.collection(FirestoreCollections.collections);

  /// Gets a collection document reference.
  DocumentReference<Map<String, dynamic>> _collectionRef(String collectionId) =>
      _collectionsRef.doc(collectionId);

  // ==================== CRUD Operations ====================

  /// Creates a new collection.
  Future<CollectionModel> create({
    required CollectionModel collection,
  }) async {
    final docRef = _collectionsRef.doc();
    final now = DateTime.now();

    final collectionWithId = collection.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(collectionWithId.toFirestore());
    return collectionWithId;
  }

  /// Gets a collection by ID.
  Future<CollectionModel?> get(String collectionId) async {
    final doc = await _collectionRef(collectionId).get();
    if (!doc.exists) return null;
    return CollectionModel.fromFirestore(doc);
  }

  /// Gets a collection by name.
  Future<CollectionModel?> getByName(String name) async {
    final snapshot = await _collectionsRef
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CollectionModel.fromFirestore(snapshot.docs.first);
  }

  /// Updates a collection.
  Future<CollectionModel> update({
    required String collectionId,
    required CollectionModel collection,
  }) async {
    final updated = collection.copyWith(
      updatedAt: DateTime.now(),
    );

    await _collectionRef(collectionId).update(updated.toFirestore());
    return updated;
  }

  /// Updates specific fields of a collection.
  Future<void> updateFields({
    required String collectionId,
    required Map<String, dynamic> fields,
  }) async {
    await _collectionRef(collectionId).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a collection.
  Future<void> delete(String collectionId) async {
    await _collectionRef(collectionId).delete();
  }

  // ==================== Query Methods ====================

  /// Gets all collections.
  Future<List<CollectionModel>> getAll({
    int? limit,
    bool sortByOrder = true,
  }) async {
    Query<Map<String, dynamic>> query = _collectionsRef;

    if (sortByOrder) {
      query = query.orderBy('sortOrder');
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
  }

  /// Gets featured collections.
  Future<List<CollectionModel>> getFeatured({int limit = 10}) async {
    final snapshot = await _collectionsRef
        .where('isFeatured', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
  }

  /// Gets collections by type.
  Future<List<CollectionModel>> getByType(
    CollectionType type, {
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _collectionsRef
        .where('type', isEqualTo: type.name)
        .orderBy('sortOrder');

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
  }

  /// Gets collections by city.
  Future<List<CollectionModel>> getByCity(
    String city, {
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _collectionsRef
        .where('city', isEqualTo: city)
        .orderBy('sortOrder');

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
  }

  /// Gets collections containing a specific tour.
  Future<List<CollectionModel>> getCollectionsContainingTour(
    String tourId,
  ) async {
    final snapshot = await _collectionsRef
        .where('tourIds', arrayContains: tourId)
        .get();

    return snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
  }

  /// Searches collections by name or tags.
  Future<List<CollectionModel>> search(String query, {int limit = 20}) async {
    // Firestore doesn't support full-text search, so we do basic matching
    // For production, consider using Algolia or Elasticsearch
    final queryLower = query.toLowerCase();

    final snapshot = await _collectionsRef.get();

    return snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .where((collection) {
          final nameLower = collection.name.toLowerCase();
          final descLower = collection.description.toLowerCase();
          final tagsMatch = collection.tags.any(
            (tag) => tag.toLowerCase().contains(queryLower),
          );
          return nameLower.contains(queryLower) ||
              descLower.contains(queryLower) ||
              tagsMatch;
        })
        .take(limit)
        .toList();
  }

  // ==================== Tour Management ====================

  /// Adds a tour to a collection.
  Future<void> addTour({
    required String collectionId,
    required String tourId,
  }) async {
    await _collectionRef(collectionId).update({
      'tourIds': FieldValue.arrayUnion([tourId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes a tour from a collection.
  Future<void> removeTour({
    required String collectionId,
    required String tourId,
  }) async {
    await _collectionRef(collectionId).update({
      'tourIds': FieldValue.arrayRemove([tourId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Adds multiple tours to a collection.
  Future<void> addTours({
    required String collectionId,
    required List<String> tourIds,
  }) async {
    await _collectionRef(collectionId).update({
      'tourIds': FieldValue.arrayUnion(tourIds),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sets the tours in a collection (replaces all).
  Future<void> setTours({
    required String collectionId,
    required List<String> tourIds,
  }) async {
    await _collectionRef(collectionId).update({
      'tourIds': tourIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== Feature Management ====================

  /// Sets featured status for a collection.
  Future<void> setFeatured({
    required String collectionId,
    required bool isFeatured,
  }) async {
    await _collectionRef(collectionId).update({
      'isFeatured': isFeatured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates sort order for a collection.
  Future<void> setSortOrder({
    required String collectionId,
    required int sortOrder,
  }) async {
    await _collectionRef(collectionId).update({
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reorders multiple collections.
  Future<void> reorderCollections(List<String> collectionIds) async {
    final batch = _firestore.batch();

    for (var i = 0; i < collectionIds.length; i++) {
      batch.update(_collectionRef(collectionIds[i]), {
        'sortOrder': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ==================== Initialization ====================

  /// Seeds the predefined Paris collections.
  Future<void> seedParisCollections({
    required String curatorId,
    required String curatorName,
  }) async {
    for (final data in ParisCollections.predefined) {
      final existing = await getByName(data['name'] as String);
      if (existing != null) continue;

      final collection = ParisCollections.createFromPredefined(
        data,
        id: '', // Will be assigned by create()
        curatorId: curatorId,
        curatorName: curatorName,
      );

      await create(collection: collection);
    }
  }

  /// Checks if Paris collections are seeded.
  Future<bool> areParisCollectionsSeeded() async {
    final snapshot = await _collectionsRef
        .where('city', isEqualTo: 'Paris')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // ==================== Stream Methods ====================

  /// Watches all collections.
  Stream<List<CollectionModel>> watchAll() {
    return _collectionsRef.orderBy('sortOrder').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CollectionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Watches featured collections.
  Stream<List<CollectionModel>> watchFeatured() {
    return _collectionsRef
        .where('isFeatured', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CollectionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Watches a single collection.
  Stream<CollectionModel?> watchCollection(String collectionId) {
    return _collectionRef(collectionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CollectionModel.fromFirestore(doc);
    });
  }
}
