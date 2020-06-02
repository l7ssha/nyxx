part of nyxx;

/// [CachelessTextChannel] represents single text channel on [Guild].
/// Inhertits from [MessageChannel] and mixes [CacheGuildChannel].
class CachelessTextChannel extends CachelessGuildChannel with MessageChannel, ISend implements Mentionable, ITextChannel {
  /// The channel's topic.
  late final String? topic;

  @override

  /// The channel's mention string.
  String get mention => "<#${this.id}>";

  /// Channel's slowmode rate limit in seconds. This must be between 0 and 120.
  late final int slowModeThreshold;

  /// Returns url to this channel.
  String get url => "https://discordapp.com/channels/${this.guildId.toString()}"
      "/${this.id.toString()}";

  CachelessTextChannel._new(Map<String, dynamic> raw, Snowflake guildId, Nyxx client) : super._new(raw, 0, guildId, client) {
    this.topic = raw["topic"] as String?;
    this.slowModeThreshold = raw["rate_limit_per_user"] as int? ?? 0;
  }

  /// Edits the channel.
  Future<CachelessTextChannel> edit({String? name, String? topic, int? position, int? slowModeTreshold}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (topic != null) "topic": topic,
      if (position != null) "position": position,
      if (slowModeTreshold != null) "rate_limit_per_user": slowModeTreshold,
    };

    final response = await client._http._execute(BasicRequest._new("/channels/${this.id}", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return CachelessTextChannel._new(response.jsonBody as Map<String, dynamic>, guildId, client);
    }

    return Future.error(response);
  }

  /// Gets all of the webhooks for this channel.
  Stream<Webhook> getWebhooks() async* {
    final response = await client._http._execute(BasicRequest._new("/channels/$id/webhooks"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final o in (response as HttpResponseSuccess).jsonBody.values) {
      yield Webhook._new(o as Map<String, dynamic>, client);
    }
  }

  /// Creates a webhook for channel.
  /// Valid file types for [avatarFile] are jpeg, gif and png.
  ///
  /// ```
  /// var webhook = await channnel.createWebhook("!a Send nudes kek6407");
  /// ```
  Future<Webhook> createWebhook(String name, {File? avatarFile, String? auditReason}) async {
    if (name.isEmpty || name.length > 80) {
      return Future.error("Webhook's name cannot be shorter than 1 character and longer than 80 characters");
    }

    final body = <String, dynamic>{"name": name};

    if (avatarFile != null) {
      final extension = Utils.getFileExtension(avatarFile.path);
      final data = base64Encode(await avatarFile.readAsBytes());

      body["avatar"] = "data:image/$extension;base64,$data";
    }

    final response = await client._http
        ._execute(BasicRequest._new("/channels/$id/webhooks", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }

  /// Returns pinned [Message]s for [Channel].
  Stream<Message> getPinnedMessages() async* {
    final response = await client._http._execute(BasicRequest._new("/channels/$id/pins"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final val in (response as HttpResponseSuccess).jsonBody.values.first as Iterable<Map<String, dynamic>>) {
      yield Message._deserialize(val, client);
    }
  }

  @override

  /// Returns mention to channel
  String toString() => this.mention;
}