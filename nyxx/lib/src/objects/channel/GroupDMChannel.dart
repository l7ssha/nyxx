part of nyxx;

/// Represents group DM channel.
class GroupDMChannel extends MessageChannel {
  /// The recipients of channel.
  late Map<Snowflake, User> recipients;

  GroupDMChannel._new(Map<String, dynamic> raw, Nyxx client)
      : super._new(raw, 3, client) {
    this.recipients = Map<Snowflake, User>();
    raw['recipients'].forEach((dynamic o) {
      final User user = User._new(o as Map<String, dynamic>, client);
      this.recipients[user.id] = user;
    });
  }

  /// Removes recipient from channel
  Future<void> removeRecipient(User userId) {
    return client._http
        .send("DELETE", "/channels/${this.id}/recipients/${userId.toString()}");
  }
}
