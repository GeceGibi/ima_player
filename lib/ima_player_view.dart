part of 'ima_player.dart';

class _ImaPlayerView extends StatefulWidget {
  const _ImaPlayerView(
    this.controller, {
    required this.gestureRecognizers,
  });

  final ImaPlayerController controller;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<_ImaPlayerView> createState() => _ImaPlayerViewState();
}

class _ImaPlayerViewState extends State<_ImaPlayerView> {
  @override
  Widget build(BuildContext context) {
    const viewType = 'gece.dev/imaplayer';

    final creationParams = {
      'uri': widget.controller.uri,
      'headers': widget.controller.headers,
      'ima_tag': widget.controller.imaTag,
      'is_mixed': widget.controller.options.isMixWithOtherMedia,
      'auto_play': widget.controller.options.autoPlay,
      'initial_volume': widget.controller.options.initialVolume,
      'show_playback_controls': widget.controller.options.showPlaybackControls,
      'ads_loader_settings': widget.controller.adsLoaderSettings.toJson(),
    };

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        creationParams: creationParams,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._attach(id);
          widget.controller._onViewCreated();
        },
      );
    } else {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        gestureRecognizers: widget.gestureRecognizers,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._attach(id);
          widget.controller._onViewCreated();
        },
      );
    }
  }
}
