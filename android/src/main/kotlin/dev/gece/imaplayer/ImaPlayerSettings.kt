package dev.gece.imaplayer

import android.net.Uri

class ImaPlayerSettings(mediaUrl: String, imaTag: String?) {
    var uri: Uri = Uri.parse(mediaUrl)
    var tag: Uri? = if (imaTag != null) Uri.parse(imaTag) else null
    var isMixed: Boolean = false;
    var autoPlay: Boolean = true
    var initialVolume: Double = 1.0
    var showPlaybackControls: Boolean = true;

    val isAdsEnabled get() = tag != null;

}