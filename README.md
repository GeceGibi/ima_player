<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->


# Flutter Ima Player Plugin
Ima Player for Android & iOS. <br/>
Used ExoPlayer SDK for Android and AVPlayer for iOS.


<img src="https://raw.githubusercontent.com/GeceGibi/ima_player/main/ios_preview.gif" alt="iOS Preview" height="500px">
<img src="https://raw.githubusercontent.com/GeceGibi/ima_player/main/android_preview.gif" alt="Android Preview" height="500px">

## ImaPlayer
| Argument                        | Type                                              | Required |
| ------------------------------- |-------------------------------------------------  | -------- |
| controller                      | `ImaPlayerController`                             | YES      |


## ImaPlayerController - Constructor Arguments
| Argument                        | Type                                              | Required | Default               |
| ------------------------------- |-------------------------------------------------  | -------- | --------------------- |
| videoUrl                        | String                                            | YES      | -                     |
| imaTag                          | String?                                           | NO       | -                     |
| options                         | `ImaPlayerOptions`                                | NO       | `ImaPlayerOptions()`  |


## ImaPlayerController - Instance members
```dart
    /// Methods
    controller.play({String? videoUrl}) -> Future<bool>;
    controller.pause() -> Future<bool>;
    controller.stop() -> Future<bool>
    controller.getSize() -> Future<Size>
    controller.getInfo() -> Future<ImaPlayerInfo>
    controller.seekTo(Duration) -> Future<bool>
    controller.skipAd() -> Future<bool>
    controller.setVolume(double volume) -> Future<bool>

    /// Observables
    controller.onAdsEvent -> Stream<ImaAdsEvents>
    controller.onPlayerEvent -> Stream<ImaPlayerEvents>

    /// Variables
    controller.videoUrl -> String;
    controller.imaTag -> String?;
    controller.options -> ImaPlayerOptions;
```

## ImaPlayerOptions
| Argument                        | Type  | Description                               | Required | Default   |
| ------------------------------- |------ | ----------------------------------------- | -------- | --------- |
| muted                           | bool  |                                           | NO       | false     |
| autoPlay                        | bool  |                                           | NO       | true      |
| isMixWithOtherMedia             | bool  |                                           | NO       | true      |
| allowBackgroundPlayback         | bool  | Continue playing when app goes background | NO       | false     |
| showPlaybackControls            | bool  |                                           | NO       | true      |
| controllerAutoShow              | bool  | Just for android                          | NO       | true      |
| controllerHideOnTouch           | bool  | Just for android                          | NO       | true      |



```dart
    final controller = ImaPlayerController(
        videoUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        imaTag: 'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
        options: const ImaPlayerOptions(
            autoPlay: false
        ),
    );

    /// ...
    AspectRatio(
        aspectRatio: aspectRatio,
        child: ImaPlayer(controller: controller),
    ),
    /// ...
```