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
      home: const AppHome(),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  var aspectRatio = 16 / 9;
  final controller = ImaPlayerController(
    videoUrl:
        'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    imaTag:
        'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpostoptimizedpodbumper&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator=',
    options: const ImaPlayerOptions(
      muted: false,
      autoPlay: true,
      controllerAutoShow: false,
      controllerHideOnTouch: false,
      isMixWithOtherMedia: false,
    ),
  );

  void updateAspectRatio() async {
    final size = await controller.getSize();

    setState(() {
      aspectRatio = size.width / size.height;
    });
  }

  @override
  void initState() {
    super.initState();

    controller.onAdsEvent.listen((event) async {
      if (event == ImaAdsEvents.CONTENT_RESUME_REQUESTED) {
        updateAspectRatio();
      }
    });

    controller.onPlayerEvent.listen((event) async {
      if (event == ImaPlayerEvents.IS_LOADING_CHANGED) {
        updateAspectRatio();
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
          )
        ],
      ),
    );
  }
}
