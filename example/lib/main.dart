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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
  var aspectRatio = 16 / 9;
  ImaPlayerInfo? info;

  final controller = ImaPlayerController(
    videoUrl:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    imaTag:
        'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
    options: const ImaPlayerOptions(
      muted: false,
      autoPlay: true,
      isMixWithOtherMedia: false,
    ),
  );

  Future<void> getInfoHandler() async {
    info = await controller.getInfo();
    setState(() {});
  }

  void updateAspectRatio() async {
    final size = await controller.getSize();

    if (size.width != 0 && size.height != 0) {
      // setState(() {
      //   aspectRatio = size.width / size.height;
      // });
    }
  }

  @override
  void initState() {
    super.initState();

    controller.onAdsEvent.listen((event) async {
      print('onAdsEvent > $event');

      if (event == ImaAdsEvents.CONTENT_RESUME_REQUESTED ||
          event == ImaAdsEvents.CONTENT_PAUSE_REQUESTED) {
        updateAspectRatio();
      }
    });

    controller.onPlayerEvent.listen((event) {
      print('onPlayerEvent > $event');

      switch (event) {
        case ImaPlayerEvents.PLAYING:
          getInfoHandler();
          break;

        default:
          // no-op
          break;
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: ImaPlayer(controller: controller),
          ),
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
                videoUrl:
                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
              );
            },
            child: Text('PLAY ANOTHER VIDEO'),
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
          FilledButton(
            onPressed: getInfoHandler,
            child: Text('GET INFO'),
          ),
          Text(
            info.toString(),
            maxLines: 10,
          )
        ],
      ),
    );
  }
}
