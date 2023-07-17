part of 'ima_player.dart';

class _ImaPlayerView extends StatelessWidget {
  const _ImaPlayerView({required this.controller});
  final ImaPlayerController controller;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const viewType = 'dev.gece.imaplayer.view';

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: {
            'auto_play': controller.options.autoPlay,
            'video_url': controller.videoUrl,
            'ima_tag': controller.imaTag,
            'controller_auto_show': controller.options.controllerAutoShow,
            'controller_hide_on_touch':
                controller.options.controllerHideOnTouch,
          },
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        )
          ..addOnPlatformViewCreatedListener((id) {
            params.onPlatformViewCreated(id);
            controller._attach(id);
          })
          ..create();
      },
    );
  }
}
