import "package:nyxx/nyxx.dart";

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
    if (e.message.content == "!create_channel") {
      // Make sure that message was sent in guild not im dm, because we cant add roles in dms
      if(e.message is! GuildMessage) {
        return;
      }

      // Create default invite. We have to cast channel to access guild specific functionality.
      final invite = await (e.message.channel as TextGuildChannel).createInvite();

      // Send back invite url
      await e.message.channel.sendMessage(MessageBuilder.content(invite.url));
    }
  });
}
