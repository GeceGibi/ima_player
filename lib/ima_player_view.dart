part of ima_player;

class _ImaPlayerView extends StatelessWidget {
  const _ImaPlayerView({
    required this.controller,
    required this.gestureRecognizers,
  });

  final ImaPlayerController controller;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  Widget build(BuildContext context) {
    const viewType = 'gece.dev/imaplayer';

    final creationParams = {
      'ima_tag': controller.imaTag,
      'is_muted': controller.options.muted,
      'is_mixed': controller.options.isMixWithOtherMedia,
      'auto_play': controller.options.autoPlay,
      'video_url': controller.videoUrl,
      'controller_auto_show': controller.options.controllerAutoShow,
      'controller_hide_on_touch': controller.options.controllerHideOnTouch,
      'show_playback_controls': controller.options.showPlaybackControls,
      'ads_loader_settings': controller.adsLoaderSettings.toJson(),
    };

    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: viewType,
        onCreatePlatformView: (params) {
          return PlatformViewsService.initAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
            ..addOnPlatformViewCreatedListener((id) {
              params.onPlatformViewCreated(id);
              controller._attach(id);
              controller._onViewCreated();
            })
            ..create();
        },
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            controller: controller as AndroidViewController,
            gestureRecognizers: gestureRecognizers,
          );
        },
      );
    } else {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        gestureRecognizers: gestureRecognizers,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          controller._attach(id);
          controller._onViewCreated();
        },
      );
    }
  }
}
