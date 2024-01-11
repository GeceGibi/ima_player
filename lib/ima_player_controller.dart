// ignore_for_file: constant_identifier_names

part of 'ima_player.dart';

typedef ViewCreatedCallback = void Function();

final _kControllerInstances = <ImaPlayerController>[];

class ImaPlayerController extends ValueNotifier<PlayerEvent> {
  ImaPlayerController.network(
    this.uri, {
    this.imaTag,
    this.headers = const {},
    this.options = const ImaPlayerOptions(),
    this.adsLoaderSettings = const ImaAdsLoaderSettings(),
  }) : super(PlayerEvent(volume: options.initialVolume));

  ImaPlayerController.asset(
    String asset, {
    this.imaTag,
    this.options = const ImaPlayerOptions(),
    this.adsLoaderSettings = const ImaAdsLoaderSettings(),
  })  : uri = 'asset://$asset',
        headers = const {},
        super(PlayerEvent(volume: options.initialVolume));

  final String uri;
  final String? imaTag;
  final ImaPlayerOptions options;
  final ImaAdsLoaderSettings adsLoaderSettings;
  final Map<String, String> headers;

  ///
  MethodChannel? _methodChannel;
  EventChannel? _eventChannel;

  var _isDisposed = false;
  var _isPlayingAd = false;

  ///
  final _adEventStreamController = StreamController<AdEventType>.broadcast();
  Stream<AdEventType> get onAdEvent => _adEventStreamController.stream;

  ///
  final _onReadyCompleter = Completer<void>();
  Future<void> get onPlayerReady => _onReadyCompleter.future;

  ///
  final _onAdLoadedStreamController = StreamController<AdInfo>.broadcast();
  Stream<AdInfo> get onAdLoaded => _onAdLoadedStreamController.stream;

  ///
  StreamSubscription? _eventListener;

  void _attach(int viewId) {
    _methodChannel = MethodChannel('gece.dev/imaplayer/$viewId');
    _eventChannel = EventChannel('gece.dev/imaplayer/$viewId/events');

    _kControllerInstances.add(this);

    _eventListener = _eventChannel?.receiveBroadcastStream().listen((event) {
      switch (event["type"]) {
        case "ready":
          if (!_onReadyCompleter.isCompleted) {
            _onReadyCompleter.complete();
          }

          value = value.copyWith(isReady: true);

        case "playing":
          value = value.copyWith(isPlaying: true, isEnded: false);

        case "paused":
          value = value.copyWith(isPlaying: false);

        case "ended":
          value = value.copyWith(isEnded: true, isPlaying: false);

        case "buffered_duration":
          value = value.copyWith(
            bufferedDuration: Duration(milliseconds: event["duration"]),
          );

        case "duration":
          value = value.copyWith(
            duration: Duration(milliseconds: event["value"]),
          );

        case "volume":
          value = value.copyWith(volume: event["volume"]);

        case "buffering_start":
          value = value.copyWith(isBuffering: true);

        case "buffering_end":
          value = value.copyWith(isBuffering: false);

        case "size_changed":
          final size = List<num>.from(event["size"]).map(
            (e) => e.toDouble(),
          );

          value = value.copyWith(size: Size(size.first, size.last));

        case "ad_info":
          _onAdLoadedStreamController.add(
            AdInfo.fromJson(Map<String, dynamic>.from(event['info'])),
          );

        case "ad_event":
          final adEvent = AdEventType.fromString(event["value"]);

          if (adEvent
              case AdEventType.content_pause_requested ||
                  AdEventType.started ||
                  AdEventType.resumed) {
            _isPlayingAd = true;
          } else if (adEvent
              case AdEventType.content_resume_requested ||
                  AdEventType.paused ||
                  AdEventType.completed ||
                  AdEventType.all_ads_completed) {
            _isPlayingAd = false;
          }

          _adEventStreamController.add(adEvent);

          value = value.copyWith(isPlayingAd: _isPlayingAd);
      }
    })
      ?..onError((error) {
        if (error is PlatformException) {
          switch (error.code) {
            case "player_error":
              _onReadyCompleter.completeError(error);
              break;

            case "ad_error":
              _onAdLoadedStreamController.addError(error);
              break;

            default:
              throw error;
          }
        }
      });
  }

  /// Pauses all ima players but excluded this one
  static void pauseImaPlayers([ImaPlayerController? excludedOne]) {
    for (final instance in _kControllerInstances) {
      if (!instance._isDisposed) {
        if (excludedOne == instance) {
          continue;
        }

        instance.pause();
      }
    }
  }

  /// Play or resume video content or ads <br />
  /// If want to play new video with same player just pass `uri`
  Future<void> play({String? uri}) async {
    if (_isDisposed) return;
    await _methodChannel?.invokeMethod<bool>('play', uri);
  }

  /// Pause video content or ads
  Future<void> pause() async {
    if (_isDisposed) return;
    await _methodChannel?.invokeMethod<bool>('pause');
  }

  /// Just work on video content
  Future<void> stop() async {
    if (_isDisposed) return;
    await _methodChannel?.invokeMethod<bool>('stop');
  }

  Future<Duration> get position async {
    if (_isDisposed) return Duration.zero;
    final dur = await _methodChannel?.invokeMethod<int>('current_position');
    return Duration(milliseconds: dur ?? 0);
  }

  /// Seek to specific position
  Future<void> seekTo(Duration duration) async {
    if (_isDisposed) return;

    await _methodChannel?.invokeMethod<bool>(
        'seek_to',
        Platform.isAndroid
            ? duration.inMilliseconds
            : duration.inMilliseconds / 1000);

    if (Platform.isIOS && value.isEnded) {
      play();
    }
  }

  /// Skips the current ad. AdsManager.skip() only skips ads if IMA does not render the 'Skip ad' button. <br />
  /// [Google Document](https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsManager.html#skip())
  Future<void> skipAd() async {
    if (_isDisposed) return;
    await _methodChannel?.invokeMethod<bool>('skip_ad');
  }

  Future<void> setVolume(double volume) async {
    if (_isDisposed) return;
    await _methodChannel?.invokeMethod<bool>('set_volume', volume);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventListener?.cancel();
    _kControllerInstances.remove(this);
    _onAdLoadedStreamController.close();
    _adEventStreamController.close();
    _methodChannel?.invokeMethod('dispose');
    super.dispose();
  }
}
