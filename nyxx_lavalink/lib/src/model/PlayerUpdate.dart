part of nyxx_lavalink;

/// Player update event dispatched by lavalink at player progression
class PlayerUpdate extends BaseEvent {
  /// State of the current player
  PlayerUpdateState state;

  /// Guild id where player comes from
  Snowflake guildId;

  PlayerUpdate._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : guildId = Snowflake(json["guildId"]),
    state = PlayerUpdateState._new(json["state"]["time"] as int, json["state"]["position"] as int),
    super(client, node);
}

/// The state of a player at a given moment
class PlayerUpdateState {
  /// The timestamp of the player
  int time;
  /// The position where the current track is now on
  int position;

  PlayerUpdateState._new(this.time, this.position);
}