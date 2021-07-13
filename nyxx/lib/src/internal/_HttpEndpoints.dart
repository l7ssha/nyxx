part of nyxx;

/// Raw access to all http endpoints exposed by nyxx.
/// Allows to execute specific action without any context.
abstract class IHttpEndpoints {
  /// Returns cdn url for given [guildId] and [iconHash].
  /// Requires to specify format and size of returned image.
  /// Format can be webp, png. Size should be power of 2, eg. 512, 1024
  String? getGuildIconUrl(Snowflake guildId, String? iconHash, String format, int size);

  /// Returns cdn url for given [guildId] and [splashHash].
  /// Requires to specify format and size of returned image.
  /// Format can be webp, png. Size should be power of 2, eg. 512, 1024
  String? getGuildSplashURL(Snowflake guildId, String? splashHash, String format, int size);

  /// Returns discovery url for given [guildId] and [splashHash]. Allows to additionally specify [format] and [size] of returned image.
  String? getGuildDiscoveryURL(Snowflake guildId, String? splashHash, {String format = "webp", int size = 128});

  /// Returns url to guild widget for given [guildId]. Additionally accepts [style] parameter.
  String getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]);

  /// Allows to modify guild emoji.
  Future<GuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId,
      {String? name,
      List<Snowflake>? roles,
      File? avatar,
      String? encodedAvatar,
      List<int>? avatarBytes,
      String? encodedExtension});

  /// Removes emoji from given guild
  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId);

  /// Edits role using builder form [role] parameter
  Future<Role> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role,
      {String? auditReason});

  /// Deletes from with given [roleId]
  Future<void> deleteRole(Snowflake guildId, Snowflake roleId,
      {String? auditReason});

  /// Adds role to user
  Future<void> addRoleToUser(
      Snowflake guildId, Snowflake roleId, Snowflake userId,
      {String? auditReason});

  /// Fetches [Guild] object from API
  Future<Guild> fetchGuild(Snowflake guildId);

  /// Fetches [IChannel] from API. Channel cas be cast to wanted type using generics
  Future<T> fetchChannel<T>(Snowflake id);

  /// Returns [IGuildEmoji] for given [emojiId]
  Future<IGuildEmoji> fetchGuildEmoji(Snowflake guildId, Snowflake emojiId);

  /// Creates emoji in given guild
  Future<GuildEmoji> createEmoji(Snowflake guildId, String name,
      {List<SnowflakeEntity>? roles,
      File? imageFile,
      List<int>? imageBytes,
      String? encodedImage,
      String? encodedExtension});

  /// Returns how many user will be pruned in prune operation
  Future<int> guildPruneCount(Snowflake guildId, int days,
      {Iterable<Snowflake>? includeRoles});

  /// Executes actual prune action, returning how many users were pruned.
  Future<int> guildPrune(Snowflake guildId, int days,
      {Iterable<Snowflake>? includeRoles, String? auditReason});

  /// Get all guild bans.
  Stream<Ban> getGuildBans(Snowflake guildId);

  /// Changes nick of self user in given [guildId]
  Future<void> changeGuildSelfNick(Snowflake guildId, String nick);

  /// Get [Ban] object for given [bannedUserId]
  Future<Ban> getGuildBan(Snowflake guildId, Snowflake bannedUserId);

  /// Changes guild owner of guild from bot to [member].
  /// Bot needs to be owner of guild to use that endpoint.
  Future<Guild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member,
      {String? auditReason});

  /// Leaves guild with given id
  Future<void> leaveGuild(Snowflake guildId);

  /// Returns list of all guild invites
  Stream<Invite> fetchGuildInvites(Snowflake guildId);

  /// Fetches audit logs of guild
  Future<AuditLog> fetchAuditLogs(Snowflake guildId,
      {Snowflake? userId, int? actionType, Snowflake? before, int? limit});

  /// Creates new role
  Future<Role> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder,
      {String? auditReason});

  /// Returns list of all voice regions that guild has access to
  Stream<VoiceRegion> fetchGuildVoiceRegions(Snowflake guildId);

  /// Moves guild channel in hierachy.
  Future<void> moveGuildChannel(
      Snowflake guildId, Snowflake channelId, int position,
      {String? auditReason});

  /// Ban user with given id
  Future<void> guildBan(Snowflake guildId, Snowflake userId,
      {int deleteMessageDays = 0, String? auditReason});

  /// Kick user from guild
  Future<void> guildKick(Snowflake guildId, Snowflake userId,
      {String? auditReason});

  /// Unban user with given id
  Future<void> guildUnban(Snowflake guildId, Snowflake userId);

  /// Allows to edit basic guild properties
  Future<Guild> editGuild(Snowflake guildId,
      {String? name,
      int? verificationLevel,
      int? notificationLevel,
      SnowflakeEntity? afkChannel,
      int? afkTimeout,
      String? icon,
      String? auditReason});

  /// Fetches [Member] object from guild
  Future<Member> fetchGuildMember(Snowflake guildId, Snowflake memberId);

  /// Fetches list of members from guild.
  /// Requires GUILD_MEMBERS intent to work properly.
  Stream<Member> fetchGuildMembers(Snowflake guildId,
      {int limit = 1, Snowflake? after});

  /// Searches guild for user with [query] parameter
  /// Requires GUILD_MEMBERS intent to work properly.
  Stream<Member> searchGuildMembers(Snowflake guildId, String query,
      {int limit = 1});

  /// Returns all [Webhook]s in given channel
  Stream<Webhook> fetchChannelWebhooks(Snowflake channelId);

  /// Deletes guild. Requires bot to be owner of guild
  Future<void> deleteGuild(Snowflake guildId);

  /// Returns all roles of guild
  Stream<Role> fetchGuildRoles(Snowflake guildId);

  /// Returns url to user avatar
  String userAvatarURL(Snowflake userId, String? avatarHash, int discriminator,
      {String format = "webp", int size = 128});

  /// Fetches [User] object for given [userId]
  Future<User> fetchUser(Snowflake userId);

  /// "Edits" guild member. Allows to manipulate other guild users.
  Future<void> editGuildMember(Snowflake guildId, Snowflake memberId,
      {String? nick,
      List<SnowflakeEntity>? roles,
      bool? mute,
      bool? deaf,
      SnowflakeEntity? channel,
      String? auditReason});

  /// Removes role from user
  Future<void> removeRoleFromUser(
      Snowflake guildId, Snowflake roleId, Snowflake userId,
      {String? auditReason});

  /// Returns invites for given channel. Includes additional metadata.
  Stream<InviteWithMeta> fetchChannelInvites(Snowflake channelId);

  /// Allows to edit permission for channel
  Future<void> editChannelPermissions(
      Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity,
      {String? auditReason});

  /// Allows to edit permission of channel (channel overrides)
  Future<void> editChannelPermissionOverrides(
      Snowflake channelId, PermissionOverrideBuilder permissionBuilder,
      {String? auditReason});

  /// Deletes permission overrides for given entity [id]
  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id,
      {String? auditReason});

  /// Creates new invite for given [channelId]
  Future<Invite> createInvite(Snowflake channelId,
      {int? maxAge,
      int? maxUses,
      bool? temporary,
      bool? unique,
      String? auditReason});

  /// Sends message in channel with given [channelId] using [builder]
  Future<Message> sendMessage(Snowflake channelId, MessageBuilder builder);

  /// Fetches single message with given [messageId]
  Future<Message> fetchMessage(Snowflake channelId, Snowflake messageId);

  /// Bulk removes messages in given [channelId].
  Future<void> bulkRemoveMessages(
      Snowflake channelId, Iterable<SnowflakeEntity> messagesIds);

  /// Downloads messages in given channel.
  Stream<Message> downloadMessages(Snowflake channelId,
      {int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around});

  /// Crates new webhook
  Future<Webhook> createWebhook(Snowflake channelId, String name,
      {File? avatarFile,
      List<int>? avatarBytes,
      String? encodedAvatar,
      String? encodedExtension,
      String? auditReason});

  /// Returns all pinned messages in channel
  Stream<Message> fetchPinnedMessages(Snowflake channelId);

  /// Triggers typing indicator in channel
  Future<void> triggerTyping(Snowflake channelId);

  /// Cross posts message in new channel to all subsribed channels
  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId);

  /// Sends message and creates new thread in one action.
  Future<ThreadPreviewChannel> createThreadWithMessage(Snowflake channelId, Snowflake messageId, ThreadBuilder builder);

  /// Creates new thread.
  Future<ThreadPreviewChannel> createThread(Snowflake channelId, ThreadBuilder builder);

  /// Returns all member of given thread
  Stream<ThreadMember> getThreadMembers(Snowflake channelId, Snowflake guildId);

  /// Joins thread with given id
  Future<void> joinThread(Snowflake channelId);

  /// Adds member to thread given bot has sufficient permissions
  Future<void> addThreadMember(Snowflake channelId, Snowflake userId);

  /// Leave thread with given id
  Future<void> leaveThread(Snowflake channelId);

  /// Removes member from thread given bot has sufficient permissions
  Future<void> removeThreadMember(Snowflake channelId, Snowflake userId);

  /// Returns all active threads in given channel
  Future<ThreadListResultWrapper> fetchActiveThreads(Snowflake channelId);

  /// Returns all public archived thread in given channel
  Future<ThreadListResultWrapper> fetchPublicArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all private archived thread in given channel
  Future<ThreadListResultWrapper> fetchPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Returns all joined private archived thread in given channel
  Future<ThreadListResultWrapper> fetchJoinedPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit});

  /// Removes all embeds from given message
  Future<Message> suppressMessageEmbeds(
      Snowflake channelId, Snowflake messageId);

  /// Edits message with given id using [builder]
  Future<Message> editMessage(Snowflake channelId, Snowflake messageId, MessageBuilder builder);

  /// Creates reaction with given [emoji] on given message
  Future<void> createMessageReaction(
      Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes all reactions for given [emoji] from message
  Future<void> deleteMessageReaction(
      Snowflake channelId, Snowflake messageId, IEmoji emoji);

  /// Deletes all reactions of given user from message.
  Future<void> deleteMessageUserReaction(
      Snowflake channelId, Snowflake messageId, IEmoji emoji, Snowflake userId);

  /// Deletes all reactions on given message
  Future<void> deleteMessageAllReactions(
      Snowflake channelId, Snowflake messageId);

  /// Deletes message from given channel
  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId,
      {String? auditReason});

  /// Pins message in channel
  Future<void> pinMessage(Snowflake channelId, Snowflake messageId);

  /// Unpins message from channel
  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId);

  /// Edits self user.
  Future<User> editSelfUser(
      {String? username,
      File? avatarFile,
      List<int>? avatarBytes,
      String? encodedAvatar,
      String? encodedExtension});

  /// Deletes invite with given [code]
  Future<void> deleteInvite(String code, {String? auditReason});

  /// Deletes webhook with given [id] using bot permissions or [token] if supplied
  Future<void> deleteWebhook(Snowflake id, {String token = "", String? auditReason});

  Future<Webhook> editWebhook(Snowflake webhookId,
      {String token = "",
      String? name,
      SnowflakeEntity? channel,
      File? avatarFile,
      List<int>? avatarBytes,
      String? encodedAvatar,
      String? encodedExtension,
      String? auditReason});

  /// Executes [Webhook] -- sends message using [Webhook]
  /// To execute webhook in thread use [threadId] parameter.
  /// Webhooks can have overridden [avatarUrl] and [username] per each
  /// execution.
  ///
  /// If [wait] is set to true -- request will return resulting message.
  Future<Message?> executeWebhook(
      Snowflake webhookId,
      MessageBuilder builder,
      {String? token,
        bool? wait,
        String? avatarUrl,
        String? username,
        Snowflake? threadId});

  /// Fetches webhook using its [id] and optionally [token].
  /// If [token] is specified it will be used to fetch webhook data.
  /// If not authenticated or missing permissions
  /// for given webhook token can be used.
  Future<Webhook> fetchWebhook(Snowflake id, {String token = ""});

  /// Fetches invite based on specified [code]
  Future<Invite> fetchInvite(String code);

  /// Returns url for sticker.
  String stickerUrl(String stickerHash, String extension);

  /// Returns url for given [emojiId]
  String emojiUrl(Snowflake emojiId);

  /// Creates and returns [DMChannel] for user with given [userId].
  Future<DMChannel> createDMChannel(Snowflake userId);

  /// Used to send a request including standard bot authentication.
  Future<_HttpResponse> sendRawRequest(String url, String method, {dynamic body, dynamic headers});

  /// Fetches preview of guild
  Future<GuildPreview> fetchGuildPreview(Snowflake guildId);

  /// Allows to create guild channel.
  Future<IChannel> createGuildChannel(Snowflake guildId, ChannelBuilder channelBuilder);

  /// Deletes guild channel
  Future<void> deleteChannel(Snowflake channelId);

  /// Gets the stage instance associated with the Stage channel, if it exists.
  Future<StageChannelInstance> getStageChannelInstance(Snowflake channelId);

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance(Snowflake channelId);

  /// Creates a new Stage instance associated to a Stage channel.
  Future<StageChannelInstance> createStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel});

  /// Updates fields of an existing Stage instance.
  Future<StageChannelInstance> updateStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel});

  /// Allows to edit guild channel. Resulting updated channel can by cast using generics
  Future<T> editGuildChannel<T extends GuildChannel>(Snowflake channelId, ChannelBuilder builder, {String? auditReason});

  /// Returns single nitro sticker
  Future<StandardSticker> getSticker(Snowflake id);

  /// Returns all nitro sticker packs
  Stream<StickerPack> listNitroStickerPacks();

  /// Fetches all [GuildSticker]s in given [Guild]
  Stream<GuildSticker> fetchGuildStickers(Snowflake guildId);

  /// Fetches [GuildSticker]
  Future<GuildSticker> fetchGuildSticker(Snowflake guildId, Snowflake stickerId);

  /// Creates [GuildSticker] in given [Guild]
  Future<GuildSticker> createGuildSticker(Snowflake guildId, StickerBuilder builder);

  /// Edits [GuildSticker]. Only allows to update sticker metadata
  Future<GuildSticker> editGuildSticker(Snowflake guildId, Snowflake stickerId, StickerBuilder builder);

  /// Deletes [GuildSticker] for [Guild]
  Future<void> deleteGuildSticker(Snowflake guildId, Snowflake stickerId);
}

