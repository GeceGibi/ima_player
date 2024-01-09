// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ima_player_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdInfoImpl _$$AdInfoImplFromJson(Map<String, dynamic> json) => _$AdInfoImpl(
      duration: json['duration'] == null
          ? Duration.zero
          : _durationFromJson(json['duration'] as num),
      skipTimeOffset: json['skip_time_offset'] == null
          ? Duration.zero
          : _durationFromJson(json['skip_time_offset'] as num),
      adid: json['adid'] as String? ?? '',
      size: json['size'] == null
          ? Size.zero
          : _sizeFromJson(json['size'] as List),
      advertiserName: json['advertiser_name'] as String? ?? '',
      adSystem: json['ad_system'] as String? ?? '',
      contentType: json['content_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bitrate: json['bitrate'] as int? ?? 0,
      skippable: json['skippable'] as bool? ?? false,
      linear: json['linear'] as bool? ?? true,
      uiDisabled: json['ui_disabled'] as bool? ?? false,
      isBumper: json['is_bumper'] as bool? ?? false,
      totalAds: json['total_ads'] as int? ?? 0,
    );

Map<String, dynamic> _$$AdInfoImplToJson(_$AdInfoImpl instance) =>
    <String, dynamic>{
      'duration': _durationToJson(instance.duration),
      'skip_time_offset': _durationToJson(instance.skipTimeOffset),
      'adid': instance.adid,
      'size': _sizeToJson(instance.size),
      'advertiser_name': instance.advertiserName,
      'ad_system': instance.adSystem,
      'content_type': instance.contentType,
      'title': instance.title,
      'description': instance.description,
      'bitrate': instance.bitrate,
      'skippable': instance.skippable,
      'linear': instance.linear,
      'ui_disabled': instance.uiDisabled,
      'is_bumper': instance.isBumper,
      'total_ads': instance.totalAds,
    };
