library ima_player;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'ima_player_models.dart';
part 'ima_player_view.dart';
part 'ima_player_events.dart';
part 'ima_player_controller.dart';

class ImaPlayerOptions {
  const ImaPlayerOptions({
    this.muted = false,
    this.autoPlay = true,
    this.isMixWithOtherMedia = true,
    this.allowBackgroundPlayback = false,
    this.showPlaybackControls = true,

    /// Just android
    this.controllerAutoShow = true,
    this.controllerHideOnTouch = true,
  });

  final bool muted;
  final bool autoPlay;
  final bool controllerAutoShow;
  final bool controllerHideOnTouch;
  final bool isMixWithOtherMedia;
  final bool allowBackgroundPlayback;
  final bool showPlaybackControls;
}

class ImaPlayer extends StatefulWidget {
  const ImaPlayer({
    required this.controller,
    this.gestureRecognizers = const {},
    super.key,
  });

  final ImaPlayerController controller;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<ImaPlayer> createState() => _ImaPlayerState();
}

class _ImaPlayerState extends State<ImaPlayer> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!widget.controller.options.allowBackgroundPlayback) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          widget.controller.pause();

        case AppLifecycleState.resumed:
          if (widget.controller.options.autoPlay) {
            widget.controller.play();
          }

        default:
        // no-op
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  // final ImaPlayerOptions options;
  @override
  Widget build(BuildContext context) {
    return _ImaPlayerView(
      controller: widget.controller,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }
}
