import "dart:math";

import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/interactions.dart";

// Creates instance of slash command builder with name, description and sub options.
// Its used to synchronise commands with discord and also to be able to respond to them.
// SlashCommandBuilder allows to register handler for slash command that you will be able
// to respond to command event.
final singleCommand = SlashCommandBuilder("help", "This is example help command", [])
  ..registerHandler((event) async {
    // Handler accepts a function with parameter of SlashCommandInteraction which contains
    // all of the stuff need to respond to interaction.
    // From there you have two routes: ack and then respond later or respond immediately without ack.
    // Sending ack will display indicator that bot is thinking and from there you will have 15 mins to respond to
    // that interaction.
    await event.respond(MessageBuilder.content("Work in progress"));
  });

// If you want your command to have subcommand you don't need to register handler
// for main handler because only sub commands will be invokable.
// In list for options you can create new instances of sub commands with
// commands handlers that command could be responded by bot.
final subCommand = SlashCommandBuilder("game", "This is example game command", [
  subCommandFlipGame
]);

// Subcommand event handler receives same SlashCommandInteraction parameter with all
// info and tools need to respond to an interaction
final subCommandFlipGame = CommandOptionBuilder(CommandOptionType.subCommand, "coinflip", "Coin flip game")
  ..registerHandler((event) async {
    final result = Random().nextBool() ? "tail" : "heads";

    await event.respond(MessageBuilder.content("You flipped: $result"));
  });

void main() {
  final bot = Nyxx("<TOKEN>", GatewayIntents.allUnprivileged);
  Interactions(bot)
    ..registerSlashCommand(singleCommand) // Register created before slash command
    ..syncOnReady(); // This is needed if you want to sync commands on bot startup.
}
