// ignore_for_file: constant_identifier_names

part of 'ima_player.dart';

enum ImaPlayerEvents {
  TIMELINE_CHANGED,
  MEDIA_ITEM_TRANSITION,
  TRACKS_CHANGED,
  IS_LOADING_CHANGED,
  PLAYBACK_STATE_CHANGED,
  PLAY_WHEN_READY_CHANGED,
  PLAYBACK_SUPPRESSION_REASON_CHANGED,
  IS_PLAYING_CHANGED,
  REPEAT_MODE_CHANGED,
  SHUFFLE_MODE_ENABLED_CHANGED,
  PLAYER_ERROR,
  POSITION_DISCONTINUITY,
  PLAYBACK_PARAMETERS_CHANGED,
  AVAILABLE_COMMANDS_CHANGED,
  MEDIA_METADATA_CHANGED,
  PLAYLIST_METADATA_CHANGED,
  SEEK_BACK_INCREMENT_CHANGED,
  SEEK_FORWARD_INCREMENT_CHANGED,
  MAX_SEEK_TO_PREVIOUS_POSITION_CHANGED,
  TRACK_SELECTION_PARAMETERS_CHANGED,
  AUDIO_ATTRIBUTES_CHANGED,
  AUDIO_SESSION_ID,
  VOLUME_CHANGED,
  SKIP_SILENCE_ENABLED_CHANGED,
  SURFACE_SIZE_CHANGED,
  VIDEO_SIZE_CHANGED,
  RENDERED_FIRST_FRAME,
  CUES,
  METADATA,
  DEVICE_INFO_CHANGED,
  DEVICE_VOLUME_CHANGED
}

enum ImaAdsEvents {
  ALL_ADS_COMPLETED,
  AD_BREAK_FETCH_ERROR,
  CLICKED,
  COMPLETED,
  CUEPOINTS_CHANGED,
  CONTENT_PAUSE_REQUESTED,
  CONTENT_RESUME_REQUESTED,
  FIRST_QUARTILE,
  LOG,
  AD_BREAK_READY,
  MIDPOINT,
  PAUSED,
  RESUMED,
  SKIPPABLE_STATE_CHANGED,
  SKIPPED,
  STARTED,
  TAPPED,
  ICON_TAPPED,
  ICON_FALLBACK_IMAGE_CLOSED,
  THIRD_QUARTILE,
  LOADED,
  AD_PROGRESS,
  AD_BUFFERING,
  AD_BREAK_STARTED,
  AD_BREAK_ENDED,
  AD_PERIOD_STARTED,
  AD_PERIOD_ENDED;
}

class ImaPlayerController {
  ImaPlayerController._(int id)
      : _methodChannel = MethodChannel('dev.gece.imaplayer/$id'),
        _playerEventChannel = EventChannel('dev.gece.imaplayer_events/$id')
            .receiveBroadcastStream(),
        _adsEventChannel = EventChannel('dev.gece.imaplayer_ads_events/$id')
            .receiveBroadcastStream() {
    _playerEventChannel.listen((event) {
      _onPlayerEventController.add(ImaPlayerEvents.values[event]);
    });

    _adsEventChannel.listen((event) {
      _onAdsEventController.add(ImaAdsEvents.values[event]);
    });
  }

  final MethodChannel _methodChannel;
  final Stream<dynamic> _playerEventChannel;
  final Stream<dynamic> _adsEventChannel;

  final _onPlayerEventController = StreamController<ImaPlayerEvents>();
  late final onPlayerEvent = _onPlayerEventController.stream;

  final _onAdsEventController = StreamController<ImaAdsEvents>();
  late final onAdsEvent = _onAdsEventController.stream;

  Future<void> setUrl({required String url}) async {
    return _methodChannel.invokeMethod('setUrl', url);
  }

  Future<bool> play({String? videoUrl}) async {
    return (await _methodChannel.invokeMethod<bool>('play', {
      if (videoUrl != null) 'video_url': videoUrl,
    }))!;
  }

  Future<bool> pause() async {
    return (await _methodChannel.invokeMethod<bool>('pause'))!;
  }

  Future<bool> stop() async {
    return (await _methodChannel.invokeMethod<bool>('stop'))!;
  }

  Future<bool> seekTo(Duration duration) async {
    return (await _methodChannel.invokeMethod<bool>(
        'seek_to', duration.inMilliseconds))!;
  }

  Future<Size> get size async {
    final video = await _methodChannel.invokeMapMethod<String, int>('get_size');
    final height = (video?['height'] ?? 0).toDouble();
    final width = (video?['width'] ?? 0).toDouble();

    return Size(width, height);
  }

  Future<Map> get info async {
    return (await _methodChannel
            .invokeMapMethod<String, dynamic>('get_info')) ??
        {};
  }

  void dispose() {
    _onAdsEventController.close();
    _onPlayerEventController.close();
  }
}
