import "dart:io";

import "package:nyxx/nyxx.dart";

// Main function
void main() {
  // Create new bot instance
  final bot = Nyxx("<TOKEN>", GatewayIntents.allUnprivileged);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((ReadyEvent e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessageReceived.listen((MessageReceivedEvent e) {
    // When receive specific message send new file to channel
    if (e.message.content == "!give-me-file") {
      // Files argument needs to be list of AttachmentBuilder object with
      // path to file that you want to send. You can also use other
      // AttachmentBuilder constructors to send File object or raw bytes
      e.message.channel.sendMessage(MessageBuilder()..files = [AttachmentBuilder.path("kitten.jpeg")]);
    }

    // Check if message content equals "!givemeembed"
    if (e.message.content == "!givemeembed") {
      // Files can be used within embeds as custom images
      final attachment = AttachmentBuilder.file(File("kitten.jpeg"));

      // use attachUrl getter from AttachmentBuilder class to get reference to uploaded file
      final embed = EmbedBuilder()
        ..title = "Example Title"
        ..thumbnailUrl = attachment.attachUrl;

      // Send everything we created before to channel where message was received.
      // e.message.channel.getFromCache()?.sendMessage(files: [attachment], embed: embed, content: "HEJKA!");
      e.message.channel.sendMessage(
          MessageBuilder.content("HEJKA!")
            ..embeds = [embed]
            ..files = [attachment]
      );
    }
  });
}