class _HttpEndpoints implements IHttpEndpoints {
  late final _HttpHandler _httpClient;
  final INyxx _client;

  _HttpEndpoints._new(this._client) {
    this._httpClient = this._client._http;
  }

  @override
  String? getGuildIconUrl(
      Snowflake guildId, String? iconHash, String format, int size) {
    if (iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/icons/$guildId/$iconHash.$format?size=$size";
    }

    return null;
  }

  @override
  String? getGuildSplashURL(
      Snowflake guildId, String? splashHash, String format, int size) {
    if (splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/splashes/$guildId/$splashHash.$format?size=$size";
    }

    return null;
  }

  @override
  String? getGuildDiscoveryURL(Snowflake guildId, String? splashHash,
      {String format = "webp", int size = 128}) {
    if (splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/discovery-splashes/$guildId/$splashHash.$format?size=$size";
    }

    return null;
  }

  @override
  String getGuildWidgetUrl(Snowflake guildId, [String style = "shield"]) =>
      "https://cdn.${Constants.cdnHost}/guilds/$guildId/widget.png?style=$style";

  @override
  Future<GuildEmoji> editGuildEmoji(Snowflake guildId, Snowflake emojiId,
      {String? name,
      List<Snowflake>? roles,
      File? avatar,
      String? encodedAvatar,
      List<int>? avatarBytes,
      String? encodedExtension}) async {
    if (name == null && roles == null) {
      return Future.error(
          ArgumentError("Both name and roles fields cannot be null"));
    }

    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (roles != null) "roles": roles.map((r) => r.toString())
    };

