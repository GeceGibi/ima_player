part of 'ima_player.dart';

class ImaPlayerUI extends StatefulWidget {
  const ImaPlayerUI({
    super.key,
    required this.player,
  });

  final ImaPlayer player;

  @override
  State<ImaPlayerUI> createState() => _ImaPlayerUIState();
}

class _ImaPlayerUIState extends State<ImaPlayerUI> {
  var aspectRatio = 16 / 9;
  var uiHidden = false;

  ImaPlayerController get controller => widget.player.controller;

  Timer? uiTimer;
  void watchUi() {
    uiTimer?.cancel();
    uiTimer = Timer(const Duration(seconds: 3), hideUi);
  }

  void hideUi() {
    if (uiHidden || !controller.value.isPlaying || controller.value.isEnded) {
      return;
    }

    uiTimer?.cancel();
    setState(() {
      uiHidden = true;
    });
  }

  void showUi() {
    if (!uiHidden) {
      return;
    }

    uiTimer?.cancel();

    watchUi();
    setState(() {
      uiHidden = false;
    });
  }

  void toggleUi() {
    if (uiHidden) {
      showUi();
    } else {
      hideUi();
    }
  }

  void togglePlay() {
    if (!controller.value.isReady) {
      return;
    }

    if (controller.value.isEnded) {
      replay();
    } else if (controller.value.isPlaying) {
      showUi();
      controller.pause();
    } else {
      watchUi();
      controller.play();
    }
  }

  void replay() {
    if (!controller.value.isReady) {
      return;
    }

    controller.seekTo(Duration.zero);
    watchUi();
  }

  void muteToggle() {
    if (!controller.value.isReady) {
      return;
    }

    if (controller.value.volume == 0.0) {
      controller.setVolume(1.0);
    } else {
      controller.setVolume(0.0);
    }

    watchUi();
  }

  final backwardAndForwardStep = const Duration(seconds: 5);
  Future<void> forwardVideo() async {
    if (!controller.value.isReady || !controller.value.isPlaying) {
      return;
    }

    watchUi();

    final position = await controller.position;
    var nextPosition = position + backwardAndForwardStep;

    if (nextPosition >= controller.value.duration) {
      nextPosition = controller.value.duration;
    }

    controller.seekTo(nextPosition);
  }

  Future<void> backwardVideo() async {
    if (!controller.value.isReady || !controller.value.isPlaying) {
      return;
    }

    watchUi();

    final position = await controller.position;
    var nextPosition = position - backwardAndForwardStep;

    if (nextPosition <= Duration.zero) {
      nextPosition = Duration.zero;
    }

    controller.seekTo(nextPosition);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      watchUi();

      controller.addListener(() {
        if (controller.value.isEnded) {
          showUi();
        }

        if (controller.value.size.aspectRatio != 0) {
          aspectRatio = controller.value.size.aspectRatio;
        }

        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        children: [
          widget.player,
          if (!controller.value.isPlayingAd)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: toggleUi,
                child: IgnorePointer(
                  ignoring: uiHidden,
                  child: AnimatedOpacity(
                    opacity: uiHidden ? 0.0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const Positioned.fill(
                          child: ColoredBox(color: Color(0x66000000)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onDoubleTap: backwardVideo,
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onDoubleTap: forwardVideo,
                              ),
                            )
                          ],
                        ),
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: togglePlay,
                            child: Icon(
                              controller.value.isEnded
                                  ? Icons.replay_circle_filled
                                  : controller.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (controller.value.isReady)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: muteToggle,
                              child: Icon(
                                controller.value.volume == 0.0
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        if (controller.value.isReady)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            left: 8,
                            child: ImaProgressBar(controller),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ImaProgressBar extends StatefulWidget {
  const ImaProgressBar(this.controller, {super.key});
  final ImaPlayerController controller;

  @override
  State<ImaProgressBar> createState() => _ImaProgressBarState();
}

class _ImaProgressBarState extends State<ImaProgressBar> {
  var position = Duration.zero;
  var bufferedPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (!widget.controller.value.isReady) {
          return;
        }

        position = await widget.controller.position;
        bufferedPosition = await widget.controller.bufferedPosition;

        setState(() {});
      });
    });
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0").substring(3);
  }

  final textStyle = const TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    var color = Colors.white;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: ColoredBox(
          color: const Color(0x88000000),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text(
                  formatDuration(widget.controller.value.duration),
                  style: textStyle,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: LayoutBuilder(builder: (context, rect) {
                      final positionPercent = position.inMilliseconds /
                          widget.controller.value.duration.inMilliseconds;

                      final bufferPercent = bufferedPosition.inMilliseconds /
                          widget.controller.value.duration.inMilliseconds;

                      return Stack(
                        fit: StackFit.loose,
                        children: [
                          SizedBox(
                            width: rect.maxWidth,
                            height: 5.0,
                            child: ColoredBox(color: color.withOpacity(0.1)),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            width: bufferPercent * rect.maxWidth,
                            height: 5.0,
                            child: ColoredBox(color: color.withOpacity(0.3)),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            width: positionPercent * rect.maxWidth,
                            height: 5.0,
                            child: ColoredBox(color: color),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                Text(
                  formatDuration(position),
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
