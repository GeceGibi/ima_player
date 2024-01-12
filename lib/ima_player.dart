library ima_player;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

export './ima_player_models.dart'
    show AdInfo, PlayerEvent, AdEventType, ImaAdsLoaderSettings;

import './ima_player_models.dart';

part 'ima_player_ui.dart';
part 'ima_player_view.dart';
part 'ima_player_controller.dart';

class ImaPlayerOptions {
  const ImaPlayerOptions({
    this.autoPlay = true,
    this.initialVolume = 1.0,
    this.isMixWithOtherMedia = true,
    this.showPlaybackControls = false,
    this.allowBackgroundPlayback = false,
  });

  final bool autoPlay;
  final double initialVolume;

  final bool isMixWithOtherMedia;
  final bool allowBackgroundPlayback;
  final bool showPlaybackControls;
}

class ImaPlayer extends StatefulWidget {
  const ImaPlayer(
    this.controller, {
    this.gestureRecognizers = const {},
    super.key,
  });

  final ImaPlayerController controller;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<ImaPlayer> createState() => _ImaPlayerState();
}

class _ImaPlayerState extends State<ImaPlayer> with WidgetsBindingObserver {
  var itWasPlaying = false;
  var viewId = -1;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (widget.controller._isDisposed) {
      return;
    }

    if (!widget.controller.options.allowBackgroundPlayback) {
      switch (state) {
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          itWasPlaying = widget.controller.value.isPlaying;
          widget.controller.pause();

        case AppLifecycleState.resumed:
          if (itWasPlaying) {
            widget.controller.play();
          }

        default:
        // no-op
      }
    }
  }

  @override
  void didUpdateWidget(covariant ImaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      widget.controller._attach(viewId);
      widget.controller.value = oldWidget.controller.value;
      oldWidget.controller._disposeListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller._disposeView();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller._isDisposed) {
      throw "This controller is disposed.";
    }

    return _ImaPlayerView(
      widget.controller,
      gestureRecognizers: widget.gestureRecognizers,
      onViewCreated: (viewId) {
        this.viewId = viewId;
      },
    );
  }
}
