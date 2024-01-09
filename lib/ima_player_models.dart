// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ima_player_models.freezed.dart';
part 'ima_player_models.g.dart';

//! ----------------------------------------------------------------------------
enum AdEventType {
  all_ads_completed,
  ad_break_fetch_error,
  clicked,
  completed,
  cuepoints_changed,
  content_pause_requested,
  content_resume_requested,
  first_quartile,
  log,
  ad_break_ready,
  midpoint,
  paused,
  resumed,
  skippable_state_changed,
  skipped,
  started,
  tapped,
  icon_tapped,
  icon_fallback_image_closed,
  third_quartile,
  loaded,
  ad_progress,
  ad_buffering,
  ad_break_started,
  ad_break_ended,
  ad_period_started,
  ad_period_ended,
  unknown;

  static AdEventType fromString(String? event) {
    for (final value in values) {
      if (value.name == event || value.name == '${event}D') {
        return value;
      }
    }

    return AdEventType.unknown;
  }
}

Size _sizeFromJson(List data) {
  final resolution = List<num>.from(data);
  return Size(resolution.first.toDouble(), resolution.last.toDouble());
}

List<num> _sizeToJson(Size size) {
  return [size.width, size.height];
}

Duration _durationFromJson(num milliseconds) {
  return Duration(seconds: milliseconds.toInt());
}

int _durationToJson(Duration duration) {
  return duration.inSeconds;
}

@freezed
class AdInfo with _$AdInfo {
  const factory AdInfo({
    @Default(Duration.zero)
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    Duration duration,
    @Default(Duration.zero)
    @JsonKey(
      name: 'skip_time_offset',
      fromJson: _durationFromJson,
      toJson: _durationToJson,
    )
    Duration skipTimeOffset,
    @Default('') String adid,
    @Default(Size.zero)
    @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson)
    Size size,
    @Default('') @JsonKey(name: 'advertiser_name') String advertiserName,
    @Default('') @JsonKey(name: 'ad_system') String adSystem,
    @Default('') @JsonKey(name: 'content_type') String contentType,
    @Default('') String title,
    @Default('') String description,
    @Default(0) int bitrate,
    @Default(false) bool skippable,
    @Default(true) bool linear,
    @Default(false) @JsonKey(name: 'ui_disabled') bool uiDisabled,
    @Default(false) @JsonKey(name: 'is_bumper') bool isBumper,
    @Default(0) @JsonKey(name: 'total_ads') int totalAds,
  }) = _AdInfo;

  factory AdInfo.fromJson(Map<String, dynamic> json) => _$AdInfoFromJson(json);
}

//! ----------------------------------------------------------------------------
@freezed
class PlayerEvent with _$PlayerEvent {
  const factory PlayerEvent({
    @Default(false) bool isBuffering,
    @Default(false) bool isPlaying,
    @Default(false) bool isPlayingAd,
    @Default(false) bool isReady,
    @Default(false) bool isEnded,
    @Default(0.0) double volume,
    @Default(Size.zero) Size size,
    @Default(Duration.zero) Duration duration,
  }) = _PlayerEvent;
}

//! ----------------------------------------------------------------------------
class ImaAdsLoaderSettings {
  const ImaAdsLoaderSettings({
    this.enableDebugMode = false,
    this.language = "en",
    this.ppid,
  });

  final String? ppid;

  /// https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/localization?hl=en
  final String language;
  final bool enableDebugMode;

  Map<String, dynamic> toJson() => {
        if (ppid != null) 'ppid': ppid,
        'language': language,
        'enable_debug_mode': enableDebugMode,
      };
}
