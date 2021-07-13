import "package:nyxx/nyxx.dart";

DiscordColor getColorForUserFromMessage(Message message) {
  if (message is GuildMessage) {
    return message.member.highestRole.color;
  }

  return DiscordColor.black;
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
  bot.onMessageReceived.listen((MessageReceivedEvent e) {
    // Check if message content equals "!embed"
    if (e.message.content == "!embed") {

      // Create embed with author and footer section.
      final embed = EmbedBuilder()
        ..addField(name: "Example field title", content: "Example value")
        ..addField(builder: (field) {
          field.content = "Hi";
          field.name = "Example Field";
        })
        ..addAuthor((author) {
          author.name = e.message.author.username;
          author.iconUrl = e.message.author.avatarURL();
        })
        ..addFooter((footer) {
          footer.text = "Footer example, good";
        })
        ..color = getColorForUserFromMessage(e.message);

      // Sent an embed to channel where message received was sent
      e.message.channel.sendMessage(MessageBuilder.embed(embed));
    }
  });
}
