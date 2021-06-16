part of nyxx_lavalink;

class _Cluster {
  /// A reference to the client
  final Nyxx _client;

  /// The client id provided to lavalink;
  final Snowflake _clientId;

  /// All available nodes
  final Map<int, Node> _nodes = {};

  /// Nodes that are currently connecting to server, when a node gets connected
  /// it will be moved to [_nodes], and when reconnecting will be moved here again
  final Map<int, Node> _connectingNodes = {};

  /// A map to keep the assigned node id for each player
  final Map<Snowflake, int> _nodeLocations = {};

  int _lastId = 0;

  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;

  final _logger = logging.Logger("Lavalink cluster");

  /// Emitted when stats are sent from lavalink
  late final Stream<Stats> onStatsReceived;
  /// Emitted when a player gets updated
  late final Stream<PlayerUpdate> onPlayerUpdate;
  /// Emitted when a track starts playing
  late final Stream<TrackStart> onTrackStart;
  /// Emitted when a track ends playing
  late final Stream<TrackEnd> onTrackEnd;
  /// Emitted when a web socket is closed
  late final Stream<WebSocketClosed> onWebSocketClosed;
  /// Emitted everytime an event is received
  late final Stream<Map<String, dynamic>> onRawEvent;

  late final _EventDispatcher _eventDispatcher;

  Future<void> _addNode(NodeOptions nodeOptions, int nodeId) async {
    await Isolate.spawn(_handleNode, this._receivePort.sendPort);

    final isolateSendPort = await this._receiveStream.firstWhere((element) => element is SendPort) as SendPort;

    nodeOptions.clientId = this._clientId;
    nodeOptions.nodeId = nodeId;

    isolateSendPort.send(nodeOptions._toJson());

    // Say the node to start the connection
    isolateSendPort.send({"cmd": "CONNECT"});

    final node = Node._fromOptions(this, nodeOptions, isolateSendPort);

    this._connectingNodes[nodeId] = node;
  }

  Future<void> _handleNodeMessage(dynamic message) async {
    if (message is SendPort) return;
    final map = message as Map<String, dynamic>;

    this._logger.log(logging.Level.FINE, "Receved data from node ${map["nodeId"]}, data: $map");

    switch(map["cmd"]) {
      case "DISPATCH":
        unawaited(this._eventDispatcher.dispatchEvent(map));
        break;

      case "LOG": {
        logging.Level? level;

        switch (map["level"]) {
          case "INFO":
            level = logging.Level.INFO;
            break;

          case "WARNING":
            level = logging.Level.WARNING;
            break;
        }

        _logger.log(level!, map["message"]);
      }
      break;

      case "EXITED": {
        final nodeId = map["nodeId"]! as int;
        this._nodes.remove(nodeId);
        this._connectingNodes.remove(nodeId);

        _logger.log(logging.Level.INFO, "[Node $nodeId] Exited");
      }
      break;

      case "CONNECTED": {
        final node = this._connectingNodes.remove(map["nodeId"] as int);

        if(node != null) {
          this._nodes[node.options.nodeId] = node;

          _logger.log(logging.Level.INFO, "[Node ${map["nodeId"]}] Connected to lavalink");
        }
      }
      break;

      case "DISCONNECTED": {
        final node = this._nodes.remove(map["nodeId"] as int);

        if(node != null) {
          this._connectingNodes[node.options.nodeId] = node;

          node.players.forEach((guildId, _) {
            // this makes possible for a player to be moved to another node
            this._nodeLocations.remove(guildId);
          });

          // Also delete the players, so them can be created again on another node
          node.players.clear();

          _logger.log(logging.Level.INFO, "[Node ${map["nodeId"]}] Disconnected from lavalink");
        }
      }
      break;
    }
  }

  void _registerEvents() {
    this._client.onVoiceServerUpdate.listen((event) async {
      await Future.delayed(const Duration(milliseconds: 100));

      final node = this._nodes[this._nodeLocations[event.guild.id]];

      if(node == null) return;

      final player = node.players[event.guild.id];

      if(player == null) return;

      player._handleServerUpdate(event);
    });

    this._client.onVoiceStateUpdate.listen((event) async {
      if(!(event.raw["d"]["user_id"] == _clientId.toString())) return;
      if(event.state.guild == null) return;

      await Future.delayed(const Duration(milliseconds: 100));

      final node = this._nodes[this._nodeLocations[event.state.guild!.id]];

      if(node == null) return;

      final player = node.players[event.state.guild!.id];

      if(player == null) return;

      player._handleStateUpdate(event);
    });
  }

  /// Creates a new cluster ready to start adding connections
  _Cluster(this._client, this._clientId, [logging.Level? loggingLevel]) {
    this._registerEvents();

    this._eventDispatcher = _EventDispatcher(this);

    this._receiveStream = this._receivePort.asBroadcastStream();

    this._receiveStream.listen(_handleNodeMessage);

    logging.Logger.root.level = loggingLevel ?? logging.Level.INFO;
  }
}

/// Cluster of lavalink nodes
class Cluster extends _Cluster {
  /// Creates a new lavalink cluster
  Cluster(Nyxx client, Snowflake clientId, {logging.Level? loggingLevel}):
        super(client, clientId, loggingLevel);

  /// Returns a map with the nodes connected to lavalink cluster
  Map<int, Node> get connectedNodes => Map.unmodifiable(this._nodes);

  /// Returns a map with the nodes that are actually disconnected from lavalink
  Map<int, Node> get disconnectedNodes => Map.unmodifiable(this._connectingNodes);

  /// Get the best available node, it is recommended to use [getOrCreatePlayerNode] instead
  Node getBestNode() {
    if(this._nodes.isEmpty) throw ClusterException._new("No available nodes");
    if(this._nodes.length == 1) {

      for(final k in this._nodes.keys) {
        // return first node if only one is connected
        return this._nodes[k]!;
      }
    }

    /// As dart doesn't have tuples this will contain the node with few players
    /// Order:
    ///   Index 0 - Node id
    ///   Index 1 - The number of players the node has
    final minNode = <int>[];

    this._nodes.forEach((id, node) {
      if(minNode.isEmpty) {
        minNode.add(id);
        minNode.add(node.players.length);
      } else {
        if (node.players.length < minNode[1]) {
          minNode[0] = id;
          minNode[1] = node.players.length;
        }
      }
    });

    return this._nodes[minNode[0]]!;
  }

  /// Attempts to get the node containing a player for a specific guild id
  ///
  /// if the player doesn't exist, then the best node is retrieved and the player created
  Node getOrCreatePlayerNode(Snowflake guildId) {
    final nodePreview = this._nodeLocations.containsKey(guildId) ?
        this._nodes[_nodeLocations[guildId]] : this.getBestNode();

    Node node;

    if(nodePreview == null) {
      node = this.getBestNode();
    } else {
      node = nodePreview;
    }

    if(!node.players.containsKey(guildId)) {
      node.createPlayer(guildId);
    }

    return node;
  }

  /// Attempts to retrieve a node disconnected from lavalink by its id
  ///
  /// this method does not work with nodes that have exceeded the maximum
  /// reconnect attempts as those get removed from cluster
  Node? getDisconnectedNode(int nodeId) => this._connectingNodes[nodeId];

  /// Adds and initializes a node
  Future<void> addNode(NodeOptions options) async {

    /// Set a tiny delay so we can ensure we don't repeat ids
    await Future.delayed(const Duration(milliseconds: 50));

    this._lastId += 1;

    await this._addNode(options, this._lastId);
  }
}