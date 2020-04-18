part of nyxx;

/// The main place to start with interacting with the Discord API and creating discord bot.
/// From there you can subscribe to various [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// and fetch data from API with provided methods or get cached data.
///
/// Creating new instance of bot:
/// ```
/// Nyxx('<TOKEN>');
/// ```
/// After initializing nyxx you can subscribe to events:
/// ```
/// client.onReady.listen((e) => print('Ready!'));
///
/// client.onRoleCreate.listen((e) {
///   print('Role created with name: ${e.role.name});
/// });
/// ```
/// or setup `CommandsFramework` and `Voice`.
class Nyxx implements Disposable {
  final String _token;
  final DateTime _startTime = DateTime.now();

  late final ClientOptions _options;
  late final _EventController _events;

  late final HttpHandler _http;

  /// The current bot user.
  late ClientUser self;

  /// The bot's OAuth2 app.
  late ClientOAuth2Application app;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  late final Cache<Snowflake, Guild> guilds;

  /// All of the channels the bot can see.
  late final ChannelCache channels;

  /// All of the users the bot can see. Does not have offline users
  /// without `forceFetchUsers` enabled.
  late final Cache<Snowflake, User> users;

  /// True if client is ready.
  bool ready = false;

  /// The current version of `nyxx`
  final String version = _Constants.version;

  /// Current client's shard
  late Shard shard;

  /// Generic Stream for message like events. It includes added reactions, and message deletions.
  /// For received messages refer to [onMessageReceived]
  late Stream<MessageEvent> onMessage;

  /// Emitted when packet is received from gateway.
  late Stream<RawEvent> onRaw;

  /// Emitted when a shard is disconnected from the websocket.
  late Stream<DisconnectEvent> onDisconnect;

  /// Emitted when a successful HTTP response is received.
  late Stream<HttpResponseEvent> onHttpResponse;

  /// Emitted when a HTTP request failed.
  late Stream<HttpErrorEvent> onHttpError;

  /// Sent when the client is ratelimited, either by the ratelimit handler itself,
  /// or when a 429 is received.
  late Stream<RatelimitEvent> onRatelimited;

  /// Emitted when the client is ready. Should be sent only once.
  late Stream<ReadyEvent> onReady;

  /// Emitted when a message is received. It includes private messages.
  late Stream<MessageReceivedEvent> onMessageReceived;

  /// Emitted when private message is received.
  late Stream<MessageReceivedEvent> onDmReceived;

  /// Emitted when channel's pins are updated.
  late Stream<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild's emojis are changed.
  late Stream<GuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited. Old message can be null if isn't cached.
  late Stream<MessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is deleted.
  late Stream<MessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  late Stream<ChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  late Stream<ChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  late Stream<ChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  late Stream<GuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  late Stream<GuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  late Stream<GuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated.
  late Stream<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  late Stream<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a guild becomes unavailable during a guild outage.
  late Stream<GuildUnavailableEvent> onGuildUnavailable;

  /// Emitted when a member joins a guild.
  late Stream<GuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  late Stream<GuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  late Stream<GuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member's presence is changed.
  late Stream<PresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  late Stream<TypingEvent> onTyping;

  /// Emitted when a role is created.
  late Stream<RoleCreateEvent> onRoleCreate;

  /// Emitted when a role is updated.
  late Stream<RoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  late Stream<RoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  late Stream<MessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  late Stream<MessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  late Stream<MessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  late Stream<MessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channel.
  late Stream<VoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild's voice server is updated.
  /// This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  late Stream<VoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when user was updated
  late Stream<UserUpdateEvent> onUserUpdate;

  /// Emitted when bot is mentioned
  late Stream<MessageReceivedEvent> onSelfMention;

  /// Emitted when invite is created
  late Stream<InviteCreatedEvent> onInviteCreated;

  /// Emitted when invite is deleted
  late Stream<InviteDeletedEvent> onInviteDeleted;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  late Stream<MessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmoji;

  /// Logger instance
  Logger _logger = Logger("Client");

  /// Gets an bot invite link with zero permissions
  String get inviteLink => app.getInviteUrl();

  /// Creates and logs in a new client. If [ignoreExceptions] is true (by default is)
  /// isolate will ignore all exceptions and continue to work.
  Nyxx(this._token, {ClientOptions? options, bool ignoreExceptions = true}) {
    if (!setup) {
      throw NoSetupError();
    }

    if (_token.isEmpty) {
      throw NoTokenError();
    }

    if (ignoreExceptions && !browser) {
      Isolate.current.setErrorsFatal(false);

      ReceivePort errorsPort = ReceivePort();
      errorsPort.listen((err) {
        _logger.severe("ERROR: ${err[0]} \n ${err[1]}");
      });
      Isolate.current.addErrorListener(errorsPort.sendPort);
    }

    this._options = options ?? ClientOptions();
    this.guilds = _SnowflakeCache();
    this.channels = ChannelCache._new();
    this.users = _SnowflakeCache();

    this._http = HttpHandler._new(this);

    this._events = _EventController(this);
    this.onSelfMention = this.onMessageReceived.where((event) =>
        event.message?.mentions != null &&
            // TODO: NNBD
        event.message!.mentions.containsKey(this.self.id));
    this.onDmReceived = this.onMessageReceived.where((event) =>
        event.message?.channel is DMChannel ||
        event.message?.channel is GroupDMChannel);
  }

