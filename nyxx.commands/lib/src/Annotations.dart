part of nyxx.commands;

/// Defines command. Can be placed above method.
/// It defines command handler for specified command.
///
/// Code above creates new command group with name `cmd` and subcommand `check`.
/// Group also has default command handler if only `cmd` invoked
/// ```
/// @Command(name: "elo")
/// Future<void> elo(CommandContext ctx) async => await ctx.reply(content: "ELO");
/// ```
class Command {
  /// Name of command. Text which will trigger execution
  final String name;

  /// List of aliases for command.
  final List<String> aliases;

  /// When command is executed bot will indicate 'typing'. Used for long running commands.
  final bool typing;

  const Command(this.name, {this.typing = false, this.aliases = const []});
}

/// Defines additional properties which will restrict user access to command
/// All fields are optional and wont affect command execution of not set.
class Restrict {
  /// Checks if user is in admins list provided at creating CommandsFramework
  final bool admin;

  /// List of roles required to execute command
  final List<Snowflake> roles;

  /// List of required permissions to invoke command
  final List<int> userPermissions;

  /// List of required to bot to succeed.
  final List<int> botPermissions;

  /// Cooldown for command in seconds
  final int cooldown;

  /// Allows to restrict command to be used only on guild or only in DM or both
  final ContextType requiredContext;

  /// If command is nfsw it wont be invoked in no nsfw channels
  final bool nsfw;

  /// Command requires user invoking that command to be in voice channel
  final bool requireVoice;

  /// Topic of command. Can only execute this command if channel has specific topics indicated
  /// Adding to channel topic `[games, PC]` will allow to only execute commands annotated with this phrases
  final List<String> topics;

  const Restrict(
      {this.admin = false,
      this.roles = const [],
      this.cooldown = 0,
      this.userPermissions = const [],
      this.botPermissions = const [],
      this.requiredContext = ContextType.both,
      this.nsfw = false,
      this.requireVoice = false,
      this.topics = const []});
}

/// Captures all remaining command text into `List<String>` or `String`
class Remainder {
  const Remainder();
}

/// Type of context required for command
enum ContextType { guild, dm, both }
