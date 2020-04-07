part of nyxx;

/// Emitted when user was updated
class UserUpdateEvent {
  /// User instance before update
  User? oldUser;

  /// User instance after update
  late final User newUser;

  UserUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.oldUser = client.users[Snowflake(json['d']['id'] as String)];
    newUser = User._new(json['d'] as Map<String, dynamic>, client);
  }
}
