part of nyxx_interactions;

/// Function that will handle execution of slash command interaction event
typedef SlashCommandHandler = FutureOr<void> Function(SlashCommandInteractionEvent);

/// Function that will handle execution of button interaction event
typedef ButtonInteractionHandler = FutureOr<void> Function(ButtonInteractionEvent);

/// Function that will handle execution of dropdown event
typedef MultiselectInteractionHandler = FutureOr<void> Function(MultiselectInteractionEvent);

/// Interaction extension for Nyxx. Allows use of: Slash Commands.
class Interactions {
  static const _interactionCreateCommand = "INTERACTION_CREATE";
  static const _op0 = 0;

  final Nyxx _client;
  late final _EventController _events;

  final Logger _logger = Logger("Interactions");

  final _commandBuilders = <SlashCommandBuilder>[];
  final _commands = <SlashCommand>[];
  final _commandHandlers = <String, SlashCommandHandler>{};
  final _buttonHandlers = <String, ButtonInteractionHandler>{};
  final _multiselectHandlers = <String, MultiselectInteractionHandler>{};

  /// Emitted when a slash command is sent.
  late final Stream<SlashCommandInteractionEvent> onSlashCommand;

  /// Emitted when a button interaction is received.
  late final Stream<ButtonInteractionEvent> onButtonEvent;

  /// Emitted when a dropdown interaction is received.
  late final Stream<MultiselectInteractionEvent> onMultiselectEvent;

  /// Emitted when a slash command is created by the user.
  late final Stream<SlashCommand> onSlashCommandCreated;

  /// Create new instance of the interactions class.
  Interactions(this._client) {
    _events = _EventController(this);
    _client.options.dispatchRawShardEvent = true;
    _logger.info("Interactions ready");

    _client.onReady.listen((event) async {
      _client.shardManager.rawEvent.listen((event) {
        if (event.rawData["op"] == OPCodes.dispatch && event.rawData["t"] == _interactionCreateCommand) {
          this._logger.fine("Received interaction event: [${event.rawData}]");

          final type = event.rawData["d"]["type"] as int;

          switch (type) {
            case 2:
              _events.onSlashCommand.add(SlashCommandInteractionEvent._new(_client, event.rawData["d"] as RawApiMap));
              break;
            case 3:
              final componentType = event.rawData["d"]["data"]["component_type"] as int;

              switch (componentType) {
                case 2:
                  _events.onButtonEvent.add(ButtonInteractionEvent._new(_client, event.rawData["d"] as Map<String, dynamic>));
                  break;
                case 3:
                  _events.onMultiselectEvent.add(MultiselectInteractionEvent._new(_client, event.rawData["d"] as Map<String, dynamic>));
                  break;
                default:
                  this._logger.warning("Unknown componentType type: [$componentType]; Payload: ${jsonEncode(event.rawData)}");
              }

              break;
            default:
              this._logger.warning("Unknown interaction type: [$type]; Payload: ${jsonEncode(event.rawData)}");
          }
        }
      });
    });
  }

  Future<void> _syncPermissions() async {
    final commandPartition = _partition<SlashCommandBuilder>(
        this._commandBuilders, (element) => element.guild == null);
    final globalCommands = commandPartition.first;
    final groupedGuildCommands =
        _groupSlashCommandBuilders(commandPartition.last);

    final globalBody = globalCommands
      .where((builder) => builder.permissions != null && builder.permissions!.isNotEmpty)
      .map((builder) => {
        "id": builder._id.toString(),
        "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
      })
      .toList();

    await this
        ._client
        .httpEndpoints
        .sendRawRequest("/applications/${this._client.app.id}/commands/permissions", "PUT", body: globalBody);

    for (final entry in groupedGuildCommands.entries) {
      final guildBody = entry.value
        .where((builder) => builder.permissions != null && builder.permissions!.isNotEmpty)
        .map((builder) => {
          "id": builder._id.toString(),
          "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
        })
        .toList();

      await this._client.httpEndpoints.sendRawRequest("/applications/${this._client.app.id}/guilds/${entry.key}/commands/permissions", "PUT", body: guildBody);
    }
  }

  void _extractCommandIds(HttpResponseSuccess response) {
    final body = response.jsonBody as List<dynamic>;
    for (final command in body) {
      final commandMap = command as Map<String, dynamic>;
      this._commandBuilders.firstWhere(
          (b) => b.name == commandMap["name"]
          && b.guild == (commandMap["guild_id"] == null
              ? null
              : Snowflake(commandMap["guild_id"])
          )
        )
        ._setId(Snowflake(commandMap["id"]));
    }
  }

  /// Syncs commands builders with discord after client is ready.
  void syncOnReady() {
    this._client.onReady.listen((_) async {
      await this.sync();
    });
  }

