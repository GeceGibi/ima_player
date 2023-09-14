part of ima_player;

class ImaVideoInfo {
  ImaVideoInfo.fromJson(Map<String, dynamic> json)
      : currentPosition = json['current_position'] ?? 0.0,
        totalDuration = json['total_duration'] ?? 0.0,
        isBuffering = json['is_buffering'] ?? false,
        isPlaying = json['is_playing'] ?? false,
        size = Size(
          (json['width'] ?? 0).toDouble(),
          (json['height'] ?? 0).toDouble(),
        );

  final double currentPosition;
  final double totalDuration;
  final bool isPlaying;
  final bool isBuffering;
  final Size size;

  @override
  String toString() =>
      'ImaPlayerInfo(currentPosition: $currentPosition, totalDuration: $totalDuration, isPlaying: $isPlaying, isBuffering: $isBuffering, size: $size)';
}

class ImaAdInfo {
  ImaAdInfo.fromJson(Map<String, dynamic> json)
      : adSkipTimeOffset = json['ad_skip_time_offset'] ?? 0.0,
        adDuration = json['ad_duration'] ?? 0.0,
        adCurrentPosition = json['ad_current_position'] ?? 0.0,
        adTitle = json['ad_title'] ?? '',
        adType = json['ad_type'] ?? '',
        size = Size(
          (json['ad_width'] ?? 0).toDouble(),
          (json['ad_height'] ?? 0).toDouble(),
        ),

        ///
        isPlaying = json['is_playing'] ?? false,
        isBuffering = json['is_buffering'] ?? false,
        isSkippable = json['is_skippable'] ?? false,
        isUiDisabled = json['is_ui_disabled'] ?? false,

        ///
        totalAdCount = json['total_ad_count'] ?? 0;

  final double adCurrentPosition;
  final String adTitle;
  final double adDuration;
  final Size size;
  final String adType;
  final double adSkipTimeOffset;

  final bool isPlaying;
  final bool isBuffering;
  final bool isSkippable;
  final bool isUiDisabled;

  final int totalAdCount;

  @override
  String toString() =>
      'ImaAdInfo(adSkipTimeOffset: $adSkipTimeOffset, adDuration: $adDuration, adCurrentPosition: $adCurrentPosition, size: $size, adTitle: $adTitle, adType: $adType, isPlaying: $isPlaying, isBuffering: $isBuffering, isSkippable: $isSkippable, isUiDisabled: $isUiDisabled, totalAdCount: $totalAdCount)';
}

class ImaAdsLoaderSettings {
  const ImaAdsLoaderSettings({
    this.autoPlayAdBreaks = true,
    this.enableDebugMode = false,
    this.language = "en",
    this.ppid,
  });

  final String? ppid;

  /// https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/localization?hl=en
  final String language;
  final bool enableDebugMode;
  final bool autoPlayAdBreaks;

  Map<String, dynamic> toJson() => {
        if (ppid != null) 'ppid': ppid,
        'language': language,
        'enable_debug_mode': enableDebugMode,
        'auto_play_ad_breaks': autoPlayAdBreaks,
      };
}
