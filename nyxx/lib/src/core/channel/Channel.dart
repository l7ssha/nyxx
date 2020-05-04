part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
abstract class Channel extends SnowflakeEntity {
  /// The channel's type.
  /// https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  ChannelType type;

  /// Reference to client instance
  Nyxx client;

  Channel._new(Map<String, dynamic> raw, int type, this.client)
      : this.type = ChannelType(type),
        super(Snowflake(raw['id'] as String));

  factory Channel._deserialize(Map<String, dynamic> raw, Nyxx client) {
    var type = raw['d']['type'] as int;

    final guild = raw['d']['guild_id'] != null ? client.guilds[Snowflake(raw['d']['guild_id'])] : null;

    switch(type) {
      case 1:
        return DMChannel._new(raw['d'] as Map<String, dynamic>, client);
        break;
      case 3:
        return GroupDMChannel._new(raw['d'] as Map<String, dynamic>, client);
        break;
      case 0:
      case 5:
        return TextChannel._new(raw['d'] as Map<String, dynamic>, guild!, client);
        break;
      case 2:
        return VoiceChannel._new(raw['d'] as Map<String, dynamic>, guild!, client);
        break;
      case 4:
        return CategoryChannel._new(raw['d'] as Map<String, dynamic>, guild!, client);
        break;
      default:
        return _InternalChannel._new(raw['d'] as Map<String, dynamic>, type, client);
    }
  }

  /// Deletes the channel.
  /// Throws if bot cannot perform operation
  Future<void> delete({String auditReason = ""}) {
    return client._http
        ._execute(BasicRequest._new("/channels/${this.id}", method: 'DELETE', auditLog: auditReason));
  }

  @override
  String toString() => this.id.toString();
}

class _InternalChannel extends Channel {
  _InternalChannel._new(Map<String, dynamic> raw, int type, Nyxx client) :
      super._new(raw, type, client);
}

/// Enum for possible channel types
class ChannelType {
  final int _value;

  ChannelType(this._value);
  const ChannelType._create(this._value);

  @override
  String toString() => _value.toString();

  @override
  bool operator ==(other) =>
      (other is ChannelType && other._value == this._value) ||
      (other is int && other == this._value);

  @override
  int get hashCode => _value.hashCode;

  static const ChannelType text = ChannelType._create(0);
  static const ChannelType voice = ChannelType._create(2);
  static const ChannelType category = ChannelType._create(4);

  static const ChannelType dm = ChannelType._create(1);
  static const ChannelType groupDm = ChannelType._create(3);

  static const ChannelType guildNews = ChannelType._create(5);
  static const ChannelType guildStore = ChannelType._create(6);
}