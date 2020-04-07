part of nyxx;

/// Discord gateways implement a method of user-controlled guild sharding which allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing between separate connections to operate.
///
/// Shard is basically represents single websocket connection to gateway. Each shard can operate on up to 2500 guilds.
class Shard implements Disposable {
  /// The shard id.
  late final int id;

  /// Whether or not the shard is ready.
  bool ready = false;

  /// Emitted when the shard is ready.
  late Stream<Shard> onReady;

  /// Emitted when the shard encounters an error.
  late Stream<Shard> onDisconnect;

  /// A map of guilds the shard is on.
  Cache<Snowflake, Guild> get guilds => _ws._client.guilds;

  bool _acked = false;
  bool _waiting = true;
  Timer? _guildTimer;

  late final Timer _heartbeatTimer;
  late final _WS _ws;
  transport.WebSocket? _socket;
  late int _sequence;
  String? _sessionId;
  late final StreamController<Shard> _onReady;
  late final StreamController<Shard> _onDisconnect;

  Logger _logger = Logger("Websocket");

  int messagesReceived = 0;
  int get eventsSeen => _sequence;

  Shard._new(this._ws, this.id) {
    this._onReady = StreamController<Shard>.broadcast();
    this.onReady = this._onReady.stream;

    this._onDisconnect = StreamController<Shard>.broadcast();
    this.onDisconnect = this._onDisconnect.stream;
  }

  /// Allows to set presence for current shard.
  void setPresence(
      {String? status, bool afk = false, Presence? game, DateTime? since}) {
    var packet = Map<String, dynamic>();

    packet['status'] = status;
    packet['afk'] = afk;

    if (game != null) {
      var gameMap = Map<String, dynamic>();

      gameMap['name'] = game.name;
      gameMap['type'] = game.type._value;
      if (game.url != null) gameMap['url'] = game.url;

      packet['game'] = gameMap;
    }

    if (since != null) {
      packet['since'] = since.millisecondsSinceEpoch;
    } else {
      packet['since'] = null;
    }

    this.send("STATUS_UPDATE", packet);
  }

  /// Syncs all guilds
  void guildSync() => this.send("GUILD_SYNC", this.guilds.keys.toList());

  // Attempts to connect to ws
  void _connect([bool resume = false, bool init = false]) {
    this.ready = false;
    //if (this._socket != null) this._socket!.close();

    if (!init && resume) {
      Future.delayed(const Duration(seconds: 3), () => _connect(true));
      return;
    }

    transport.WebSocket.connect(Uri.parse("${this._ws.gateway}?v=6&encoding=json")).then((ws) {
      _socket = ws;
      _socket!.listen(
          (data) {
            this._handleMsg(_decodeBytes(data), resume);
          },
          onDone: this._handleErr,
          onError: (err) {
            print(err);
            this._handleErr();
          });
    }, onError: (_, __) => Future.delayed(
        const Duration(seconds: 6), () => this._connect()));
  }

  // Decodes zlib compresses string into string json
  Map<String, dynamic> _decodeBytes(dynamic bytes) {
    if (bytes is String) return jsonDecode(bytes) as Map<String, dynamic>;

    var decoded = zlib.decoder.convert(bytes as List<int>);
    var rawStr = utf8.decode(decoded);
    return jsonDecode(rawStr) as Map<String, dynamic>;
  }

  /// Sends WS data.
  void send(String op, dynamic d) {
    this._socket?.add(
        jsonEncode(<String, dynamic>{"op": _OPCodes.matchOpCode(op), "d": d}));
  }

  void _heartbeat() {
    if (this._socket?.closeCode != null) return;
    if (!this._acked) _logger.warning("No ACK received");
    this.send("HEARTBEAT", _sequence);
    this._acked = false;
  }

