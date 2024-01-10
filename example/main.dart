import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ima_player/ima_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const AppHome(),
        "/player": (context) => const PlayerScreen(),
      },
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pushNamed('/player'),
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  var position = Duration.zero;

  var aspectRatio = 16 / 9;
  var events = <AdEventType>[];

  final controller = ImaPlayerController.network(
    'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    imaTag:
        'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_preroll_skippable&sz=640x480&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
    options: const ImaPlayerOptions(
      autoPlay: true,
      initialVolume: 1.0,
      isMixWithOtherMedia: false,
      showPlaybackControls: false,
    ),
  );

  @override
  void initState() {
    super.initState();

    controller.onPlayerReady.then((value) {
      print('#####');
      print('READY');
      print('#####');
    });

    controller.onAdLoaded.listen((event) {
      print('#####');
      print('event: $event');
      print('#####');
    }).onError((error) {
      print(error);
    });

    controller.onAdEvent.listen((event) {
      print('#####');
      print('event: $event');
      print('#####');

      events.add(event);
      setState(() {});
    });

    controller.addListener(() {
      setState(() {
        if (controller.value.size.aspectRatio != 0) {
          aspectRatio = controller.value.size.aspectRatio;
        }
      });
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final pos = await controller.position;

      setState(() {
        position = pos;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          ImaPlayerUI(
            player: ImaPlayer(controller),
          ),
          Text(position.toString()),
          Text(controller.value.bufferedDuration.toString()),
          FilledButton(
            onPressed: controller.play,
            child: Text('PLAY'),
          ),
          FilledButton(
            onPressed: controller.pause,
            child: Text('PAUSE'),
          ),
          FilledButton(
            onPressed: controller.stop,
            child: Text('STOP'),
          ),
          FilledButton(
            onPressed: () {
              controller.play(
                uri:
                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
              );
            },
            child: Text('PLAY ANOTHER VIDEO'),
          ),
          FilledButton(
            onPressed: controller.pauseOtherPlayers,
            child: Text('PAUSE OTHER PLAYERS'),
          ),
          FilledButton(
            onPressed: controller.skipAd,
            child: Text('SKIP AD'),
          ),
          FilledButton(
            onPressed: () => controller.setVolume(0.2),
            child: Text('SET VOLUME (0.2)'),
          ),
          FilledButton(
            onPressed: () => controller.seekTo(const Duration(seconds: 10)),
            child: Text('SEEK TO (10 SEC)'),
          ),
          const Divider(),
          Text(controller.value.toString()),
          const Divider(),
          StreamBuilder(
            stream: controller.onAdLoaded,
            builder: (context, snap) {
              if (!snap.hasData) {
                return Text('No ad data');
              }

              return Text(snap.requireData.toString());
            },
          ),
          const Divider(),
          Text(events.join('\n')),
        ],
      ),
    );
  }
}
