part of 'ima_player.dart';

class _ImaPlayerView extends StatelessWidget {
  const _ImaPlayerView(
    this.creationParams, {
    required this.gestureRecognizers,
    required this.onViewCreated,
  });

  final Map<String, dynamic> creationParams;
  final void Function(int viewId) onViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  Widget build(BuildContext context) {
    const viewType = 'gece.dev/imaplayer_view';

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        creationParams: creationParams,
        gestureRecognizers: gestureRecognizers,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onViewCreated,
      );
    } else {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        gestureRecognizers: gestureRecognizers,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onViewCreated,
      );
    }
  }
}
