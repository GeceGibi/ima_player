// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ima_player_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AdInfo _$AdInfoFromJson(Map<String, dynamic> json) {
  return _AdInfo.fromJson(json);
}

/// @nodoc
mixin _$AdInfo {
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration get duration => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'skip_time_offset',
      fromJson: _durationFromJson,
      toJson: _durationToJson)
  Duration get skipTimeOffset => throw _privateConstructorUsedError;
  String get adid => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson)
  Size get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'advertiser_name')
  String get advertiserName => throw _privateConstructorUsedError;
  @JsonKey(name: 'ad_system')
  String get adSystem => throw _privateConstructorUsedError;
  @JsonKey(name: 'content_type')
  String get contentType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get bitrate => throw _privateConstructorUsedError;
  bool get skippable => throw _privateConstructorUsedError;
  bool get linear => throw _privateConstructorUsedError;
  @JsonKey(name: 'ui_disabled')
  bool get uiDisabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_bumper')
  bool get isBumper => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_ads')
  int get totalAds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdInfoCopyWith<AdInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdInfoCopyWith<$Res> {
  factory $AdInfoCopyWith(AdInfo value, $Res Function(AdInfo) then) =
      _$AdInfoCopyWithImpl<$Res, AdInfo>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      Duration duration,
      @JsonKey(
          name: 'skip_time_offset',
          fromJson: _durationFromJson,
          toJson: _durationToJson)
      Duration skipTimeOffset,
      String adid,
      @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson) Size size,
      @JsonKey(name: 'advertiser_name') String advertiserName,
      @JsonKey(name: 'ad_system') String adSystem,
      @JsonKey(name: 'content_type') String contentType,
      String title,
      String description,
      int bitrate,
      bool skippable,
      bool linear,
      @JsonKey(name: 'ui_disabled') bool uiDisabled,
      @JsonKey(name: 'is_bumper') bool isBumper,
      @JsonKey(name: 'total_ads') int totalAds});
}

/// @nodoc
class _$AdInfoCopyWithImpl<$Res, $Val extends AdInfo>
    implements $AdInfoCopyWith<$Res> {
  _$AdInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
    Object? skipTimeOffset = null,
    Object? adid = null,
    Object? size = null,
    Object? advertiserName = null,
    Object? adSystem = null,
    Object? contentType = null,
    Object? title = null,
    Object? description = null,
    Object? bitrate = null,
    Object? skippable = null,
    Object? linear = null,
    Object? uiDisabled = null,
    Object? isBumper = null,
    Object? totalAds = null,
  }) {
    return _then(_value.copyWith(
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      skipTimeOffset: null == skipTimeOffset
          ? _value.skipTimeOffset
          : skipTimeOffset // ignore: cast_nullable_to_non_nullable
              as Duration,
      adid: null == adid
          ? _value.adid
          : adid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
      advertiserName: null == advertiserName
          ? _value.advertiserName
          : advertiserName // ignore: cast_nullable_to_non_nullable
              as String,
      adSystem: null == adSystem
          ? _value.adSystem
          : adSystem // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      bitrate: null == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int,
      skippable: null == skippable
          ? _value.skippable
          : skippable // ignore: cast_nullable_to_non_nullable
              as bool,
      linear: null == linear
          ? _value.linear
          : linear // ignore: cast_nullable_to_non_nullable
              as bool,
      uiDisabled: null == uiDisabled
          ? _value.uiDisabled
          : uiDisabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isBumper: null == isBumper
          ? _value.isBumper
          : isBumper // ignore: cast_nullable_to_non_nullable
              as bool,
      totalAds: null == totalAds
          ? _value.totalAds
          : totalAds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdInfoImplCopyWith<$Res> implements $AdInfoCopyWith<$Res> {
  factory _$$AdInfoImplCopyWith(
          _$AdInfoImpl value, $Res Function(_$AdInfoImpl) then) =
      __$$AdInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      Duration duration,
      @JsonKey(
          name: 'skip_time_offset',
          fromJson: _durationFromJson,
          toJson: _durationToJson)
      Duration skipTimeOffset,
      String adid,
      @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson) Size size,
      @JsonKey(name: 'advertiser_name') String advertiserName,
      @JsonKey(name: 'ad_system') String adSystem,
      @JsonKey(name: 'content_type') String contentType,
      String title,
      String description,
      int bitrate,
      bool skippable,
      bool linear,
      @JsonKey(name: 'ui_disabled') bool uiDisabled,
      @JsonKey(name: 'is_bumper') bool isBumper,
      @JsonKey(name: 'total_ads') int totalAds});
}

