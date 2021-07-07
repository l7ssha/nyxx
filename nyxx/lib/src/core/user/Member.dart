part of nyxx;

class Member extends SnowflakeEntity implements Mentionable {
  /// Reference to client
  final INyxx client;

  /// [Cacheable] for this [Guild] member
  late final Cacheable<Snowflake, User> user;

  /// The members nickname, null if not set.
  String? nickname;

  /// When the member joined the guild.
  late final DateTime joinedAt;

  /// Weather or not the member is deafened.
  late final bool deaf;

  /// Weather or not the member is muted.
  late final bool mute;

  /// Cacheable of guild where member is located
  late final Cacheable<Snowflake, Guild> guild;

  /// Roles of member
  late Iterable<Cacheable<Snowflake, Role>> roles;

  /// Highest role of member
  late final Cacheable<Snowflake, Role> hoistedRole;

  /// When the user starting boosting the guild
  late DateTime? boostingSince;

  /// Member's avatar in [Guild]
  late final String? avatarHash;

  /// Voice state of member. Null if not connected to channel or voice state not cached
  VoiceState? get voiceState => this.guild.getFromCache()?.voiceStates[this.id];

  /// The channel's mention string.
  @override
  String get mention => "<@${this.id}>";

  // TODO: is everything okay?
  /// Returns highest role of member.
  /// Uses ! on nullable properties and will throw if anything is missing from cache
  Role get highestRole =>
      this.roles.reduce((value, element) {
        final valueInstance = value.getFromCache();
        final elementInstance = element.getFromCache();

        if (valueInstance!.position > elementInstance!.position) {
          return value;
        }

        return element;
      }).getFromCache()!;

  Member._new(this.client, RawApiMap raw, Snowflake guildId) : super(Snowflake(raw["user"]["id"])) {
    this.nickname = raw["nick"] as String?;
    this.deaf = raw["deaf"] as bool;
    this.mute = raw["mute"] as bool;
    this.user = _UserCacheable(client, this.id);
    this.guild = _GuildCacheable(client, guildId);
    this.boostingSince = DateTime.tryParse(raw["premium_since"] as String? ?? "");
    this.avatarHash = raw["avatar"] as String?;

    this.roles = [
      for (var id in raw["roles"])
        _RoleCacheable(client, Snowflake(id), this.guild)
    ];

    if (raw["hoisted_role"] != null) {
      this.hoistedRole = _RoleCacheable(client, Snowflake(raw["hoisted_role"]), this.guild);
    }

    if (raw["joined_at"] != null) {
      this.joinedAt = DateTime.parse(raw["joined_at"] as String).toUtc();
    }

    if (!client.users.hasKey(this.id) && client._cacheOptions.userCachePolicyLocation.objectConstructor) {
      final userRaw = raw["user"] as RawApiMap;

      if (userRaw["id"] != null && userRaw.length != 1) {
        client.users.add(this.id, User._new(client, userRaw));
      }
    }
  }

  /// Returns total permissions of user.
  Future<Permissions> get effectivePermissions async {
    final guildInstance = await guild.getOrDownload();
    final owner = await guildInstance.owner.getOrDownload();
    if (this == owner) {
      return Permissions.all();
    }

    var total = guildInstance.everyoneRole.permissions.raw;
    for (final role in roles) {
      final roleInstance = await role.getOrDownload();

      total |= roleInstance.permissions.raw;

      if (PermissionsUtils.isApplied(total, PermissionsConstants.administrator)) {
        return Permissions.fromInt(PermissionsConstants.allPermissions);
      }
    }

    return Permissions.fromInt(total);
  }

  /// Returns url to member avatar
  String? avatarURL({String format = "webp", int size = 128}) {
    if(this.avatarHash == null) {
      return null;
    }

    return this.client.httpEndpoints.memberAvatarURL(this.id, this.guild.id, this.avatarHash!);
  }

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban({int? deleteMessageDays, String? reason, String? auditReason}) async =>
      client.httpEndpoints.guildBan(this.guild.id, this.id, auditReason: auditReason);

  /// Adds role to user.
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  Future<void> addRole(SnowflakeEntity role, {String? auditReason}) =>
      client.httpEndpoints.addRoleToUser(this.guild.id, role.id, this.id, auditReason: auditReason);

  /// Removes [role] from user.
  Future<void> removeRole(SnowflakeEntity role, {String? auditReason}) =>
      client.httpEndpoints.removeRoleFromUser(this.guild.id, role.id, this.id, auditReason: auditReason);

  /// Kicks the member from guild
  Future<void> kick({String? auditReason}) =>
      client.httpEndpoints.guildKick(this.guild.id, this.id);

  /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
  Future<void> edit({String? nick, List<SnowflakeEntity>? roles, bool? mute, bool? deaf, SnowflakeEntity? channel, String? auditReason}) =>
      client.httpEndpoints.editGuildMember(this.guild.id, this.id, nick: nick, roles: roles, mute: mute, deaf: deaf, channel: channel, auditReason: auditReason);

  void _updateMember(String? nickname, List<Snowflake> roles, DateTime? boostingSince) {
    if (this.nickname != nickname) {
      this.nickname = nickname;
    }

    if (this.roles != roles) {
      this.roles = roles.map((e) => _RoleCacheable(client, e, this.guild));
    }

    if (this.boostingSince == null && boostingSince != null) {
      this.boostingSince = boostingSince;
    }
  }
}
