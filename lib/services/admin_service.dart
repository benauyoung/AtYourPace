import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';

/// Audit log action types
enum AuditAction {
  tourApproved,
  tourRejected,
  tourHidden,
  tourUnhidden,
  tourFeatured,
  tourUnfeatured,
  userRoleChanged,
  userBanned,
  userUnbanned,
  settingsUpdated,
}

/// Audit log entry model
class AuditLogEntry {
  final String id;
  final String adminId;
  final String adminEmail;
  final AuditAction action;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  AuditLogEntry({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    this.targetId,
    this.targetType,
    this.details,
    required this.timestamp,
  });

  factory AuditLogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogEntry(
      id: doc.id,
      adminId: data['adminId'] as String,
      adminEmail: data['adminEmail'] as String? ?? 'Unknown',
      action: AuditAction.values.firstWhere(
        (e) => e.name == data['action'],
        orElse: () => AuditAction.settingsUpdated,
      ),
      targetId: data['targetId'] as String?,
      targetType: data['targetType'] as String?,
      details: data['details'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'adminId': adminId,
      'adminEmail': adminEmail,
      'action': action.name,
      if (targetId != null) 'targetId': targetId,
      if (targetType != null) 'targetType': targetType,
      if (details != null) 'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  String get actionDescription {
    switch (action) {
      case AuditAction.tourApproved:
        return 'Approved tour';
      case AuditAction.tourRejected:
        return 'Rejected tour';
      case AuditAction.tourHidden:
        return 'Hid tour';
      case AuditAction.tourUnhidden:
        return 'Unhid tour';
      case AuditAction.tourFeatured:
        return 'Featured tour';
      case AuditAction.tourUnfeatured:
        return 'Unfeatured tour';
      case AuditAction.userRoleChanged:
        return 'Changed user role';
      case AuditAction.userBanned:
        return 'Banned user';
      case AuditAction.userUnbanned:
        return 'Unbanned user';
      case AuditAction.settingsUpdated:
        return 'Updated settings';
    }
  }
}

/// Service for admin operations including tour review and user management.
class AdminService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  User? get currentUser => _auth.currentUser;

  // ==================== Audit Logging ====================

  /// Logs an admin action to the audit log
  Future<void> _logAction({
    required AuditAction action,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? details,
  }) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('auditLogs').add({
        'adminId': currentUser!.uid,
        'adminEmail': currentUser!.email ?? 'Unknown',
        'action': action.name,
        if (targetId != null) 'targetId': targetId,
        if (targetType != null) 'targetType': targetType,
        if (details != null) 'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't fail the main operation if logging fails
      // In production, you might want to log this to a monitoring service
    }
  }

  /// Gets audit logs with optional filtering
  Future<List<AuditLogEntry>> getAuditLogs({
    String? adminId,
    AuditAction? action,
    String? targetId,
    int limit = 50,
    DateTime? startAfter,
  }) async {
    await _verifyAdminRole();

    Query<Map<String, dynamic>> query = _firestore
        .collection('auditLogs')
        .orderBy('timestamp', descending: true);

    if (adminId != null) {
      query = query.where('adminId', isEqualTo: adminId);
    }

    if (action != null) {
      query = query.where('action', isEqualTo: action.name);
    }

    if (targetId != null) {
      query = query.where('targetId', isEqualTo: targetId);
    }

    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.map((doc) => AuditLogEntry.fromFirestore(doc)).toList();
  }

  /// Gets audit logs for a specific target (tour or user)
  Future<List<AuditLogEntry>> getTargetAuditLogs(String targetId, {int limit = 20}) async {
    await _verifyAdminRole();

    final snapshot = await _firestore
        .collection('auditLogs')
        .where('targetId', isEqualTo: targetId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => AuditLogEntry.fromFirestore(doc)).toList();
  }

  // ==================== Tour Management ====================