/// @nodoc
class __$$AdInfoImplCopyWithImpl<$Res>
    extends _$AdInfoCopyWithImpl<$Res, _$AdInfoImpl>
    implements _$$AdInfoImplCopyWith<$Res> {
  __$$AdInfoImplCopyWithImpl(
      _$AdInfoImpl _value, $Res Function(_$AdInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
    Object? skipTimeOffset = null,
    Object? adid = null,
    Object? size = null,
    Object? advertiserName = null,
    Object? adSystem = null,
    Object? contentType = null,
    Object? title = null,
    Object? description = null,
    Object? bitrate = null,
    Object? skippable = null,
    Object? linear = null,
    Object? uiDisabled = null,
    Object? isBumper = null,
    Object? totalAds = null,
  }) {
    return _then(_$AdInfoImpl(
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      skipTimeOffset: null == skipTimeOffset
          ? _value.skipTimeOffset
          : skipTimeOffset // ignore: cast_nullable_to_non_nullable
              as Duration,
      adid: null == adid
          ? _value.adid
          : adid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
      advertiserName: null == advertiserName
          ? _value.advertiserName
          : advertiserName // ignore: cast_nullable_to_non_nullable
              as String,
      adSystem: null == adSystem
          ? _value.adSystem
          : adSystem // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      bitrate: null == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int,
      skippable: null == skippable
          ? _value.skippable
          : skippable // ignore: cast_nullable_to_non_nullable
              as bool,
      linear: null == linear
          ? _value.linear
          : linear // ignore: cast_nullable_to_non_nullable
              as bool,
      uiDisabled: null == uiDisabled
          ? _value.uiDisabled
          : uiDisabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isBumper: null == isBumper
          ? _value.isBumper
          : isBumper // ignore: cast_nullable_to_non_nullable
              as bool,
      totalAds: null == totalAds
          ? _value.totalAds
          : totalAds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdInfoImpl implements _AdInfo {
  const _$AdInfoImpl(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      this.duration = Duration.zero,
      @JsonKey(
          name: 'skip_time_offset',
          fromJson: _durationFromJson,
          toJson: _durationToJson)
      this.skipTimeOffset = Duration.zero,
      this.adid = '',
      @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson)
      this.size = Size.zero,
      @JsonKey(name: 'advertiser_name') this.advertiserName = '',
      @JsonKey(name: 'ad_system') this.adSystem = '',
      @JsonKey(name: 'content_type') this.contentType = '',
      this.title = '',
      this.description = '',
      this.bitrate = 0,
      this.skippable = false,
      this.linear = true,
      @JsonKey(name: 'ui_disabled') this.uiDisabled = false,
      @JsonKey(name: 'is_bumper') this.isBumper = false,
      @JsonKey(name: 'total_ads') this.totalAds = 0});

  factory _$AdInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdInfoImplFromJson(json);

  @override
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  @override
  @JsonKey(
      name: 'skip_time_offset',
      fromJson: _durationFromJson,
      toJson: _durationToJson)
  final Duration skipTimeOffset;
  @override
  @JsonKey()
  final String adid;
  @override
  @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson)
  final Size size;
  @override
  @JsonKey(name: 'advertiser_name')
  final String advertiserName;
  @override
  @JsonKey(name: 'ad_system')
  final String adSystem;
  @override
  @JsonKey(name: 'content_type')
  final String contentType;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final int bitrate;
  @override
  @JsonKey()
  final bool skippable;
  @override
  @JsonKey()
  final bool linear;
  @override
  @JsonKey(name: 'ui_disabled')
  final bool uiDisabled;
  @override
  @JsonKey(name: 'is_bumper')
  final bool isBumper;
  @override
  @JsonKey(name: 'total_ads')
  final int totalAds;

  @override
  String toString() {
    return 'AdInfo(duration: $duration, skipTimeOffset: $skipTimeOffset, adid: $adid, size: $size, advertiserName: $advertiserName, adSystem: $adSystem, contentType: $contentType, title: $title, description: $description, bitrate: $bitrate, skippable: $skippable, linear: $linear, uiDisabled: $uiDisabled, isBumper: $isBumper, totalAds: $totalAds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdInfoImpl &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.skipTimeOffset, skipTimeOffset) ||
                other.skipTimeOffset == skipTimeOffset) &&
            (identical(other.adid, adid) || other.adid == adid) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.advertiserName, advertiserName) ||
                other.advertiserName == advertiserName) &&
            (identical(other.adSystem, adSystem) ||
                other.adSystem == adSystem) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.bitrate, bitrate) || other.bitrate == bitrate) &&
            (identical(other.skippable, skippable) ||
                other.skippable == skippable) &&
            (identical(other.linear, linear) || other.linear == linear) &&
            (identical(other.uiDisabled, uiDisabled) ||
                other.uiDisabled == uiDisabled) &&
            (identical(other.isBumper, isBumper) ||
                other.isBumper == isBumper) &&
            (identical(other.totalAds, totalAds) ||
                other.totalAds == totalAds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      duration,
      skipTimeOffset,
      adid,
      size,
      advertiserName,
      adSystem,
      contentType,
      title,
      description,
      bitrate,
      skippable,
      linear,
      uiDisabled,
      isBumper,
      totalAds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdInfoImplCopyWith<_$AdInfoImpl> get copyWith =>
      __$$AdInfoImplCopyWithImpl<_$AdInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdInfoImplToJson(
      this,
    );
  }
}

