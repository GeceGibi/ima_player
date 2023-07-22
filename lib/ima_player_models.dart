part of 'ima_player.dart';

class ImaPlayerInfo {
  ImaPlayerInfo.fromJson(Map<String, dynamic> json)
      : currentPosition = json['current_position'],
        totalDuration = json['total_duration'],
        isPlaying = json['is_playing'],
        isPlayingAd = json['is_playing_ad'],
        isBuffering = json['is_buffering'];

  final int currentPosition;
  final int totalDuration;
  final bool isPlaying;
  final bool isPlayingAd;
  final bool isBuffering;

  @override
  String toString() =>
      'ImaPlayerInfo(currentPosition: $currentPosition, totalDuration: $totalDuration, isPlaying: $isPlaying, isPlayingAd: $isPlayingAd, isBuffering: $isBuffering)';
}
