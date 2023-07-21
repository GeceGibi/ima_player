import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

    // Just android
    this.controllerAutoShow = true,

    // Just android
    this.controllerHideOnTouch = true,
  });

  final bool muted;
  final bool autoPlay;
  final bool controllerAutoShow;
  final bool controllerHideOnTouch;
  final bool isMixWithOtherMedia;
}

class ImaPlayer extends StatelessWidget {
  const ImaPlayer({
    required this.controller,
    super.key,
  });

  final ImaPlayerController controller;
  // final ImaPlayerOptions options;

  @override
  Widget build(BuildContext context) {
    return _ImaPlayerView(controller: controller);
  }
}
