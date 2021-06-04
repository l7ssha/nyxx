part of nyxx;

/// Entity Utility is a Utility that lets you create Entities from outside of the nyxx project. Typically used in nyxx.* projects.
/// An example getting a user is below:
/// ```dart
/// void main() {
///     var bot = Nyxx("TOKEN");
///     Map<String, dynamic> rawJson = /* rawJson from the API */
///     User user = EntityUtility.createUser(bot, rawJson);
/// }
/// ```
class EntityUtility {
  /// Creates a User object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     User user = EntityUtility.createUser(bot, rawJson);
  /// }
  /// ```
  static User createUser(INyxx client, Map<String, dynamic> rawJson) =>
      User._new(client, rawJson);

  /// Creates a Guild object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     Guild guild = EntityUtility.createGuild(bot, rawJson);
  /// }
  /// ```
  static Guild createGuild(INyxx client, Map<String, dynamic> rawJson, [bool guildCreate = false]) =>
      Guild._new(client, rawJson, guildCreate);

  /// Creates a Role object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     Role role = EntityUtility.createRole(bot, Snowflake("81384788765712384"), rawJson);
  /// }
  /// ```
  static Role createRole(
          INyxx client, Snowflake guildId, Map<String, dynamic> rawJson) =>
      Role._new(client, rawJson, guildId);

  /// Creates a CategoryGuildChannel object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     CategoryGuildChannel category = EntityUtility.createCategoryGuildChannel(bot, Snowflake("81384788765712384"), rawJson);
  /// }
  /// ```
  static CategoryGuildChannel createCategoryGuildChannel(
          INyxx client, Snowflake guildId, Map<String, dynamic> rawJson) =>
      CategoryGuildChannel._new(client, rawJson, guildId);

  /// Creates a VoiceGuildChannel object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     VoiceGuildChannel voiceChannel = EntityUtility.createVoiceGuildChannel(bot, Snowflake("81384788765712384"), rawJson);
  /// }
  /// ```
  static VoiceGuildChannel createVoiceGuildChannel(
          INyxx client, Snowflake guildId, Map<String, dynamic> rawJson) =>
      VoiceGuildChannel._new(client, rawJson, guildId);

  /// Creates a Guild object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     TextGuildChannel textChannel = EntityUtility.createTextGuildChannel(bot, Snowflake("81384788765712384"), rawJson);
  /// }
  /// ```
  static TextGuildChannel createTextGuildChannel(
          INyxx client, Snowflake guildId, Map<String, dynamic> rawJson) =>
      TextGuildChannel._new(client, rawJson, guildId);

  /// Creates a Guild object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     DMChannel dmChannel = EntityUtility.createDMChannel(bot, rawJson);
  /// }
  /// ```
  static DMChannel createDMChannel(INyxx client, Map<String, dynamic> rawJson) =>
      DMChannel._new(client, rawJson);

  /// Creates a Guild Member object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     DMChannel dmChannel = EntityUtility.createGuildMember(bot, Snowflake(''), rawJson);
  /// }
  /// ```
  static Member createGuildMember(
          INyxx client, Snowflake guildId, Map<String, dynamic> rawJson) =>
      Member._new(client, rawJson, guildId);

  /// Creates a Guild Member object, can be used for other classes where you have correct rawJson data from the API.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Map<String, dynamic> rawJson = /* rawJson from the API */
  ///     DMChannel dmChannel = EntityUtility.createGuildMessage(bot, rawJson);
  /// }
  /// ```
  static Message createMessage(
      INyxx client, Map<String, dynamic> rawJson) =>
      Message._deserialize(client, rawJson);
}
