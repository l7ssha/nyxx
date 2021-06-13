part of nyxx_lavalink;

/*
  The actual node runner
  Following nyxx design, the node communicates with the cluster using json
  First message will always be the [NodeOptions] data

  Can receive:
  * CONNECT - Attempts to connect to lavalink server
  * RECONNECT - Reconnects to the server
  * DISCONNECT - Disconnects from the server
  * SEND - Sends a given json payload directly to the server through the web socket
  * UPDATE - Updates the current node data
  * SHUTDOWN - Shuts down the node and kills the isolate

  Can send:
  * DISPATCH - Dispatch the given event
  * DISCONNECTED - WebSocket disconnected
  * CONNECTED - WebSocket connected
  * ERROR - An error occurred
  * EXITED - Node shutdown itself
  * LOG - Log something
*/
Future<void> _handleNode(SendPort clusterPort) async {

  WebSocket? socket;
  StreamSubscription? socketStream;

  // First thing to do is to return a send port to the cluster to communicate with the node
  final receivePort = ReceivePort();
  final receiveStream = receivePort.asBroadcastStream();
  clusterPort.send(receivePort.sendPort);

  var node = NodeOptions._fromJson(await receiveStream.first as Map<String, dynamic>);

  final logger = logging.Logger("Node ${node._nodeId}");

  Future<void> processEvent(Map<String, dynamic> json) async {
    switch(json["type"]) {
      case "TrackStartEvent":
        clusterPort.send({"cmd": "DISPATCH", "nodeId": node._nodeId, "event": "TrackStart", "data": json});
        break;

      case "TrackEndEvent":
        clusterPort.send({"cmd": "DISPATCH", "nodeId": node._nodeId, "event": "TrackEnd", "data": json});
        break;

      case "WebSocketClosedEvent":
        clusterPort.send({"cmd": "DISPATCH", "nodeId": node._nodeId, "event": "WebSocketClosed", "data": json});
        break;
    }
  }

  Future<void> process(Map<String, dynamic> json) async {
    switch(json["op"]) {
      case "stats":
        clusterPort.send({"cmd": "DISPATCH", "nodeId": node._nodeId, "event": "Stats", "data": json});
        break;

      case "playerUpdate":
        clusterPort.send({"cmd": "DISPATCH", "nodeId": node._nodeId, "event": "PlayerUpdate", "data": json});
        break;

      case "event":
        await processEvent(json);
        break;
    }
  }

  Future<void> connect() async {
    final address = node.ssl ? "wss://${node.host}:${node.port}" : "ws://${node.host}:${node.port}";
    var actualAttempt = 1;

    while (!(actualAttempt > node.maxConnectAttempts)) {
      try {
        clusterPort.send({"cmd": "LOG", "nodeId": node._nodeId, "level": "INFO", "message": "[Node ${node._nodeId}] Trying to connect to lavalink (${actualAttempt}/${node.maxConnectAttempts})"});

        await WebSocket.connect(address, headers: {
          "Authorization": node.password,
          "Num-Shards": node.shards,
          "User-Id": node.clientId.id
        }).then((ws) {
          socket = ws;

          socketStream = socket!.listen((data) {
            process(jsonDecode(data as String) as Map<String, dynamic>);
          }, onDone: () async {
            clusterPort.send({"cmd": "DISCONNECTED", "nodeId": node._nodeId});
            connect();

            return;
          },
              cancelOnError: true,
              onError: (err) {
                clusterPort.send({"cmd": "ERROR", "nodeId": node._nodeId, "code": socket!.closeCode, "reason": socket!.closeReason});
              }
          );

          return;
        });

        return;
      // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        clusterPort.send({"cmd": "LOG", "nodeId": node._nodeId, "level": "WARNING", "message": "[Node ${node._nodeId}] Error while trying to connect to lavalink; $e"});
      }

      logger.log(logging.Level.WARNING, "Failed to connect to lavalink, retrying");

      clusterPort.send({"cmd": "LOG", "nodeId": node._nodeId, "level": "WARNING", "message": "[Node ${node._nodeId}] Failed to connect to lavalink, retrying"});

      actualAttempt += 1;

      await Future.delayed(const Duration(seconds: 5));
    }

    clusterPort.send({"cmd": "EXITED", "nodeId": node._nodeId});

    return;
  }

  Future<void> disconnect() async {

  }

  Future<void> reconnect() async {

  }

  await for (final msg in receiveStream) {
    switch (msg["cmd"]) {
      case "CONNECT":
        await connect();
        break;

      case "RECONNECT":
        await reconnect();
        break;

      case "DISCONNECT":
        await disconnect();
        break;

      case "SEND":
        socket?.add(jsonEncode(msg["data"]));
        break;

      case "UPDATE":
        node = NodeOptions._fromJson(msg["data"] as Map<String, dynamic>);
        break;

      case "SHUTDOWN": {
        Isolate.current.kill(priority: Isolate.immediate);
      }
      break;

      default:
        break;
    }
  }
}