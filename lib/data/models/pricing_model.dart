import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'pricing_model.freezed.dart';
part 'pricing_model.g.dart';

enum PricingType {
  @JsonValue('free')
  free,
  @JsonValue('paid')
  paid,
  @JsonValue('subscription')
  subscription,
  @JsonValue('pay_what_you_want')
  payWhatYouWant,
}

@freezed
class PricingModel with _$PricingModel {
  const PricingModel._();

  const factory PricingModel({
    required String id,
    required String tourId,
    @Default(PricingType.free) PricingType type,
    double? price,
    @Default('EUR') String currency,
    @Default(false) bool allowPayWhatYouWant,
    double? suggestedPrice,
    double? minimumPrice,
    @Default([]) List<PricingTier> tiers,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _PricingModel;

  factory PricingModel.fromJson(Map<String, dynamic> json) =>
      _$PricingModelFromJson(json);

  factory PricingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PricingModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isFree => type == PricingType.free;
  bool get isPaid => type == PricingType.paid;
  bool get isSubscription => type == PricingType.subscription;
  bool get isPayWhatYouWant => type == PricingType.payWhatYouWant;

  String get displayPrice {
    if (isFree) return 'Free';
    if (price == null) return 'Free';
    return '$currency ${price!.toStringAsFixed(2)}';
  }

  String get priceRange {
    if (isFree) return 'Free';
    if (isPayWhatYouWant) {
      if (minimumPrice != null && suggestedPrice != null) {
        return '$currency ${minimumPrice!.toStringAsFixed(2)} - ${suggestedPrice!.toStringAsFixed(2)}';
      }
      return 'Pay what you want';
    }
    return displayPrice;
  }
}

@freezed
class PricingTier with _$PricingTier {
  const PricingTier._();

  const factory PricingTier({
    required String id,
    required String name,
    required double price,
    required String description,
    @Default([]) List<String> features,
    @Default(0) int sortOrder,
  }) = _PricingTier;

  factory PricingTier.fromJson(Map<String, dynamic> json) =>
      _$PricingTierFromJson(json);

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
}

extension PricingTypeExtension on PricingType {
  String get displayName {
    switch (this) {
      case PricingType.free:
        return 'Free';
      case PricingType.paid:
        return 'Paid';
      case PricingType.subscription:
        return 'Subscription';
      case PricingType.payWhatYouWant:
        return 'Pay What You Want';
    }
  }

  String get description {
    switch (this) {
      case PricingType.free:
        return 'Tour is free for everyone';
      case PricingType.paid:
        return 'One-time purchase required';
      case PricingType.subscription:
        return 'Requires active subscription';
      case PricingType.payWhatYouWant:
        return 'Users choose their price';
    }
  }
}
