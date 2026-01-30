// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PricingModelImpl _$$PricingModelImplFromJson(Map<String, dynamic> json) =>
    _$PricingModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      type: $enumDecodeNullable(_$PricingTypeEnumMap, json['type']) ??
          PricingType.free,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      allowPayWhatYouWant: json['allowPayWhatYouWant'] as bool? ?? false,
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble(),
      minimumPrice: (json['minimumPrice'] as num?)?.toDouble(),
      tiers: (json['tiers'] as List<dynamic>?)
              ?.map((e) => PricingTier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$PricingModelImplToJson(_$PricingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'type': _$PricingTypeEnumMap[instance.type]!,
      'price': instance.price,
      'currency': instance.currency,
      'allowPayWhatYouWant': instance.allowPayWhatYouWant,
      'suggestedPrice': instance.suggestedPrice,
      'minimumPrice': instance.minimumPrice,
      'tiers': instance.tiers,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$PricingTypeEnumMap = {
  PricingType.free: 'free',
  PricingType.paid: 'paid',
  PricingType.subscription: 'subscription',
  PricingType.payWhatYouWant: 'pay_what_you_want',
};

_$PricingTierImpl _$$PricingTierImplFromJson(Map<String, dynamic> json) =>
    _$PricingTierImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PricingTierImplToJson(_$PricingTierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'features': instance.features,
      'sortOrder': instance.sortOrder,
    };
