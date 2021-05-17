part of nyxx;

/// ClientUser is bot's discord account. Allows to change bot's presence.
class ClientUser extends User {
  /// Weather or not the client user's account is verified.
  bool? verified;

  /// Weather or not the client user has MFA enabled.
  bool? mfa;

  ClientUser._new(Nyxx client, Map<String, dynamic> raw) : super._new(client, raw) {
    this.verified = raw["verified"] as bool;
    this.mfa = raw["mfa_enabled"] as bool;
  }

  /// Allows to get [Member] objects for all guilds for bot user.
  Map<Guild, Member> getMembership() {
    final membershipCollection = <Guild, Member>{};

    for (final guild in client.guilds.values) {
      final member = guild.members[this.id];

      if (member != null) {
        membershipCollection[guild] = member;
      }
    }

    return membershipCollection;
  }

  /// Edits current user. This changes user's username - not per guild nickname.
  Future<User> edit({String? username, File? avatarFile, List<int>? avatarBytes, String? encodedAvatar, String? encodedExtension}) =>
      client._httpEndpoints.editSelfUser(username: username, avatarFile: avatarFile, avatarBytes: avatarBytes, encodedAvatar: encodedAvatar, encodedExtension: encodedExtension);
}
