part of 'ima_player.dart';

class _ImaPlayerView extends StatelessWidget {
  const _ImaPlayerView(
    this.controller, {
    required this.gestureRecognizers,
    required this.onViewCreated,
  });

  final ImaPlayerController controller;
  final void Function(int viewId) onViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  void onPlatformViewCreatedHandler(int viewId) {
    controller._attach(viewId);
    onViewCreated(viewId);
  }

  @override
  Widget build(BuildContext context) {
    const viewType = 'gece.dev/imaplayer';

    final creationParams = {
      'uri': controller.uri,
      'headers': controller.headers,
      'ima_tag': controller.imaTag,
      'is_mixed': controller.options.isMixWithOtherMedia,
      'auto_play': controller.options.autoPlay,
      'initial_volume': controller.options.initialVolume,
      'show_playback_controls': controller.options.showPlaybackControls,
      'ads_loader_settings': controller.adsLoaderSettings.toJson(),
    };

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        creationParams: creationParams,
        layoutDirection: TextDirection.ltr,
        gestureRecognizers: gestureRecognizers,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreatedHandler,
      );
    } else {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        layoutDirection: TextDirection.ltr,
        gestureRecognizers: gestureRecognizers,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreatedHandler,
      );
    }
  }
}
