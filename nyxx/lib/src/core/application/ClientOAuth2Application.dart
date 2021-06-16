part of nyxx;

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application {
  /// The app's flags.
  late final int? flags;

  /// The app's owner.
  late final User owner;

  ClientOAuth2Application._new(RawApiMap raw, Nyxx client) : super._new(raw) {
    this.flags = raw["flags"] as int?;
    this.owner = User._new(client, raw["owner"] as RawApiMap);
  }

  /// Creates an OAuth2 URL with the specified permissions.
  String getInviteUrl([int permissions = 0]) =>
      "https://cdn.${Constants.cdnHost}/oauth2/authorize?client_id=$id&scope=bot&permissions=$permissions";
}
