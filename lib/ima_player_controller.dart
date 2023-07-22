// ignore_for_file: constant_identifier_names

part of 'ima_player.dart';

typedef ViewCreatedCallback = void Function();

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
  EventChannel? _eventChannel;

  final _onPlayerEventController = StreamController<ImaPlayerEvents?>();
  late final onPlayerEvent = _onPlayerEventController.stream;

  final _onAdsEventController = StreamController<ImaAdsEvents>();
  late final onAdsEvent = _onAdsEventController.stream;

  void _attach(int viewId) {
    _methodChannel = MethodChannel('gece.dev/imaplayer/$viewId');
    _eventChannel = EventChannel('gece.dev/imaplayer/$viewId/events');

    _eventChannel!.receiveBroadcastStream().listen((event) {
      if (event is Map && event.containsKey('type')) {
        final value = event["value"];

        switch (event['type']) {
          case 'ads':
            final status = ImaAdsEvents.fromString(
              (value as String?)?.toUpperCase().replaceAll(' ', '_'),
            );

            _onAdsEventController.add(status);
            break;

          case 'player':
            final status = ImaPlayerEvents.fromString(value);
            _onPlayerEventController.add(status);
            break;
        }
      }
    });
  }

  void _onViewCreated() {
    _methodChannel?.invokeMethod('view_created');
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
            'seek_to',
            Platform.isAndroid
                ? duration.inMilliseconds
                : duration.inMilliseconds / 1000)) ??
        false;
  }

  Future<bool> skipAd() async {
    return (await _methodChannel?.invokeMethod<bool>('skip_ad')) ?? false;
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
    _methodChannel?.invokeMethod('dispose').then((value) {
      _onAdsEventController.close();
      _onPlayerEventController.close();
    });
  }
}
