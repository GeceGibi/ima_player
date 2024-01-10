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
    this.autoDisposeController = false,
    super.key,
  });

  final bool autoDisposeController;
  final ImaPlayerController controller;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<ImaPlayer> createState() => _ImaPlayerState();
}

class _ImaPlayerState extends State<ImaPlayer>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  var itWasPlaying = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.autoDisposeController) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _ImaPlayerView(
      widget.controller,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