  /// Syncs command builders with discord immediately.
  /// Warning: Client could not be ready at the function execution.
  /// Use [syncOnReady] for proper behavior
  Future<void> sync() async {
    final commandPartition = _partition<SlashCommandBuilder>(this._commandBuilders, (element) => element.guild == null);
    final globalCommands = commandPartition.first;
    final groupedGuildCommands = _groupSlashCommandBuilders(commandPartition.last);

    final globalCommandsResponse = await this._client.httpEndpoints.sendRawRequest(
        "/applications/${this._client.app.id}/commands",
        "PUT",
        body: [
          for(final builder in globalCommands)
            builder.build()
        ]
    );

    if (globalCommandsResponse is HttpResponseSuccess) {
      _extractCommandIds(globalCommandsResponse);
      this._registerCommandHandlers(globalCommandsResponse, globalCommands);
    }

    for(final entry in groupedGuildCommands.entries) {
      final response = await this._client.httpEndpoints.sendRawRequest(
          "/applications/${this._client.app.id}/guilds/${entry.key}/commands",
          "PUT",
          body: [
            for(final builder in entry.value)
              builder.build()
          ]
      );

      if (response is HttpResponseSuccess) {
        _extractCommandIds(response);
        this._registerCommandHandlers(response, entry.value);
      }
    }

    await this._syncPermissions();
    this._logger.info("Finished bulk overriding permissions");

    this._commandBuilders.clear(); // Cleanup after registering command since we don't need this anymore
    this._logger.info("Finished bulk overriding slash commands");

    if (this._commands.isEmpty) {
      return;
    }

    this.onSlashCommand.listen((event) async {
      final commandHash = _determineInteractionCommandHandler(event.interaction);

      if (this._commandHandlers.containsKey(commandHash)) {
        await this._commandHandlers[commandHash]!(event);
      }
    });

    this._logger.info("Finished registering ${this._commandHandlers.length} commands!");

    if (this._buttonHandlers.isNotEmpty) {
      this.onButtonEvent.listen((event) {
        if (this._buttonHandlers.containsKey(event.interaction.customId)) {
          this._buttonHandlers[event.interaction.customId]!(event);
        } else {
          this._logger.warning("Received event for unknown button: ${event.interaction.customId}");
        }
      });
    }

    if (this._multiselectHandlers.isNotEmpty) {
      this.onMultiselectEvent.listen((event) {
        if (this._multiselectHandlers.containsKey(event.interaction.customId)) {
          this._multiselectHandlers[event.interaction.customId]!(event);
        } else {
          this._logger.warning("Received event for unknown dropdown: ${event.interaction.customId}");
        }
      });
    }
  }

  /// Registers callback for button event for given [id]
  void registerButtonHandler(String id, ButtonInteractionHandler handler) =>
      this._buttonHandlers[id] = handler;

  /// Register callback for dropdown event for given [id]
  void registerMultiselectHandler(String id, MultiselectInteractionHandler handler) =>
      this._multiselectHandlers[id] = handler;

  /// Allows to register new [SlashCommandBuilder]
  void registerSlashCommand(SlashCommandBuilder slashCommandBuilder) =>
      this._commandBuilders.add(slashCommandBuilder);

  void _registerCommandHandlers(HttpResponseSuccess response, Iterable<SlashCommandBuilder> builders) {
    final registeredSlashCommands = (response.jsonBody as List<dynamic>).map((e) => SlashCommand._new(e as RawApiMap, this._client));

    for(final registeredCommand in registeredSlashCommands) {
      final matchingBuilder = builders.firstWhere((element) => element.name.toLowerCase() == registeredCommand.name);
      this._assignCommandToHandler(matchingBuilder, registeredCommand);

      this._commands.add(registeredCommand);
    }
  }

  void _assignCommandToHandler(SlashCommandBuilder builder, SlashCommand command) {
    final commandHashPrefix = "${command.id}|${command.name}";

    final subCommands = builder.options.where((element) => element.type == CommandOptionType.subCommand);
    if (subCommands.isNotEmpty) {
      for (final subCommand in subCommands) {
        if (subCommand._handler == null) {
          continue;
        }

        this._commandHandlers["$commandHashPrefix${subCommand.name}"] = subCommand._handler!;
      }

      return;
    }

    final subCommandGroups = builder.options.where((element) => element.type == CommandOptionType.subCommandGroup);
    if (subCommandGroups.isNotEmpty) {
      for (final subCommandGroup in subCommandGroups) {
        final subCommands = subCommandGroup.options?.where((element) => element.type == CommandOptionType.subCommand) ?? [];

        for (final subCommand in subCommands) {
          if (subCommand._handler == null) {
            continue;
          }

          this._commandHandlers["$commandHashPrefix${subCommandGroup.name}${subCommand.name}"] = subCommand._handler!;
        }
      }

      return;
    }

    if (builder._handler != null) {
      this._commandHandlers[commandHashPrefix] = builder._handler!;
    }
  }
}