abstract class _AdInfo implements AdInfo {
  const factory _AdInfo(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      final Duration duration,
      @JsonKey(
          name: 'skip_time_offset',
          fromJson: _durationFromJson,
          toJson: _durationToJson)
      final Duration skipTimeOffset,
      final String adid,
      @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson) final Size size,
      @JsonKey(name: 'advertiser_name') final String advertiserName,
      @JsonKey(name: 'ad_system') final String adSystem,
      @JsonKey(name: 'content_type') final String contentType,
      final String title,
      final String description,
      final int bitrate,
      final bool skippable,
      final bool linear,
      @JsonKey(name: 'ui_disabled') final bool uiDisabled,
      @JsonKey(name: 'is_bumper') final bool isBumper,
      @JsonKey(name: 'total_ads') final int totalAds}) = _$AdInfoImpl;

  factory _AdInfo.fromJson(Map<String, dynamic> json) = _$AdInfoImpl.fromJson;

  @override
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration get duration;
  @override
  @JsonKey(
      name: 'skip_time_offset',
      fromJson: _durationFromJson,
      toJson: _durationToJson)
  Duration get skipTimeOffset;
  @override
  String get adid;
  @override
  @JsonKey(fromJson: _sizeFromJson, toJson: _sizeToJson)
  Size get size;
  @override
  @JsonKey(name: 'advertiser_name')
  String get advertiserName;
  @override
  @JsonKey(name: 'ad_system')
  String get adSystem;
  @override
  @JsonKey(name: 'content_type')
  String get contentType;
  @override
  String get title;
  @override
  String get description;
  @override
  int get bitrate;
  @override
  bool get skippable;
  @override
  bool get linear;
  @override
  @JsonKey(name: 'ui_disabled')
  bool get uiDisabled;
  @override
  @JsonKey(name: 'is_bumper')
  bool get isBumper;
  @override
  @JsonKey(name: 'total_ads')
  int get totalAds;
  @override
  @JsonKey(ignore: true)
  _$$AdInfoImplCopyWith<_$AdInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PlayerEvent {
  bool get isBuffering => throw _privateConstructorUsedError;
  bool get isPlaying => throw _privateConstructorUsedError;
  bool get isPlayingAd => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;
  bool get isEnded => throw _privateConstructorUsedError;
  double get volume => throw _privateConstructorUsedError;
  Size get size => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PlayerEventCopyWith<PlayerEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerEventCopyWith<$Res> {
  factory $PlayerEventCopyWith(
          PlayerEvent value, $Res Function(PlayerEvent) then) =
      _$PlayerEventCopyWithImpl<$Res, PlayerEvent>;
  @useResult
  $Res call(
      {bool isBuffering,
      bool isPlaying,
      bool isPlayingAd,
      bool isReady,
      bool isEnded,
      double volume,
      Size size,
      Duration duration});
}

/// @nodoc
class _$PlayerEventCopyWithImpl<$Res, $Val extends PlayerEvent>
    implements $PlayerEventCopyWith<$Res> {
  _$PlayerEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isBuffering = null,
    Object? isPlaying = null,
    Object? isPlayingAd = null,
    Object? isReady = null,
    Object? isEnded = null,
    Object? volume = null,
    Object? size = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      isBuffering: null == isBuffering
          ? _value.isBuffering
          : isBuffering // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlayingAd: null == isPlayingAd
          ? _value.isPlayingAd
          : isPlayingAd // ignore: cast_nullable_to_non_nullable
              as bool,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      isEnded: null == isEnded
          ? _value.isEnded
          : isEnded // ignore: cast_nullable_to_non_nullable
              as bool,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerEventImplCopyWith<$Res>
    implements $PlayerEventCopyWith<$Res> {
  factory _$$PlayerEventImplCopyWith(
          _$PlayerEventImpl value, $Res Function(_$PlayerEventImpl) then) =
      __$$PlayerEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isBuffering,
      bool isPlaying,
      bool isPlayingAd,
      bool isReady,
      bool isEnded,
      double volume,
      Size size,
      Duration duration});
}

