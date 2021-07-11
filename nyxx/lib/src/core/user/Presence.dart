part of nyxx;

/// Presence is game or activity which user is playing/user participate.
/// Can be game, eg. Dota 2, VS Code or activity like Listening to song on Spotify.
class Activity {
  /// The activity name.
  late final String name;

  /// The activity type.
  late final ActivityType type;

  /// The game URL, if provided.
  late final String? url;

  /// Timestamp of when the activity was added to the user's session
  late final DateTime createdAt;

  /// Timestamps for start and/or end of the game
  late final ActivityTimestamps? timestamps;

  /// Application id for the game
  late final Snowflake? applicationId;

  /// What the player is currently doing
  late final String? details;

  /// The user's current party status
  late final String? state;

  /// The emoji used for a custom status
  late final ActivityEmoji? customStatusEmoji;

  /// Information for the current party of the player
  late final ActivityParty? party;

  /// Images for the presence and their hover texts
  late final GameAssets? assets;

  /// Secrets for Rich Presence joining and spectating
  late final GameSecrets? secrets;

  /// Whether or not the activity is an instanced game session
  late final bool? instance;

  ///	Activity flags ORd together, describes what the payload includes
  late final int? activityFlags;

  Activity._new(RawApiMap raw) {
    this.name = raw["name"] as String;
    this.url = raw["url"] as String?;
    this.type = ActivityType.from(raw["type"] as int);
    this.createdAt = DateTime.fromMillisecondsSinceEpoch(raw["created_at"] as int);
    this.details = raw["details"] as String?;
    this.state = raw["state"] as String?;

    if (raw["timestamps"] != null) {
      this.timestamps = ActivityTimestamps._new(raw["timestamps"] as RawApiMap);
    } else {
      this.timestamps = null;
    }

    if (raw["application_id"] != null) {
      this.applicationId = Snowflake(raw["application_id"]);
    } else {
      this.applicationId = null;
    }

    if (raw["emoji"] != null) {
      this.customStatusEmoji = ActivityEmoji._new(raw["emoji"] as RawApiMap);
    } else {
      this.customStatusEmoji = null;
    }

    if (raw["party"] != null) {
      this.party = ActivityParty._new(raw["party"] as RawApiMap);
    } else {
      this.party = null;
    }

    if (raw["assets"] != null) {
      this.assets = GameAssets._new(raw["assets"] as RawApiMap);
    } else {
      this.assets = null;
    }

    if (raw["secrets"] != null) {
      this.secrets = GameSecrets._new(raw["secrets"] as RawApiMap);
    } else {
      this.secrets = null;
    }

    this.instance = raw["instance"] as bool?;
    this.activityFlags = raw["flags"] as int?;
  }
}

/// Represent emoji within activity
class ActivityEmoji {
  /// Id of emoji.
  late final Snowflake? id;

  /// True if emoji is animated
  late final bool animated;

  ActivityEmoji._new(RawApiMap raw) {
    if (raw["id"] != null) {
      this.id = Snowflake(raw["id"]);
    }

    if (raw["animated"] != null) {
      this.animated = raw["animated"] as bool? ?? false;
    }
  }
}

/// Timestamp of activity
class ActivityTimestamps {
  /// DateTime when activity started
  late final DateTime? start;

  /// DateTime when activity ends
  late final DateTime? end;

  ActivityTimestamps._new(RawApiMap raw) {
    if (raw["start"] != null) {
      this.start = DateTime.fromMillisecondsSinceEpoch(raw["start"] as int);
    }

    if (raw["end"] != null) {
      this.end = DateTime.fromMillisecondsSinceEpoch(raw["end"] as int);
    }
  }
}

/// Represents type of presence activity
class ActivityType extends IEnum<int> {
  /// Status type when playing a game
  static const ActivityType game = ActivityType._create(0);

  /// Status type when streaming a game. Only supports twitch.tv or youtube.com url
  static const ActivityType streaming = ActivityType._create(1);

  /// Status type when listening to Spotify
  static const ActivityType listening = ActivityType._create(2);

  /// Custom status, not supported for bot accounts
  static const ActivityType custom = ActivityType._create(4);

  /// Competing in something
  static const ActivityType competing = ActivityType._create(5);

  /// Creates [ActivityType] from [value]
  ActivityType.from(int value) : super(value);
  const ActivityType._create(int value) : super(value);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == this._value;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
}

/// Represents party of game.
class ActivityParty {
  /// Party id.
  late final String? id;

  /// Current size of party.
  late final int? currentSize;

  /// Max size of party.
  late final int? maxSize;

  ActivityParty._new(RawApiMap raw) {
    this.id = raw["id"] as String?;

    if (raw["size"] != null) {
      this.currentSize = raw["size"].first as int;
      this.maxSize = raw["size"].last as int;
    } else {
      this.currentSize = null;
      this.maxSize = null;
    }
  }
}

/// Presence"s assets
class GameAssets {
  /// The id for a large asset of the activity, usually a snowflake.
  late final String? largeImage;

  /// Text displayed when hovering over the large image of the activity.
  late final String? largeText;

  /// The id for a small asset of the activity, usually a snowflake
  late final String? smallImage;

  /// Text displayed when hovering over the small image of the activity
  late final String? smallText;

  GameAssets._new(RawApiMap raw) {
    this.largeImage = raw["large_image"] as String?;
    this.largeText = raw["large_text"] as String?;
    this.smallImage = raw["small_image"] as String?;
    this.smallText = raw["small_text"] as String?;
  }
}

/// Represents presence"s secrets
class GameSecrets {
  /// Join secret
  late final String join;

  /// Spectate secret
  late final String spectate;

  /// Match secret
  late final String match;

  GameSecrets._new(RawApiMap raw) {
    this.join = raw["join"] as String;
    this.spectate = raw["spectate"] as String;
    this.match = raw["match"] as String;
  }
}