  /// The client's uptime.
  Duration get uptime => DateTime.now().difference(_startTime);

  /// [DateTime] when client was started
  DateTime get startTime => _startTime;

  /// Returns channel with specified id.
  /// If channel is in cache - will be taken from it otherwise API will be called.
  ///
  /// ```
  /// var channel = await client.getChannel<TextChannel>(Snowflake('473853847115137024'));
  /// ```
  Future<Channel?> getChannel(Snowflake id, {Guild? guild}) async {
    if (this.channels.hasKey(id)) return this.channels[id];

    var response = await this._http._execute(JsonRequest._new("/channels/${id.toString()}"));

    if(response is HttpResponseError) {
      return Future.error(response);
    }

    var raw = (response as HttpResponseSuccess).jsonBody as Map<String, dynamic>;

    switch (raw['type'] as int) {
      case 1:
        return DMChannel._new(raw, this);
      case 3:
        return GroupDMChannel._new(raw, this);
      case 0:
      case 5:
        return TextChannel._new(raw, guild!, this);
      case 2:
        return VoiceChannel._new(raw, guild!, this);
      case 4:
        return CategoryChannel._new(raw, guild!, this);
      default:
        return Future.error("Cannot create channel of type [${raw['type']}");
    }
  }

  /// Get user instance with specified id.
  /// If [id] is present in cache it'll be got from cache, otherwise API
  /// will be called.
  ///
  /// ```
  /// var user = client.getClient(Snowflake("302359032612651009"));
  /// ``
  Future<User?> getUser(Snowflake id) async {
    if (this.users.hasKey(id)) return this.users[id];

    var response = await this._http._execute(JsonRequest._new("/users/${id.toString()}"));

    if(response is HttpResponseSuccess) {
      return User._new(response.jsonBody as Map<String, dynamic>, this);
    }

    return Future.error(response);
  }

  /// Creates new guild with provided builder.
  /// Only for bots with less than 10 guilds otherwise it will return Future with error.
  ///
  /// ```
  /// var guildBuilder = GuildBuilder()
  ///                       ..name = "Example Guild"
  ///                       ..roles = [RoleBuilder()..name = "Example Role]
  /// var newGuild = await client.createGuild(guildBuilder);
  /// ```
  Future<Guild> createGuild(GuildBuilder builder) async {
    if (this.guilds.count >= 10) {
      return Future.error(
          "Guild cannot be created if bot is in 10 or more guilds");
    }

    var response = await this._http._execute(JsonRequest._new("/guilds", method: "POST"));

    if(response is HttpResponseSuccess) {
      return Guild._new(this, response.jsonBody as Map<String, dynamic>);
    }

    return Future.error(response);
  }

  /// Gets a webhook by its id and/or token.
  /// If token is supplied authentication is not needed.
  Future<Webhook> getWebhook(String id, {String token = ""}) async {
    var response = await this._http._execute(JsonRequest._new("/webhooks/$id/$token"));

    if(response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, this);
    }

    return Future.error(response);
  }

  /// Gets an [Invite] object with given code.
  /// If the [code] is in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var inv = client.getInvite("YMgffU8");
  /// ```
  Future<Invite> getInvite(String code) async {
    final r = await this._http._execute(JsonRequest._new("/invites/$code"));

    if(r is HttpResponseSuccess) {
      return Invite._new(r.jsonBody as Map<String, dynamic>, this);
    }

    return Future.error(r);
  }

  /// Returns number of shards
  int get shards => this._options.shardCount;

  @override
  Future<void> dispose() async {
    await shard.dispose();
    await guilds.dispose();
    await users.dispose();
    await guilds.dispose();
    await this._events.dispose();
  }
}

/// Sets up default logger
void setupDefaultLogging([Level? loglevel]) {
  Logger.root.level = loglevel ?? Level.ALL;

  Logger.root.onRecord.listen((LogRecord rec) {
    String color = "";
    if (rec.level == Level.WARNING)
      color = "\u001B[33m";
    else if (rec.level == Level.SEVERE)
      color = "\u001B[31m";
    else if (rec.level == Level.INFO)
      color = "\u001B[32m";
    else
      color = "\u001B[0m";

    print('[${DateTime.now()}] '
        '$color[${rec.level.name}] [${rec.loggerName}]\u001B[0m: '
        '${rec.message}');
  });
}
