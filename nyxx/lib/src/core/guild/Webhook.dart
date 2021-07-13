part of nyxx;

/// Type of webhook. Either [incoming] if it its normal webhook executable with token,
/// or [channelFollower] if its discord internal webhook
class WebhookType extends IEnum<int> {
  /// Incoming Webhooks can post messages to channels with a generated token
  static const WebhookType incoming = WebhookType._create(1);

  /// Channel Follower Webhooks are internal webhooks used with Channel Following to post new messages into channels
  static const WebhookType channelFollower = WebhookType._create(2);

  const WebhookType._create(int? value) : super(value ?? 0);
  WebhookType.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == _value;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
}

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity implements IMessageAuthor {
  /// The webhook's name.
  late final String? name;

  /// The webhook's token. Defaults to empty string
  late final String token;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  late final CacheableTextChannel<TextGuildChannel>? channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  late final Cacheable<Snowflake, Guild>? guild;

  /// The user, if this is accessed using a normal client.
  late final User? user;

  /// Webhook type
  late final WebhookType? type;

  /// Webhooks avatar hash
  late final String? avatarHash;

  /// Default webhook avatar id
  int get defaultAvatarId => 0;

  @override
  String get username => this.name.toString();

  @override
  int get discriminator => -1;

  @override
  bool get bot => true;

  @override
  String get tag => "";

  /// Reference to [Nyxx] object
  final INyxx client;

  Webhook._new(RawApiMap raw, this.client) : super(Snowflake(raw["id"] as String)) {
    this.name = raw["name"] as String?;
    this.token = raw["token"] as String? ?? "";
    this.avatarHash = raw["avatar"] as String?;

    if (raw["type"] != null) {
      this.type = WebhookType.from(raw["type"] as int);
    } else {
      this.type = null;
    }

    if (raw["channel_id"] != null) {
      this.channel = CacheableTextChannel<TextGuildChannel>._new(client, Snowflake(raw["channel_id"]), ChannelType.text);
    } else {
      this.channel = null;
    }

    if (raw["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"] as String));
    } else {
      this.guild = null;
    }

    if (raw["user"] != null) {
      this.user = User._new(client, raw["user"] as RawApiMap);
    } else {
      this.user = null;
    }
  }

  /// Executes webhook.
  ///
  /// [wait] - waits for server confirmation of message send before response,
  /// and returns the created message body (defaults to false; when false a message that is not save does not return an error)
  Future<Message?> execute(
      MessageBuilder builder,
      {bool? wait,
      Snowflake? threadId,
      String? avatarUrl,
      String? username}) =>
      client.httpEndpoints.executeWebhook(
        this.id,
        builder,
        token: token,
        threadId: threadId,
        username: username,
        wait: wait,
        avatarUrl: avatarUrl
      );

  @override
  String avatarURL({String format = "webp", int size = 128}) =>
      client.httpEndpoints.userAvatarURL(this.id, this.avatarHash, 0, format: format, size: size);

  /// Edits the webhook.
  Future<Webhook> edit({String? name, SnowflakeEntity? channel, File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension, String? auditReason}) =>
    client.httpEndpoints.editWebhook(this.id, token: this.token, name: name,
        channel: channel, avatarFile: avatarFile, avatarBytes: avatarBytes, encodedAvatar: encodedAvatar, encodedExtension: encodedExtension, auditReason: auditReason);

  /// Deletes the webhook.
  Future<void> delete({String? auditReason}) =>
      client.httpEndpoints.deleteWebhook(this.id, token: token, auditReason: auditReason);

  /// Returns a string representation of this object.
  @override
  String toString() => this.name.toString();
}
