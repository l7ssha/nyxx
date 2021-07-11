part of nyxx;

class ActivityBuilder implements Builder{
  /// The activity name.
  late final String name;

  /// The activity type.
  late final ActivityType type;

  /// The game URL, if provided.
  String? url;

  /// Creates new instance of [ActivityBuilder]
  ActivityBuilder(this.name, this.type, {this.url});

  /// Sets activity to game
  factory ActivityBuilder.game(String name) =>
      ActivityBuilder(name, ActivityType.game);

  /// Sets activity to streaming
  factory ActivityBuilder.streaming(String name, String url) =>
      ActivityBuilder(name, ActivityType.streaming, url: url);

  @override
  RawApiMap build() => {
    "name": this.name,
    "type": this.type.value,
    if (this.type == ActivityType.streaming) "url": this.url,
  };
}

/// Allows to build object of user presence used later when setting user presence.
class PresenceBuilder extends Builder {
  /// Status of user.
  UserStatus? status;

  /// If is afk
  bool? afk;

  /// Type of activity.
  ActivityBuilder? activity;

  /// WHen activity was started
  DateTime? since;

  /// Empty constructor to when setting all values manually.
  PresenceBuilder();

  /// Default builder constructor.
  factory PresenceBuilder.of({UserStatus? status, ActivityBuilder? activity}) =>
      PresenceBuilder()
        ..status = status
        ..activity = activity;

  /// Sets client status to idle. [since] indicates how long client is afking
  factory PresenceBuilder.idle({DateTime? since}) =>
    PresenceBuilder()
      ..since = since
      ..afk = true;

  @override
  RawApiMap build() => <String, dynamic>{
        "status": (status != null) ? status.toString() : UserStatus.online.toString(),
        "afk": (afk != null) ? afk : false,
        "activities": [
          if (this.activity != null)
            this.activity!.build(),
        ],
        "since": (since != null) ? since!.millisecondsSinceEpoch : null
      };
}
