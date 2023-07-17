import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'ima_player_view.dart';
part 'ima_player_events.dart';
part 'ima_player_controller.dart';

class ImaPlayerOptions {
  const ImaPlayerOptions({
    this.autoPlay = true,
    this.controllerAutoShow = true,
    this.controllerHideOnTouch = true,
  });

  final bool autoPlay;
  final bool controllerAutoShow;
  final bool controllerHideOnTouch;
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
