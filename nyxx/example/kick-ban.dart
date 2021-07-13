import "package:nyxx/nyxx.dart";

// Returns user that can be banned from message. Parses mention or raw id from message
SnowflakeEntity getUserToBan(GuildMessage message) {
  // If mentions are not empty return first mention
  if(message.mentions.isNotEmpty) {
    return message.mentions.first.id.toSnowflakeEntity();
  }

  // Otherwise split message by spaces then take lst part and parse it to snowflake and return as Snowflake entity
  return SnowflakeEntity(message.content.split(" ").last.toSnowflake());
}

// Main function
void main() {
  // Create new bot instance. Replace string with your token
  final bot = Nyxx("<TOKEN>", GatewayIntents.allUnprivileged);

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.onReady.listen((ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.onMessageReceived.listen((MessageReceivedEvent e) async {
    // Check if message content equals "!embed"
    if (e.message.content == "!ban") {

      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message is! GuildMessage) {
        return;
      }

      // Get user to ban
      final userToBan = getUserToBan(e.message as GuildMessage);

      // Ban user using variable initialized before
      await (e.message as GuildMessage).guild.getFromCache()!.ban(userToBan);

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("👍"));
    }

    // Check if message content equals "!embed"
    if (e.message.content == "!ban") {
      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message is! GuildMessage) {
        return;
      }

      // Get user to kick
      final userToBan = getUserToBan(e.message as GuildMessage);

      // Kick user
      await (e.message as GuildMessage).guild.getFromCache()!.kick(userToBan);

      // Send feedback
      await e.message.channel.sendMessage(MessageBuilder.content("👍"));
    }
  });
}