  Future<void> _handleMsg(Map<String, dynamic> msg, bool resume) async {
    if(this._socket!.closeCode != null) {
      return;
    }

    if (msg['op'] == _OPCodes.dispatch &&
        this._ws._client._options.ignoredEvents.contains(msg['t'] as String))
      return;

    _ws._client._events.onRaw.add(RawEvent._new(this, msg));

    if (msg['s'] != null) this._sequence = msg['s'] as int;

    switch (msg['op'] as int) {
      case _OPCodes.heartbeatAck:
        this._acked = true;
        break;
      case _OPCodes.hello:
        if (this._sessionId == null || !resume) {
          Map<String, dynamic> identifyMsg = <String, dynamic>{
            "token": _ws._client._token,
            "properties": <String, dynamic>{
              "\$os": operatingSystem,
              "\$browser": "nyxx",
              "\$device": "nyxx",
            },
            "large_threshold": this._ws._client._options.largeThreshold,
            "compress": !browser
          };

          identifyMsg['shard'] = <int>[
            this.id,
            _ws._client._options.shardCount
          ];
          this.send("IDENTIFY", identifyMsg);
        } else if (resume) {
          this.send("RESUME", <String, dynamic>{
            "token": _ws._client._token,
            "session_id": this._sessionId,
            "seq": this._sequence
          });
        }

        this._heartbeatTimer = Timer.periodic(
            Duration(milliseconds: msg['d']['heartbeat_interval'] as int),
            (Timer t) => this._heartbeat());

        break;

      case _OPCodes.invalidSession:
        _logger.severe("Invalid session. Reconnecting...");
        _heartbeatTimer.cancel();
        _ws._client._events.onDisconnect.add(DisconnectEvent._new(this, 9));
        this._onDisconnect.add(this);

        if (msg['d'] as bool) {
          Future.delayed(const Duration(seconds: 3), () => _connect(true));
        } else {
          Future.delayed(const Duration(seconds: 6), () => _connect());
        }

        break;

      case _OPCodes.dispatch:
        var j = msg['t'] as String;
        switch (j) {
          case 'READY':
            this._sessionId = msg['d']['session_id'] as String;
            _ws._client.self = ClientUser._new(
                msg['d']['user'] as Map<String, dynamic>, _ws._client);

            this.ready = true;
            _logger.info("Shard connected");
            this._onReady.add(this);

            break;

          case 'GUILD_MEMBERS_CHUNK':
            msg['d']['members'].forEach((dynamic o) {
              var mem = _StandardMember(
                  o as Map<String, dynamic>,
                  /// TODO: NNBD - To consider
                  (_ws._client.guilds[Snowflake(msg['d']['guild_id'])])!,
                  _ws._client);
              _ws._client.users[mem.id] = mem;
              mem.guild.members[mem.id] = mem;
            });
            break;

          case 'MESSAGE_REACTION_REMOVE_ALL':
            var m = MessageReactionsRemovedEvent._new(msg, _ws._client);

            if (m.message != null) {
              _ws._client._events.onMessageReactionsRemoved.add(m);
              _ws._client._events.onMessage.add(m);
            }
            break;

          case 'MESSAGE_REACTION_ADD':
            MessageReactionEvent._new(msg, _ws._client, true);
            break;

          case 'MESSAGE_REACTION_REMOVE':
            MessageReactionEvent._new(msg, _ws._client, false);
            break;

          case 'MESSAGE_DELETE_BULK':
            MessageDeleteBulkEvent._new(msg, _ws._client);
            break;

          case 'CHANNEL_PINS_UPDATE':
            var m = ChannelPinsUpdateEvent._new(msg, _ws._client);

            _ws._client._events.onChannelPinsUpdate.add(m);
            break;

          case 'VOICE_STATE_UPDATE':
            _ws._client._events.onVoiceStateUpdate
                .add(VoiceStateUpdateEvent._new(msg, _ws._client));
            break;

          case 'VOICE_SERVER_UPDATE':
            _ws._client._events.onVoiceServerUpdate
                .add(VoiceServerUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_EMOJIS_UPDATE':
            _ws._client._events.onGuildEmojisUpdate
                .add(GuildEmojisUpdateEvent._new(msg, _ws._client));
            break;

          case 'MESSAGE_CREATE':
            messagesReceived++;

            var m = MessageReceivedEvent._new(msg, _ws._client);
            if (m.message == null) break;

            _ws._client._events.onMessage.add(m);
            _ws._client._events.onMessageReceived.add(m);
            break;

          case 'MESSAGE_DELETE':
            var m = MessageDeleteEvent._new(msg, _ws._client);
            _ws._client._events.onMessage.add(m);
            _ws._client._events.onMessageDelete.add(m);
            break;

          case 'MESSAGE_UPDATE':
            var m = MessageUpdateEvent._new(msg, _ws._client);
            break;

          case 'GUILD_CREATE':
            _ws._client._events.onGuildCreate
                .add(GuildCreateEvent._new(msg, this, _ws._client));

            // TODO: hack? Nvm, it works so it must be good quality code. Leave it alone.
            if (_waiting) {
              if (_guildTimer != null) {
                _guildTimer?.cancel();
                _guildTimer = null;
              }
              _guildTimer = Timer(const Duration(seconds: 6), () {
                _waiting = false;
                _ws.propagateReady();
                _guildTimer = null;
              });
            }

            break;

          case 'GUILD_UPDATE':
            _ws._client._events.onGuildUpdate
                .add(GuildUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_DELETE':
            if (msg['d']['unavailable'] == true)
              _ws._client._events.onGuildUnavailable
                  .add(GuildUnavailableEvent._new(msg, _ws._client));
            else
              _ws._client._events.onGuildDelete
                  .add(GuildDeleteEvent._new(msg, this, _ws._client));
            break;

          case 'GUILD_BAN_ADD':
            _ws._client._events.onGuildBanAdd
                .add(GuildBanAddEvent._new(msg, _ws._client));
            break;

          case 'GUILD_BAN_REMOVE':
            _ws._client._events.onGuildBanRemove
                .add(GuildBanRemoveEvent._new(msg, _ws._client));
            break;

          case 'GUILD_MEMBER_ADD':
            _ws._client._events.onGuildMemberAdd
                .add(GuildMemberAddEvent._new(msg, _ws._client));
            break;

          case 'GUILD_MEMBER_REMOVE':
            _ws._client._events.onGuildMemberRemove
                .add(GuildMemberRemoveEvent._new(msg, _ws._client));
            break;

          case 'GUILD_MEMBER_UPDATE':
            _ws._client._events.onGuildMemberUpdate
                .add(GuildMemberUpdateEvent._new(msg, _ws._client));
            break;

          case 'CHANNEL_CREATE':
            _ws._client._events.onChannelCreate
                .add(ChannelCreateEvent._new(msg, _ws._client));
            break;

          case 'CHANNEL_UPDATE':
            _ws._client._events.onChannelUpdate
                .add(ChannelUpdateEvent._new(msg, _ws._client));
            break;

          case 'CHANNEL_DELETE':
            _ws._client._events.onChannelDelete
                .add(ChannelDeleteEvent._new(msg, _ws._client));
            break;

          case 'TYPING_START':
            var m = TypingEvent._new(msg, _ws._client);

            _ws._client._events.onTyping.add(m);
            break;

          case 'PRESENCE_UPDATE':
            var m = PresenceUpdateEvent._new(msg, _ws._client);
            if (m.member != null) _ws._client._events.onPresenceUpdate.add(m);
            break;

          case 'GUILD_ROLE_CREATE':
            _ws._client._events.onRoleCreate
                .add(RoleCreateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_ROLE_UPDATE':
            _ws._client._events.onRoleUpdate
                .add(RoleUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_ROLE_DELETE':
            _ws._client._events.onRoleDelete
                .add(RoleDeleteEvent._new(msg, _ws._client));
            break;

          case 'USER_UPDATE':
            _ws._client._events.onUserUpdate
                .add(UserUpdateEvent._new(msg, _ws._client));
            break;

          default:
            print("UNKNOWN OPCODE: ${jsonEncode(msg)}");
        }
        break;
    }
  }

  void _handleErr() {
    this._heartbeatTimer.cancel();
    _logger.severe(
        "Shard disconnected. Error code: [${this._socket?.closeCode}] | Error message: [${this._socket?.closeReason}]");
    this.dispose();

    switch (this._socket?.closeCode) {
      case 4004:
      case 4010:
        exit(1);
        break;
      case 4007:
      case 4009:
        Future.delayed(const Duration(seconds: 3), () => this._connect(true));
        break;
      default:
        Future.delayed(const Duration(seconds: 6), () => _connect(false, true));
        break;
    }

    _ws._client._events.onDisconnect
        .add(DisconnectEvent._new(this, this._socket?.closeCode!));
    this._onDisconnect.add(this);
  }

  @override
  Future<void> dispose() async {
    await this._socket?.drain();
    await this._socket?.close(1000);
    this._socket = null;
  }
}
