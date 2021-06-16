part of nyxx;

/// Emitted when invite is creating
class InviteCreatedEvent {
  /// [Invite] object of created invite
  late final Invite invite;

  InviteCreatedEvent._new(RawApiMap raw, Nyxx client) {
    this.invite = Invite._new(raw["d"] as RawApiMap, client);
  }
}

/// Emitted when invite is deleted
class InviteDeletedEvent {
  /// Channel to which invite was pointing
  late final Cacheable<Snowflake, GuildChannel> channel;

  /// Guild where invite was deleted
  late final Cacheable<Snowflake, Guild>? guild;

  /// Code of invite
  late final String code;

  InviteDeletedEvent._new(RawApiMap raw, Nyxx client) {
    this.code = raw["d"]["code"] as String;
    this.channel = _ChannelCacheable(client, Snowflake(raw["d"]["channel_id"]));

    if (raw["d"]["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}
