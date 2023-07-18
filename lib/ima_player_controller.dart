// ignore_for_file: constant_identifier_names

part of 'ima_player.dart';

class ImaPlayerController {
  ImaPlayerController({
    required this.videoUrl,
    this.imaTag,
    this.options = const ImaPlayerOptions(),
  });

  final String videoUrl;
  final String? imaTag;
  final ImaPlayerOptions options;

  MethodChannel? _methodChannel;
  EventChannel? _eventChannelPlayer;
  EventChannel? _eventChannelAds;

  final _onPlayerEventController = StreamController<ImaPlayerEvents>();
  late final onPlayerEvent = _onPlayerEventController.stream;

  final _onAdsEventController = StreamController<ImaAdsEvents>();
  late final onAdsEvent = _onAdsEventController.stream;

  void _attach(int viewId) {
    _methodChannel = MethodChannel('dev.gece.imaplayer/$viewId');
    _eventChannelPlayer = EventChannel('dev.gece.imaplayer_events/$viewId');
    _eventChannelAds = EventChannel('dev.gece.imaplayer_ads_events/$viewId');

    _eventChannelPlayer!.receiveBroadcastStream().listen((event) {
      final status = ImaPlayerEvents.values[event];

      _onPlayerEventController.add(status);
    });

    _eventChannelAds!.receiveBroadcastStream().listen((event) {
      final status = ImaAdsEvents.values[event];

      _onAdsEventController.add(status);
    });
  }

  Future<bool> play({String? videoUrl}) async {
    return (await _methodChannel?.invokeMethod<bool>('play', {
          if (videoUrl != null) 'video_url': videoUrl,
        })) ??
        false;
  }

  Future<bool> pause() async {
    return (await _methodChannel?.invokeMethod<bool>('pause')) ?? false;
  }

  Future<bool> stop() async {
    return (await _methodChannel?.invokeMethod<bool>('stop')) ?? false;
  }

  Future<bool> seekTo(Duration duration) async {
    return (await _methodChannel?.invokeMethod<bool>(
            'seek_to', duration.inMilliseconds)) ??
        false;
  }

  Future<bool> setVolume(double volume) async {
    return (await _methodChannel?.invokeMethod<bool>('set_volume', volume)) ??
        false;
  }

  Future<Size> getSize() async {
    final video = await _methodChannel?.invokeMapMethod<String, int>(
      'get_size',
    );

    final height = (video?['height'] ?? 0).toDouble();
    final width = (video?['width'] ?? 0).toDouble();

    return Size(width, height);
  }

  Future<ImaPlayerInfo> getInfo() async {
    return ImaPlayerInfo.fromJson(
      (await _methodChannel?.invokeMapMethod<String, dynamic>('get_info')) ??
          {},
    );
  }

  void dispose() {
    _onAdsEventController.close();
    _onPlayerEventController.close();
  }
}
