part of 'ima_player.dart';

class ImaPlayerUI extends StatefulWidget {
  const ImaPlayerUI({
    super.key,
    required this.player,
    this.bufferingIndicatorBuilder,
    this.muteEnabled = true,
    this.fastBackwardEnabled = true,
    this.fastForwardEnabled = true,
    this.uiFadeOutDuration = const Duration(milliseconds: 350),
    this.uiAutoHideAfterDuration = const Duration(seconds: 3),
  });

  final ImaPlayer player;
  final bool muteEnabled;
  final bool fastForwardEnabled;
  final bool fastBackwardEnabled;
  final Widget Function()? bufferingIndicatorBuilder;
  final Duration uiFadeOutDuration;
  final Duration uiAutoHideAfterDuration;

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
    uiTimer = Timer(widget.uiAutoHideAfterDuration, hideUi);
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

  void seekToHandler(double position) async {
    final duration = controller.value.duration * position;
    watchUi();
    controller.seekTo(duration);
  }

  final backwardAndForwardStep = const Duration(seconds: 5);
  Future<void> forwardVideo() async {
    if (!controller.value.isReady || !controller.value.isPlaying) {
      return;
    }

    watchUi();

    final position = await controller.position;
    var nextPosition = position + backwardAndForwardStep;

    if (nextPosition > controller.value.duration) {
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

  var _initialWatcherAddedAfterAds = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.addListener(() {
        if (!mounted) {
          return;
        }

        if (controller.value.isReady &&
            controller.value.isPlaying &&
            !_initialWatcherAddedAfterAds) {
          _initialWatcherAddedAfterAds = true;
          watchUi();
        }

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
    final canRenderUi = controller.value.isReady &&
        !controller.value.isBuffering &&
        !controller.value.isPlayingAd &&
        !controller._isDisposedController;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        children: [
          widget.player,
          if (controller.value.isBuffering)
            if (widget.bufferingIndicatorBuilder != null)
              widget.bufferingIndicatorBuilder!()
            else
              const Center(child: CircularProgressIndicator.adaptive()),
          if (canRenderUi)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onDoubleTap:
                          widget.fastBackwardEnabled ? backwardVideo : null,
                      onTap: toggleUi,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onDoubleTap:
                          widget.fastBackwardEnabled ? forwardVideo : null,
                      onTap: toggleUi,
                    ),
                  )
                ],
              ),
            ),
          if (canRenderUi)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: uiHidden,
                child: AnimatedOpacity(
                  opacity: uiHidden ? 0.0 : 1,
                  duration: widget.uiFadeOutDuration,
                  child: Stack(
                    children: [
                      const IgnorePointer(
                        child: SizedBox.expand(
                          child: ColoredBox(color: Color(0x66000000)),
                        ),
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
                      if (controller.value.isReady &&
                          !controller.value.isEnded &&
                          widget.muteEnabled)
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
                      if (controller.value.isReady && !controller.value.isEnded)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          left: 8,
                          child: ImaProgressBar(
                            controller,
                            onSeek: seekToHandler,
                          ),
                        )
                    ],
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
  const ImaProgressBar(this.controller, {required this.onSeek, super.key});

  final ImaPlayerController controller;
  final void Function(double position) onSeek;

  @override
  State<ImaProgressBar> createState() => _ImaProgressBarState();
}

class _ImaProgressBarState extends State<ImaProgressBar> {
  var position = Duration.zero;
  var seekValue = ValueNotifier<double?>(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (!widget.controller.value.isReady ||
            !widget.controller.value.isPlaying ||
            widget.controller._isDisposedController ||
            widget.controller._isDisposedView) {
          return;
        }

        position = await widget.controller.position;
        setState(() {});
      });
    });
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0").substring(3);
  }

  TextStyle? get textStyle => Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xAA000000),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              formatDuration(widget.controller.value.duration),
              style: textStyle,
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, rect) {
              final positionPercent = position.inMilliseconds /
                  widget.controller.value.duration.inMilliseconds;

              if (positionPercent.isNaN || positionPercent.isInfinite) {
                return const SizedBox.shrink();
              }

              return Listener(
                onPointerUp: (event) {
                  widget.onSeek(event.localPosition.dx / rect.maxWidth);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(
                    value: positionPercent,
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              formatDuration(position),
              style: textStyle,
            ),
          )
        ],
      ),
    );
  }
}
