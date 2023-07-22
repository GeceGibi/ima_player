part of 'ima_player.dart';

class _ImaPlayerView extends StatelessWidget {
  const _ImaPlayerView({required this.controller});
  final ImaPlayerController controller;

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
    };

    final gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(
        () => EagerGestureRecognizer(),
      ),
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
            controller: controller as AndroidViewController,
            gestureRecognizers: gestureRecognizers,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
      );
    } else {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
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
