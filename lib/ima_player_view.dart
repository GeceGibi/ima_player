part of 'ima_player.dart';

class ImaPlayerView extends StatelessWidget {
  const ImaPlayerView({
    required this.videoURL,
    this.vastURL,
    this.onViewCreated,
    super.key,
  });

  final String videoURL;
  final String? vastURL;
  final void Function(ImaPlayerController controller)? onViewCreated;

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
            'auto_play': true,
            'video_url': videoURL,
            'vast_url': vastURL,
            'controller_auto_show': true,
            'controller_hide_on_touch': true,
          },
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener((id) {
            params.onPlatformViewCreated(id);
            onViewCreated?.call(ImaPlayerController._(params.id));
          })
          ..create();
      },
    );
  }
}