/// @nodoc
class __$$PlayerEventImplCopyWithImpl<$Res>
    extends _$PlayerEventCopyWithImpl<$Res, _$PlayerEventImpl>
    implements _$$PlayerEventImplCopyWith<$Res> {
  __$$PlayerEventImplCopyWithImpl(
      _$PlayerEventImpl _value, $Res Function(_$PlayerEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isBuffering = null,
    Object? isPlaying = null,
    Object? isPlayingAd = null,
    Object? isReady = null,
    Object? isEnded = null,
    Object? volume = null,
    Object? size = null,
    Object? duration = null,
  }) {
    return _then(_$PlayerEventImpl(
      isBuffering: null == isBuffering
          ? _value.isBuffering
          : isBuffering // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlayingAd: null == isPlayingAd
          ? _value.isPlayingAd
          : isPlayingAd // ignore: cast_nullable_to_non_nullable
              as bool,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      isEnded: null == isEnded
          ? _value.isEnded
          : isEnded // ignore: cast_nullable_to_non_nullable
              as bool,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$PlayerEventImpl implements _PlayerEvent {
  const _$PlayerEventImpl(
      {this.isBuffering = false,
      this.isPlaying = false,
      this.isPlayingAd = false,
      this.isReady = false,
      this.isEnded = false,
      this.volume = 0.0,
      this.size = Size.zero,
      this.duration = Duration.zero});

  @override
  @JsonKey()
  final bool isBuffering;
  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final bool isPlayingAd;
  @override
  @JsonKey()
  final bool isReady;
  @override
  @JsonKey()
  final bool isEnded;
  @override
  @JsonKey()
  final double volume;
  @override
  @JsonKey()
  final Size size;
  @override
  @JsonKey()
  final Duration duration;

  @override
  String toString() {
    return 'PlayerEvent(isBuffering: $isBuffering, isPlaying: $isPlaying, isPlayingAd: $isPlayingAd, isReady: $isReady, isEnded: $isEnded, volume: $volume, size: $size, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerEventImpl &&
            (identical(other.isBuffering, isBuffering) ||
                other.isBuffering == isBuffering) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.isPlayingAd, isPlayingAd) ||
                other.isPlayingAd == isPlayingAd) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.isEnded, isEnded) || other.isEnded == isEnded) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isBuffering, isPlaying,
      isPlayingAd, isReady, isEnded, volume, size, duration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerEventImplCopyWith<_$PlayerEventImpl> get copyWith =>
      __$$PlayerEventImplCopyWithImpl<_$PlayerEventImpl>(this, _$identity);
}

abstract class _PlayerEvent implements PlayerEvent {
  const factory _PlayerEvent(
      {final bool isBuffering,
      final bool isPlaying,
      final bool isPlayingAd,
      final bool isReady,
      final bool isEnded,
      final double volume,
      final Size size,
      final Duration duration}) = _$PlayerEventImpl;

  @override
  bool get isBuffering;
  @override
  bool get isPlaying;
  @override
  bool get isPlayingAd;
  @override
  bool get isReady;
  @override
  bool get isEnded;
  @override
  double get volume;
  @override
  Size get size;
  @override
  Duration get duration;
  @override
  @JsonKey(ignore: true)
  _$$PlayerEventImplCopyWith<_$PlayerEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