    final uploadString = Utils.getBase64UploadString(
        file: avatar,
        fileBytes: avatarBytes,
        base64EncodedFile: encodedAvatar,
        fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/emojis/$emojiId",
        method: "PATCH",
        body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(
          _client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteGuildEmoji(Snowflake guildId, Snowflake emojiId) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/emojis/$emojiId",
          method: "DELETE"));

  @override
  Future<Role> editRole(Snowflake guildId, Snowflake roleId, RoleBuilder role,
      {String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/roles/$roleId",
        method: "PATCH",
        body: role.build(),
        auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Role._new(
          _client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteRole(Snowflake guildId, Snowflake roleId,
          {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles/$roleId",
          method: "DELETE", auditLog: auditReason));

  @override
  Future<void> addRoleToUser(
          Snowflake guildId, Snowflake roleId, Snowflake userId,
          {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new(
          "/guilds/$guildId/members/$userId/roles/$roleId",
          method: "PUT",
          auditLog: auditReason));

  @override
  Future<Guild> fetchGuild(Snowflake guildId) async {
    final response =
        await _httpClient._execute(BasicRequest._new("/guilds/$guildId"));

    if (response is HttpResponseSuccess) {
      return Guild._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<T> fetchChannel<T>(Snowflake id) async {
    final response =
        await _httpClient._execute(BasicRequest._new("/channels/$id"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    final raw =
        (response as HttpResponseSuccess)._jsonBody as RawApiMap;
    return IChannel._deserialize(_client, raw) as T;
  }

  @override
  Future<IGuildEmoji> fetchGuildEmoji(
      Snowflake guildId, Snowflake emojiId) async {
    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/emojis/$emojiId"));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(
          _client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<GuildEmoji> createEmoji(Snowflake guildId, String name,
      {List<SnowflakeEntity>? roles,
      File? imageFile,
      List<int>? imageBytes,
      String? encodedImage,
      String? encodedExtension}) async {
    final body = <String, dynamic>{
      "name": name,
      if (roles != null) "roles": roles.map((r) => r.id.toString())
    };

    final uploadString = Utils.getBase64UploadString(
        file: imageFile,
        fileBytes: imageBytes,
        base64EncodedFile: encodedImage,
        fileExtension: encodedExtension);
    if (uploadString != null) {
      body["image"] = uploadString;
    }

    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/emojis",
        method: "POST",
        body: body));

    if (response is HttpResponseSuccess) {
      return GuildEmoji._new(
          _client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Future<int> guildPruneCount(Snowflake guildId, int days,
      {Iterable<Snowflake>? includeRoles}) async {
    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/prune", queryParams: {
      "days": days.toString(),
      if (includeRoles != null)
        "include_roles": includeRoles.map((e) => e.id.toString())
    }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  @override
  Future<int> guildPrune(Snowflake guildId, int days,
      {Iterable<Snowflake>? includeRoles, String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/prune",
        method: "POST",
        auditLog: auditReason,
        queryParams: {
          "days": days.toString()
        },
        body: {
          if (includeRoles != null)
            "include_roles": includeRoles.map((e) => e.id.toString())
        }));

    if (response is HttpResponseSuccess) {
      return response.jsonBody["pruned"] as int;
    }

    return Future.error(response);
  }

  @override
  Stream<Ban> getGuildBans(Snowflake guildId) async* {
    final response =
        await _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final obj in (response as HttpResponseSuccess)._jsonBody) {
      yield Ban._new(obj as RawApiMap, _client);
    }
  }

  @override
  Future<void> changeGuildSelfNick(Snowflake guildId, String nick) async =>
      _httpClient._execute(BasicRequest._new(
          "/guilds/$guildId/members/@me/nick",
          method: "PATCH",
          body: {"nick": nick}));

  @override
  Future<Ban> getGuildBan(Snowflake guildId, Snowflake bannedUserId) async {
    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/bans/$bannedUserId"));

    if (response is HttpResponseSuccess) {
      return Ban._new(response.jsonBody as RawApiMap, _client);
    }

    return Future.error(response);
  }

  @override
  Future<Guild> changeGuildOwner(Snowflake guildId, SnowflakeEntity member, {String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId",
        method: "PATCH",
        auditLog: auditReason,
        body: {"owner_id": member.id}));

    if (response is HttpResponseSuccess) {
      return Guild._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> leaveGuild(Snowflake guildId) async => _httpClient._execute(
      BasicRequest._new("/users/@me/guilds/$guildId", method: "DELETE"));

  @override
  Stream<Invite> fetchGuildInvites(Snowflake guildId) async* {
    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield Invite._new(raw as RawApiMap, _client);
    }
  }

  @override
  Future<AuditLog> fetchAuditLogs(Snowflake guildId,
      {Snowflake? userId,
      int? actionType,
      Snowflake? before,
      int? limit}) async {
    final queryParams = <String, String>{
      if (userId != null) "user_id": userId.toString(),
      if (actionType != null) "action_type": actionType.toString(),
      if (before != null) "before": before.toString(),
      if (limit != null) "limit": limit.toString()
    };

    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/audit-logs",
        queryParams: queryParams));

    if (response is HttpResponseSuccess) {
      return AuditLog._new(response.jsonBody as RawApiMap, _client);
    }

    return Future.error(response);
  }

  @override
  Future<Role> createGuildRole(Snowflake guildId, RoleBuilder roleBuilder,
      {String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/roles",
        method: "POST",
        auditLog: auditReason,
        body: roleBuilder.build()));

    if (response is HttpResponseSuccess) {
      return Role._new(
          _client, response.jsonBody as RawApiMap, guildId);
    }

    return Future.error(response);
  }

  @override
  Stream<VoiceRegion> fetchGuildVoiceRegions(Snowflake guildId) async* {
    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/regions"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield VoiceRegion._new(raw as RawApiMap);
    }
  }

  @override
  Future<void> moveGuildChannel(
      Snowflake guildId, Snowflake channelId, int position,
      {String? auditReason}) async {
    await _httpClient._execute(BasicRequest._new("/guilds/$guildId/channels",
        method: "PATCH",
        auditLog: auditReason,
        body: {"id": channelId.toString(), "position": position}));
  }

  @override
  Future<void> guildBan(Snowflake guildId, Snowflake userId,
          {int deleteMessageDays = 0, String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/bans/$userId",
          method: "PUT",
          auditLog: auditReason,
          body: {"delete-message-days": deleteMessageDays}));

  @override
  Future<void> guildKick(Snowflake guildId, Snowflake userId,
          {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/$userId",
          method: "DELTE", auditLog: auditReason));

  @override
  Future<void> guildUnban(Snowflake guildId, Snowflake userId) async =>
      _httpClient._execute(
          BasicRequest._new("/guilds/$guildId/bans/$userId", method: "DELETE"));

  @override
  Future<Guild> editGuild(Snowflake guildId,
      {String? name,
      int? verificationLevel,
      int? notificationLevel,
      SnowflakeEntity? afkChannel,
      int? afkTimeout,
      String? icon,
      String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (verificationLevel != null) "verification_level": verificationLevel,
      if (notificationLevel != null)
        "default_message_notifications": notificationLevel,
      if (afkChannel != null) "afk_channel_id": afkChannel,
      if (afkTimeout != null) "afk_timeout": afkTimeout,
      if (icon != null) "icon": icon
    };

    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId",
        method: "PATCH",
        auditLog: auditReason,
        body: body));

    if (response is HttpResponseSuccess) {
      return Guild._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<Member> fetchGuildMember(Snowflake guildId, Snowflake memberId) async {
    final response = await _httpClient
        ._execute(BasicRequest._new("/guilds/$guildId/members/$memberId"));

    if (response is HttpResponseSuccess) {
      final member = Member._new(
          _client, response.jsonBody as RawApiMap, guildId);

      if (_client._cacheOptions.memberCachePolicyLocation.http &&
          _client._cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      return member;
    }

    return Future.error(response);
  }

  @override
  Stream<Member> fetchGuildMembers(Snowflake guildId, {int limit = 1, Snowflake? after}) async* {
    final request = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/members", queryParams: {
      "limit": limit.toString(),
      if (after != null) "after": after.toString()
    }));

    if (request is HttpResponseError) {
      yield* Stream.error(request);
      return;
    }

    for (final rawMember
        in (request as HttpResponseSuccess)._jsonBody as List<dynamic>) {
      final member =
          Member._new(_client, rawMember as RawApiMap, guildId);

      if (_client._cacheOptions.memberCachePolicyLocation.http &&
          _client._cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      yield member;
    }
  }

  @override
  Stream<Member> searchGuildMembers(Snowflake guildId, String query, {int limit = 1}) async* {
    if (query.isEmpty) {
      yield* Stream.error(ArgumentError("`query` parameter cannot be empty. If you want to request all members use `fetchGuildMembers`"));
      return;
    }

    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/members/search",
        queryParams: {"query": query, "limit": limit.toString()}));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final RawApiMap memberData
        in (response as HttpResponseSuccess)._jsonBody) {
      final member = Member._new(_client, memberData, guildId);

      if (_client._cacheOptions.memberCachePolicyLocation.http &&
          _client._cacheOptions.memberCachePolicy.canCache(member)) {
        member.guild.getFromCache()?.members[member.id] = member;
      }

      yield member;
    }
  }

