part of nyxx_lavalink;

/// Player update event dispatched by lavalink at player progression
class PlayerUpdateEvent extends BaseEvent {
  /// State of the current player
  late final PlayerUpdateStateEvent state;

  /// Guild id where player comes from
  late final Snowflake guildId;

  PlayerUpdateEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json) : super(client, node) {
    guildId = Snowflake(json["guildId"]);
    this.state = PlayerUpdateStateEvent._new(json["state"]["time"] as int, json["state"]["position"] as int?);
  }
}

/// The state of a player at a given moment
class PlayerUpdateStateEvent {
  /// The timestamp of the player
  final int time;
  /// The position where the current track is now on
  final int? position;

  PlayerUpdateStateEvent._new(this.time, this.position);
}
