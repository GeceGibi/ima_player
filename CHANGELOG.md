## 2.0.0
* Updated Android, iOS sides
* Updated `ImaPlayerController()` and it's now listenable and extends with `ValueNotifier<PlayerEvent>`.
* Added `controller.onAdEvent` | `Stream<AdEventType>`
* Added `controller.onAdLoaded` | `Stream<AdInfo>`
* Added `controller.onPlayerReady` | `Future`
* Added `controller.pauseOtherPlayers()` | `Future`
* Added `ImaPlayerController.pauseAllPlayer()` | static method

* Added `ImaPlayerUi(player: ..)` widget, basic player ui.
---

* Removed `controller.getVideoInfo()`
* Removed `controller.getAdInfo()`


## 1.1.1
* Fixed `gestureRecognizer` bug [#6](https://github.com/GeceGibi/ima_player/issues/6)
* Added `gestureRecognizer` property to `ImaPlayer` widget


## 1.1.0
* Fixed ios lifecycle bug [#3](https://github.com/GeceGibi/ima_player/issues/3)
* Added `adsLoaderSettings` [#2](https://github.com/GeceGibi/ima_player/issues/2)
* Update dependencies

## 1.0.1
* Fixed ios crash issue
> When trying `adsRequest()` before view attached


## 1.0.0
* Updated README.md
* Breaking Change: removed `getSize` method
* Added `getVideoInfo` method
* Added `getAdInfo` method
* Added `ImaVideoInfo`
* Added `ImaAdInfo`

## 0.0.3
* Updated README.md

## 0.0.2
* Updated README.md
* Added iOS play method `videoUrl` argument support

## 0.0.1
* Initial release.