  /// Approves a tour submission.
  /// Updates status to 'approved'. Cloud Function (onTourApproved) will:
  /// - Promote draft version to live
  /// - Archive old live version
  /// - Mark review queue as completed
  Future<void> approveTour(String tourId, {String? notes}) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'lastReviewedAt': FieldValue.serverTimestamp(),
      'approvedBy': currentUser!.uid,
      if (notes != null) 'approvalNotes': notes,
    });

    await _logAction(
      action: AuditAction.tourApproved,
      targetId: tourId,
      targetType: 'tour',
      details: notes != null ? {'notes': notes} : null,
    );
  }

  /// Rejects a tour submission with a reason.
  /// Updates status to 'rejected'. Cloud Function (onTourRejected) will:
  /// - Mark review queue as completed
  /// - Update draft version with review timestamp
  Future<void> rejectTour(String tourId, String reason) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'lastReviewedAt': FieldValue.serverTimestamp(),
      'rejectedBy': currentUser!.uid,
      'rejectionReason': reason,
    });

    await _logAction(
      action: AuditAction.tourRejected,
      targetId: tourId,
      targetType: 'tour',
      details: {'reason': reason},
    );
  }

  /// Hides a tour from public view (soft delete for published tours).
  Future<void> hideTour(String tourId, {String? reason}) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'status': 'hidden',
      'hiddenAt': FieldValue.serverTimestamp(),
      'hiddenBy': currentUser!.uid,
      if (reason != null) 'hideReason': reason,
    });

    await _logAction(
      action: AuditAction.tourHidden,
      targetId: tourId,
      targetType: 'tour',
      details: reason != null ? {'reason': reason} : null,
    );
  }

  /// Unhides a tour (makes it visible again).
  Future<void> unhideTour(String tourId) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'status': 'approved',
      'hiddenAt': FieldValue.delete(),
      'hiddenBy': FieldValue.delete(),
      'hideReason': FieldValue.delete(),
    });

    await _logAction(
      action: AuditAction.tourUnhidden,
      targetId: tourId,
      targetType: 'tour',
    );
  }

  /// Features a tour (promotes it to featured status).
  Future<void> featureTour(String tourId, bool featured) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'featured': featured,
      'featuredAt': featured ? FieldValue.serverTimestamp() : FieldValue.delete(),
      'featuredBy': featured ? currentUser!.uid : FieldValue.delete(),
    });

    await _logAction(
      action: featured ? AuditAction.tourFeatured : AuditAction.tourUnfeatured,
      targetId: tourId,
      targetType: 'tour',
    );
  }

  // ==================== User Management ====================

  /// Updates a user's role.
  Future<void> updateUserRole(String userId, UserRole role, {String? reason}) async {
    await _verifyAdminRole();

    // Get current role for logging
    final userDoc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .get();
    final previousRole = userDoc.data()?['role'] as String?;

    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'role': role.name,
      'roleUpdatedAt': FieldValue.serverTimestamp(),
      'roleUpdatedBy': currentUser!.uid,
    });

    await _logAction(
      action: AuditAction.userRoleChanged,
      targetId: userId,
      targetType: 'user',
      details: {
        'previousRole': previousRole,
        'newRole': role.name,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Bans a user (prevents them from accessing the app).
  Future<void> banUser(String userId, {String? reason}) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'banned': true,
      'bannedAt': FieldValue.serverTimestamp(),
      'bannedBy': currentUser!.uid,
      if (reason != null) 'banReason': reason,
    });

    await _logAction(
      action: AuditAction.userBanned,
      targetId: userId,
      targetType: 'user',
      details: reason != null ? {'reason': reason} : null,
    );
  }

  /// Unbans a user.
  Future<void> unbanUser(String userId) async {
    await _verifyAdminRole();

    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'banned': false,
      'bannedAt': FieldValue.delete(),
      'bannedBy': FieldValue.delete(),
      'banReason': FieldValue.delete(),
    });

    await _logAction(
      action: AuditAction.userUnbanned,
      targetId: userId,
      targetType: 'user',
    );
  }

  // ==================== Statistics ====================

  /// Gets tour statistics for admin dashboard.
  Future<Map<String, dynamic>> getTourStats() async {
    await _verifyAdminRole();

    final toursSnapshot = await _firestore
        .collection(FirestoreCollections.tours)
        .get();

    int totalTours = toursSnapshot.size;
    int draftTours = 0;
    int pendingTours = 0;
    int liveTours = 0;
    int featuredTours = 0;
    int rejectedTours = 0;
    int hiddenTours = 0;

    for (final doc in toursSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      final featured = data['featured'] as bool? ?? false;

      switch (status) {
        case 'draft':
          draftTours++;
          break;
        case 'pending_review':
          pendingTours++;
          break;
        case 'approved':
          liveTours++;
          break;
        case 'rejected':
          rejectedTours++;
          break;
        case 'hidden':
          hiddenTours++;
          break;
      }

      if (featured) {
        featuredTours++;
      }
    }

    return {
      'totalTours': totalTours,
      'draftTours': draftTours,
      'pendingTours': pendingTours,
      'liveTours': liveTours,
      'featuredTours': featuredTours,
      'rejectedTours': rejectedTours,
      'hiddenTours': hiddenTours,
    };
  }

  /// Gets user statistics for admin dashboard.
  Future<Map<String, dynamic>> getUserStats() async {
    await _verifyAdminRole();

    final usersSnapshot = await _firestore
        .collection(FirestoreCollections.users)
        .get();

    int totalUsers = usersSnapshot.size;
    int regularUsers = 0;
    int creators = 0;
    int admins = 0;
    int bannedUsers = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final role = data['role'] as String?;
      final banned = data['banned'] as bool? ?? false;

      switch (role) {
        case 'user':
          regularUsers++;
          break;
        case 'creator':
          creators++;
          break;
        case 'admin':
          admins++;
          break;
      }

      if (banned) {
        bannedUsers++;
      }
    }

    return {
      'totalUsers': totalUsers,
      'regularUsers': regularUsers,
      'creators': creators,
      'admins': admins,
      'bannedUsers': bannedUsers,
    };
  }

  /// Verifies that the current user has admin role.
  Future<void> _verifyAdminRole() async {
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    final userDoc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(currentUser!.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final userData = userDoc.data()!;
    final role = userData['role'] as String?;

    if (role != 'admin') {
      throw Exception('Admin permission required');
    }
  }
}
