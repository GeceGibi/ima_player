// ignore_for_file: constant_identifier_names

part of ima_player;

enum ImaPlayerEvents {
  READY,
  BUFFERING,
  PLAYING,
  PAUSED;

  static ImaPlayerEvents? fromString(String? str) {
    for (final value in values) {
      if (value.name == str) {
        return value;
      }
    }

    return null;
  }
}

enum ImaAdsEvents {
  ALL_ADS_COMPLETED,
  AD_BREAK_FETCH_ERROR,
  CLICKED,
  COMPLETED,
  CUEPOINTS_CHANGED,
  CONTENT_PAUSE_REQUESTED,
  CONTENT_RESUME_REQUESTED,
  FIRST_QUARTILE,
  LOG,
  AD_BREAK_READY,
  MIDPOINT,
  PAUSED,
  RESUMED,
  SKIPPABLE_STATE_CHANGED,
  SKIPPED,
  STARTED,
  TAPPED,
  ICON_TAPPED,
  ICON_FALLBACK_IMAGE_CLOSED,
  THIRD_QUARTILE,
  LOADED,
  AD_PROGRESS,
  AD_BUFFERING,
  AD_BREAK_STARTED,
  AD_BREAK_ENDED,
  AD_PERIOD_STARTED,
  AD_PERIOD_ENDED,
  UNKNOWN;

  static ImaAdsEvents fromString(String? event) {
    if (event == "COMPLETE") {
      return ImaAdsEvents.COMPLETED;
    } else if (event == "PAUSE") {
      return ImaAdsEvents.PAUSED;
    } else if (event == "RESUME") {
      return ImaAdsEvents.RESUMED;
    }

    for (final value in values) {
      if (value.name == event) {
        return value;
      }
    }

    return ImaAdsEvents.UNKNOWN;
  }
}
