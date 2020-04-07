import 'dart:io';

import 'package:nyxx/Vm.dart';
//TODO: NNBD - Rewrite examples to be more idiomatic

// Main function
void main() {
  // Create new bot instance
  Nyxx bot = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  // Listen to ready event. Invoked when bot started listening to events.
  bot.onReady.listen((e) {
    print("Ready!");
  });

  // Listen to all incoming messages via Dart Stream
  bot.onMessageReceived.listen((e) {
    if (e.message!.content == "!ping") {
      e.message!.channel.send(content: "Pong!");
    }
  });
}