  @override
  Stream<Webhook> fetchChannelWebhooks(Snowflake channelId) async* {
    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/webhooks"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final raw in (response as HttpResponseSuccess)._jsonBody) {
      yield Webhook._new(raw as RawApiMap, _client);
    }
  }

  @override
  Future<void> deleteGuild(Snowflake guildId) async => _httpClient
      ._execute(BasicRequest._new("/guilds/$guildId", method: "DELETE"));

  @override
  Stream<Role> fetchGuildRoles(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/roles"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final rawRole in (response as HttpResponseSuccess)._jsonBody.values) {
      yield Role._new(_client, rawRole as RawApiMap, guildId);
    }
  }

  @override
  String userAvatarURL(Snowflake userId, String? avatarHash, int discriminator,
      {String format = "webp", int size = 128}) {
    if (avatarHash != null) {
      return "https://cdn.${Constants.cdnHost}/avatars/$userId/$avatarHash.$format?size=$size";
    }

    return "https://cdn.${Constants.cdnHost}/embed/avatars/${discriminator % 5}.png?size=$size";
  }

  @override
  Future<User> fetchUser(Snowflake userId) async {
    final response = await _httpClient._execute(BasicRequest._new("/users/$userId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return User._new(_client, response._jsonBody as RawApiMap);
  }

  @override
  Future<void> editGuildMember(Snowflake guildId, Snowflake memberId,
      {String? nick,
      List<SnowflakeEntity>? roles,
      bool? mute,
      bool? deaf,
      SnowflakeEntity? channel,
      String? auditReason}) {
    final body = <String, dynamic>{
      if (nick != null) "nick": nick,
      if (roles != null) "roles": roles.map((f) => f.id.toString()).toList(),
      if (mute != null) "mute": mute,
      if (deaf != null) "deaf": deaf,
      if (channel != null) "channel_id": channel.id.toString()
    };

    return _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/members/$memberId",
        method: "PATCH",
        auditLog: auditReason,
        body: body));
  }

  @override
  Future<void> removeRoleFromUser(
          Snowflake guildId, Snowflake roleId, Snowflake userId,
          {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new(
          "/guilds/$guildId/members/$userId/roles/$roleId",
          method: "DELETE",
          auditLog: auditReason));

  @override
  Stream<InviteWithMeta> fetchChannelInvites(Snowflake channelId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    final bodyValues = (response as HttpResponseSuccess).jsonBody.values.first;

    for (final val in bodyValues as Iterable<RawApiMap>) {
      yield InviteWithMeta._new(val, _client);
    }
  }

  @override
  Future<void> editChannelPermissions(
      Snowflake channelId, PermissionsBuilder perms, SnowflakeEntity entity,
      {String? auditReason}) async {
    final permSet = perms.build();

    await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/permissions/${entity.id.toString()}",
        method: "PUT",
        body: {
          "type": entity is Role ? "role" : "member",
          "allow": permSet.allow,
          "deny": permSet.deny
        },
        auditLog: auditReason));
  }

  @override
  Future<void> editChannelPermissionOverrides(
      Snowflake channelId, PermissionOverrideBuilder permissionBuilder,
      {String? auditReason}) async {
    final permSet = permissionBuilder.build();

    await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/permissions/${permissionBuilder.id.toString()}",
        method: "PUT",
        body: {
          "type": permissionBuilder.type,
          "allow": permSet.allow,
          "deny": permSet.deny
        },
        auditLog: auditReason));
  }

  @override
  Future<void> deleteChannelPermission(Snowflake channelId, SnowflakeEntity id,
      {String? auditReason}) async {
    await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/permissions/$id",
        method: "PUT",
        auditLog: auditReason));
  }

  @override
  Future<Invite> createInvite(Snowflake channelId,
      {int? maxAge,
      int? maxUses,
      bool? temporary,
      bool? unique,
      String? auditReason}) async {
    final body = {
      if (maxAge != null) "max_age": maxAge,
      if (maxUses != null) "max_uses": maxUses,
      if (temporary != null) "temporary": temporary,
      if (unique != null) "unique": unique,
    };

    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/invites",
        method: "POST",
        body: body,
        auditLog: auditReason));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return InviteWithMeta._new(
        (response as HttpResponseSuccess).jsonBody as RawApiMap,
        _client);
  }

  @override
  Future<Message> sendMessage(Snowflake channelId, MessageBuilder builder) async {
    if (!builder.canBeUsedAsNewMessage()) {
      return Future.error(ArgumentError("Cannot sent message when MessageBuilder doesn't have set either content, embed or files"));
    }

    _HttpResponse response;
    if (builder._hasFiles()) {
      response = await _httpClient._execute(MultipartRequest._new(
          "/channels/$channelId/messages", builder.files!.map((e) => e._asMultipartFile()).toList(),
          method: "POST", fields: builder.build(_client)));
    } else {
      response = await _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages",
          body: builder.build(_client),
          method: "POST"));
    }

    if (response is HttpResponseSuccess) {
      return Message._deserialize(
          _client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<Message> fetchMessage(Snowflake channelId, Snowflake messageId) async {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/messages/$messageId"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return Message._deserialize(_client, (response as HttpResponseSuccess)._jsonBody as RawApiMap);
  }

  @override
  Future<void> bulkRemoveMessages(
      Snowflake channelId, Iterable<SnowflakeEntity> messagesIds) async {
    await for (final chunk in Utils.chunk(messagesIds.toList(), 90)) {
      await _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/bulk-delete",
          method: "POST",
          body: {"messages": chunk.map((f) => f.id.toString()).toList()}));
    }
  }

  @override
  Stream<Message> downloadMessages(Snowflake channelId,
      {int limit = 50,
      Snowflake? after,
      Snowflake? before,
      Snowflake? around}) async* {
    final queryParams = {
      "limit": limit.toString(),
      if (after != null) "after": after.toString(),
      if (before != null) "before": before.toString(),
      if (around != null) "around": around.toString()
    };

    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/messages",
        queryParams: queryParams));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final val in await (response as HttpResponseSuccess)._jsonBody) {
      yield Message._deserialize(_client, val as RawApiMap);
    }
  }

  @override
  Future<T> editGuildChannel<T extends GuildChannel>(Snowflake channelId, ChannelBuilder builder, {String? auditReason}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId",
        method: "PATCH",
        body: builder.build(),
        auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return IChannel._deserialize(_client, response.jsonBody as RawApiMap) as T;
    }

    return Future.error(response);
  }

  @override
  Future<Webhook> createWebhook(Snowflake channelId, String name,
      {File? avatarFile,
      List<int>? avatarBytes,
      String? encodedAvatar,
      String? encodedExtension,
      String? auditReason}) async {
    if (name.isEmpty || name.length > 80) {
      return Future.error(ArgumentError(
          "Webhook name cannot be shorter than 1 character and longer than 80 characters"));
    }

    final body = <String, dynamic>{"name": name};

    final uploadString = Utils.getBase64UploadString(
        file: avatarFile,
        fileBytes: avatarBytes,
        base64EncodedFile: encodedAvatar,
        fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/webhooks",
        method: "POST",
        body: body,
        auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as RawApiMap, _client);
    }

    return Future.error(response);
  }

  @override
  Stream<Message> fetchPinnedMessages(Snowflake channelId) async* {
    final response = await _httpClient
        ._execute(BasicRequest._new("/channels/$channelId/pins"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
      return;
    }

    for (final val in (response as HttpResponseSuccess)._jsonBody.values.first
        as Iterable<RawApiMap>) {
      yield Message._deserialize(_client, val);
    }
  }

  @override
  Future<void> triggerTyping(Snowflake channelId) => _httpClient._execute(BasicRequest._new("/channels/$channelId/typing", method: "POST"));

  @override
  Future<void> crossPostGuildMessage(Snowflake channelId, Snowflake messageId) async =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/crosspost",
          method: "POST"));

  @override
  Future<ThreadPreviewChannel> createThreadWithMessage(
      Snowflake channelId, Snowflake messageId, ThreadBuilder builder) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/messages/$messageId/threads",
        method: "POST", body: builder.build(),),);

    if (response is HttpResponseSuccess) {
      return ThreadPreviewChannel._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }


  @override
  Future<ThreadPreviewChannel> createThread(
      Snowflake channelId, ThreadBuilder builder) async {
    final response = await _httpClient._execute(BasicRequest._new(
      "/channels/$channelId/threads",
      method: "POST", body: builder.build(),),);

    if (response is HttpResponseSuccess) {
      return ThreadPreviewChannel._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Stream<ThreadMember> getThreadMembers(Snowflake channelId, Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new("/channels/$channelId/thread-members"));

    if (response is HttpResponseSuccess) {
      final guild = new _GuildCacheable(_client, guildId);

      for(final rawThreadMember in response.jsonBody as List<dynamic>) {
        yield ThreadMember._new(_client, rawThreadMember as RawApiMap, guild);
      }
    }

    yield* Stream.error(response);
  }

  // TODO: Manage message flags better
  @override
  Future<Message> suppressMessageEmbeds(
      Snowflake channelId, Snowflake messageId) async {
    final body = <String, dynamic>{"flags": 1 << 2};

    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/messages/$messageId",
        method: "PATCH",
        body: body));

    if (response is HttpResponseSuccess) {
      return Message._deserialize(
          _client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<Message> editMessage(Snowflake channelId, Snowflake messageId, MessageBuilder builder) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/messages/$messageId",
        method: "PATCH",
        body: builder.build(_client)));

    if (response is HttpResponseSuccess) {
      return Message._deserialize(
          _client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> createMessageReaction(
          Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me",
          method: "PUT"));

  @override
  Future<void> deleteMessageReaction(
          Snowflake channelId, Snowflake messageId, IEmoji emoji) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/@me",
          method: "DELETE"));

  @override
  Future<void> deleteMessageUserReaction(Snowflake channelId,
          Snowflake messageId, IEmoji emoji, Snowflake userId) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions/${emoji.encodeForAPI()}/$userId",
          method: "DELETE"));

  @override
  Future<void> deleteMessageAllReactions(
          Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId/reactions",
          method: "DELETE"));

  @override
  Future<void> deleteMessage(Snowflake channelId, Snowflake messageId,
          {String? auditReason}) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/messages/$messageId",
          method: "DELETE",
          auditLog: auditReason));

  @override
  Future<void> pinMessage(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/pins/$messageId",
          method: "PUT"));

  @override
  Future<void> unpinMessage(Snowflake channelId, Snowflake messageId) =>
      _httpClient._execute(BasicRequest._new(
          "/channels/$channelId/pins/$messageId",
          method: "DELETE"));

  @override
  Future<User> editSelfUser(
      {String? username,
      File? avatarFile,
      List<int>? avatarBytes,
      String? encodedAvatar,
      String? encodedExtension}) async {
    final body = <String, dynamic>{if (username != null) "username": username};

    final uploadString = Utils.getBase64UploadString(
        file: avatarFile,
        fileBytes: avatarBytes,
        base64EncodedFile: encodedAvatar,
        fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient
        ._execute(BasicRequest._new("/users/@me", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return User._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteInvite(String code, {String? auditReason}) async =>
      _httpClient._execute(BasicRequest._new("/invites/$code",
          method: "DELETE", auditLog: auditReason));

  @override
  Future<void> deleteWebhook(Snowflake id,
          {String token = "", String? auditReason}) =>
      _httpClient._execute(BasicRequest._new("/webhooks/$id/$token",
          method: "DELETE", auditLog: auditReason));

  @override
  Future<Webhook> editWebhook(Snowflake webhookId,
      {String token = "",
      String? name,
      SnowflakeEntity? channel,
      File? avatarFile,
      List<int>? avatarBytes,
      String? encodedAvatar,
      String? encodedExtension,
      String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (channel != null) "channel_id": channel.id.toString()
    };

    final uploadString = Utils.getBase64UploadString(
        file: avatarFile,
        fileBytes: avatarBytes,
        base64EncodedFile: encodedAvatar,
        fileExtension: encodedExtension);
    if (uploadString != null) {
      body["avatar"] = uploadString;
    }

    final response = await _httpClient._execute(BasicRequest._new(
        "/webhooks/$webhookId/$token",
        method: "PATCH",
        auditLog: auditReason,
        body: body));

    return Future.error(response);
  }

  @override
  Future<Message?> executeWebhook(
      Snowflake webhookId,
      MessageBuilder builder,
      {String? token,
      bool? wait,
      String? avatarUrl,
      String? username,
      Snowflake? threadId}) async {

    final queryParams = {
      if (wait != null) "wait": wait,
      if (threadId != null) "thread_id": threadId
    };

    final body = {
      ...builder.build(_client),
      if (avatarUrl != null) "avatar_url": avatarUrl,
      if (username != null) "username": username,
    };

    _HttpResponse response;
    if (builder.files != null && builder.files!.isNotEmpty) {
      response = await _httpClient._execute(MultipartRequest._new(
          "/webhooks/$webhookId/$token",
          builder.files!.map((e) => e._asMultipartFile()).toList(),
          method: "POST",
          fields: body,
          queryParams: queryParams)
       );
    } else {
      response = await _httpClient._execute(BasicRequest._new(
          "/webhooks/$webhookId/$token",
          body: body,
          method: "POST",
          queryParams: queryParams));
    }

    if (response is HttpResponseSuccess) {
      if (wait == null) {
        return Message._deserialize(
            _client, response.jsonBody as RawApiMap);
      }

      return null;
    }

    return Future.error(response);
  }

  @override
  Future<Webhook> fetchWebhook(Snowflake id, {String token = ""}) async {
    final response =
        await _httpClient._execute(BasicRequest._new("/webhooks/$id/$token"));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as RawApiMap, _client);
    }

    return Future.error(response);
  }

  @override
  Future<Invite> fetchInvite(String code) async {
    final response =
        await _httpClient._execute(BasicRequest._new("/invites/$code"));

    if (response is HttpResponseSuccess) {
      return Invite._new(response.jsonBody as RawApiMap, _client);
    }

    return Future.error(response);
  }

  @override
  String stickerUrl(String stickerHash, String extension) =>
      "https://cdn.${Constants.cdnHost}/stickers/$stickerHash.$extension";

  @override
  String emojiUrl(Snowflake emojiId) =>
      "https://cdn.discordapp.com/emojis/$emojiId.png";

  @override
  Future<DMChannel> createDMChannel(Snowflake userId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/users/@me/channels",
        method: "POST",
        body: {"recipient_id": userId.toString()}));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return DMChannel._new(_client,
        (response as HttpResponseSuccess).jsonBody as RawApiMap);
  }

  @override
  Future<_HttpResponse> sendRawRequest(String url, String method,
      {dynamic body, dynamic headers}) => _httpClient
        ._execute(BasicRequest._new(url, method: method, body: body));

  Future<_HttpResponse> _getGatewayBot() =>
      _client._http._execute(BasicRequest._new("/gateway/bot"));

  Future<_HttpResponse> _getMeApplication() =>
      _client._http._execute(BasicRequest._new("/oauth2/applications/@me"));

  @override
  Future<GuildPreview> fetchGuildPreview(Snowflake guildId) async {
    final response = await _httpClient._execute(BasicRequest._new("/guilds/$guildId/preview"));

    if (response is HttpResponseSuccess) {
      return GuildPreview._new(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<IChannel> createGuildChannel(Snowflake guildId, ChannelBuilder channelBuilder) async {
    final response = await _httpClient._execute(
        BasicRequest._new("/guilds/${guildId.toString()}/channels", method: "POST", body: channelBuilder.build()));

    if (response is HttpResponseSuccess) {
      return IChannel._deserialize(_client, response.jsonBody as RawApiMap);
    }

    return Future.error(response);
  }

  @override
  Future<void> deleteChannel(Snowflake channelId) async {
    final response = await _httpClient._execute(BasicRequest._new("/channels/${channelId.toString()}", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<StageChannelInstance> createStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) async {
    final body = {
      "topic": topic,
      "channel_id": channelId.toString(),
      if (privacyLevel != null) "privacy_level": privacyLevel.value
    };

    final response = await _httpClient._execute(BasicRequest._new(
      "/stage-instances",
      method: "POST",
      body: body
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StageChannelInstance._new(_client, response._jsonBody as RawApiMap);
  }

  @override
  Future<void> deleteStageChannelInstance(Snowflake channelId) async {
    final response = await _httpClient._execute(BasicRequest._new("/stage-instances/${channelId.toString()}", method: "DELETE"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<StageChannelInstance> getStageChannelInstance(Snowflake channelId) async {
    final response = await _httpClient._execute(BasicRequest._new("/stage-instances/${channelId.toString()}"));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StageChannelInstance._new(_client, response._jsonBody as RawApiMap);
  }

  @override
  Future<StageChannelInstance> updateStageChannelInstance(Snowflake channelId, String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) async {
    final body = {
      "topic": topic,
      if (privacyLevel != null) "privacy_level": privacyLevel.value
    };

    final response = await _httpClient._execute(BasicRequest._new(
        "/stage-instances/${channelId.toString()}",
        method: "POST",
        body: body
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StageChannelInstance._new(_client, response._jsonBody as RawApiMap);
  }

  @override
  Future<void> addThreadMember(Snowflake channelId, Snowflake userId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/thread-members/$userId",
        method: "PUT"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<ThreadListResultWrapper> fetchActiveThreads(Snowflake channelId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/threads/active"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper._new(
      _client,
      (response as HttpResponseSuccess).jsonBody as RawApiMap
    );
  }

  @override
  Future<ThreadListResultWrapper> fetchJoinedPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await _httpClient._execute(BasicRequest._new(
      "/channels/$channelId/users/@me/threads/archived/private",
      queryParams: {
        if (before != null) "before": before.toIso8601String(),
        if (limit != null) "limit": limit
      }
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper._new(
        _client,
        (response as HttpResponseSuccess).jsonBody as RawApiMap
    );
  }

  @override
  Future<ThreadListResultWrapper> fetchPrivateArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/threads/archived/private",
        queryParams: {
          if (before != null) "before": before.toIso8601String(),
          if (limit != null) "limit": limit
        }
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper._new(
        _client,
        (response as HttpResponseSuccess).jsonBody as RawApiMap
    );
  }

  @override
  Future<ThreadListResultWrapper> fetchPublicArchivedThreads(Snowflake channelId, {DateTime? before, int? limit}) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/threads/archived/public",
        queryParams: {
          if (before != null) "before": before.toIso8601String(),
          if (limit != null) "limit": limit
        }
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return ThreadListResultWrapper._new(
        _client,
        (response as HttpResponseSuccess).jsonBody as RawApiMap
    );
  }

  @override
  Future<void> joinThread(Snowflake channelId) async {
    final response = await _httpClient._execute(BasicRequest._new(
      "/channels/$channelId/thread-members/@me",
      method: "PUT"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<void> leaveThread(Snowflake channelId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/thread-members/@me",
        method: "DELETE"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<void> removeThreadMember(Snowflake channelId, Snowflake userId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/channels/$channelId/thread-members/$userId",
        method: "DELETE"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<GuildSticker> createGuildSticker(Snowflake guildId, StickerBuilder builder) async {
    final response = await _httpClient._execute(MultipartRequest._new(
      "/guilds/$guildId/stickers",
      [builder._multipartFile],
      fields: builder.build(),
      method: "POST"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return GuildSticker._new(response._jsonBody as RawApiMap, _client);
  }

  @override
  Future<GuildSticker> editGuildSticker(Snowflake guildId, Snowflake stickerId, StickerBuilder builder) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/stickers/$stickerId",
        method: "PATCH"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return GuildSticker._new(response._jsonBody as RawApiMap, _client);
  }

  @override
  Future<void> deleteGuildSticker(Snowflake guildId, Snowflake stickerId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/stickers/$stickerId",
        method: "DELETE"
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<GuildSticker> fetchGuildSticker(Snowflake guildId, Snowflake stickerId) async {
    final response = await _httpClient._execute(BasicRequest._new(
        "/guilds/$guildId/stickers/$stickerId",
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return GuildSticker._new(response._jsonBody as RawApiMap, _client);
  }

  @override
  Stream<GuildSticker> fetchGuildStickers(Snowflake guildId) async* {
    final response = await _httpClient._execute(BasicRequest._new(
      "/guilds/$guildId/stickers",
    ));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawSticker in response._jsonBody) {
      yield GuildSticker._new(rawSticker as RawApiMap, _client);
    }
  }

  @override
  Future<StandardSticker> getSticker(Snowflake id) async {
    final response = await _httpClient._execute(BasicRequest._new(
      "/stickers/$id",
    ));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return StandardSticker._new(response._jsonBody as RawApiMap);
  }

  @override
  Stream<StickerPack> listNitroStickerPacks() async* {
    final response = await _httpClient._execute(BasicRequest._new(
      "/sticker-packs",
    ));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawSticker in response._jsonBody) {
      yield StickerPack._new(rawSticker as RawApiMap, _client);
    }
  }
}
