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

 <img src="https://github.com/GeceGibi/ima_player/blob/main/preview.gif?raw=true" alt="iOS Preview" height="500px">

## ImaPlayer
| Argument                        | Type                                              | Required | Default |
| ------------------------------- |-------------------------------------------------  | -------- | ------- |
| controller                      | `ImaPlayerController`                             | YES      | -       |
| gestureRecognizer               | `Set<Factory<OneSequenceGestureRecognizer>>`      | NO       | -       |
| autoDisposeController           | bool                                              | NO       | false   |


## ImaPlayerController - Constructor Arguments
| Argument                        | Type                                              | Required | Default                   |
| ------------------------------- |-------------------------------------------------  | -------- | ------------------------- |
| uri                             | String                                            | YES      | -                         |
| imaTag                          | String?                                           | NO       | -                         |
| headers                         | Map<String, String>                               | NO       | <String, String>{}        |
| options                         | `ImaPlayerOptions`                                | NO       | `ImaPlayerOptions()`      |
| adsLoaderSettings               | `ImaAdsLoaderSettings`                            | NO       | `ImaAdsLoaderSettings()`  |


## ImaAdsLoaderSettings - Constructor Arguments
| Argument                        | Type                                              | Required | Default               |
| ------------------------------- |-------------------------------------------------  | -------- | --------------------- |
| enableDebugMode                 | bool                                              | NO       | false                 |
| language                        | String                                            | NO       | "en"
| ppid                            | String?                                           | NO       | -
 

## ImaPlayerController - Instance members
```dart
    /// Methods
    controller.play({String? uri}) -> Future<void>;
    controller.pause() -> Future<void>;
    controller.stop() -> Future<void>
    controller.seekTo(Duration) -> Future<void>
    controller.skipAd() -> Future<void>
    controller.setVolume(double volume) -> Future<void>
    controller.position -> Future<Duration>

    /// Observables
    controller.onAdEvent -> Stream<AdEventType>
    controller.onAdLoaded -> Stream<AdInfo>
    controller.onPlayerReady -> Future<bool>

    /// Static Properties
    ImaPlayerController.pauseAllPlayers()
```

## ImaPlayerOptions
| Argument                        | Type  | Description                                 | Required | Default   |
| ------------------------------- |------ | ------------------------------------------- | -------- | --------- |
| muted                           | bool  |                                             | NO       | false     |
| autoPlay                        | bool  |                                             | NO       | true      |
| isMixWithOtherMedia             | bool  |                                             | NO       | true      |
| allowBackgroundPlayback         | bool  | Continue playing when app goes background   | NO       | false     |
| showPlaybackControls            | bool  | Use native playback controllers             | NO       | false     |
| initialVolume                   | double| initial volume, valid range 0.0 between 1.0 | NO       | 1.0       |


```dart
    final controller = ImaPlayerController.network(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        imaTag: 'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
    );

    /// With Ima Player Ui
    ImaPlayerUi(
        player: ImaPlayer(controller)
    ),
```


```dart
    final controller = ImaPlayerController.network(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        imaTag: 'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
        options: ImaPlayerOptions(
            showPlaybackControls: true, // if you want use native ui controls
        )
    );

    /// With Ima Player Ui
    AspectRatio(
        aspectRatio: 16 /9,
        child: ImaPlayer(controller)
    )
```


## Known issues
* add support for assets with `ImaPlayerController.asset` 


* `controller.skipAd` not working currently.
[explanation about skip button](https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsManager.html#skip())