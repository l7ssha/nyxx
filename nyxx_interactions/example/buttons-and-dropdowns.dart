import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/interactions.dart";

final singleCommand = SlashCommandBuilder("help", "This is example help command", [])
  ..registerHandler((event) async {
    // All "magic" happens via ComponentMessageBuilder class that extends MessageBuilder
    // from main nyxx package. This new builder allows to create message with components.
    final componentMessageBuilder = ComponentMessageBuilder();

    // There are two types of button - regular ones that can be responded to an interaction
    // and url button that only redirects to specified url.
    // Here we are focusing on regular button that we can respond to.
    // Label is what user will see on button, customId is id that we ca use later to
    // catch button event and respond to, and style is what kind of button we want create.
    //
    // Adding selects is as easy as adding buttons. Use MultiselectBuilder with custom id
    // and list of multiselect options.
    final componentRow = ComponentRowBuilder()
      ..addComponent(ButtonBuilder("This is button label", "thisisid", ComponentStyle.success))
      ..addComponent(ButtonBuilder("This is another button", "thisisid2", ComponentStyle.success))
      ..addComponent(MultiselectBuilder("customId", [
        MultiselectOptionBuilder("example option 1", "option1"),
        MultiselectOptionBuilder("example option 2", "option2"),
        MultiselectOptionBuilder("example option 3", "option3"),
      ]));

    // Then component row can be added to message builder and sent to user.
    componentMessageBuilder.addComponentRow(componentRow);
    await event.respond(componentMessageBuilder);
  });

// To handle button interaction you need need function that accepts
// ButtonInteractionEvent as parameter. Since button event is interaction like
// slash command it needs to acknowledged and/or responded.
// If you know that command handler would take more that 3 second to complete
// you would need to acknowledge and then respond later with proper result.
Future<void> buttonHandler(ButtonInteractionEvent event) async {
  await event.acknowledge(); // ack the interaction so we can send response later

  // Send followup to button click with id of button
  await event.sendFollowup(MessageBuilder.content(
      "Button presed with id: ${event.interaction.customId}")
  );
}

// Handling multiselect events is no different from handling button.
// Only thing that changes is type of function argument -- it now passes information
// about values selected with multiselect
Future<void> multiselectHandlerHandler(MultiselectInteractionEvent event) async {
  await event.acknowledge(); // ack the interaction so we can send response later

  // Send followup to button click with id of button
  await event.sendFollowup(MessageBuilder.content(
      "Options chosen with values: ${event.interaction.values}")
  );
}

void main() {
  final bot = Nyxx("<TOKEN>", GatewayIntents.allUnprivileged);
  Interactions(bot)
    ..registerSlashCommand(singleCommand) // Register created before slash command
    ..registerButtonHandler("thisisid", buttonHandler) // register handler for button with id: thisisid
    ..registerMultiselectHandler("customId", multiselectHandlerHandler) // register handler for multiselect with id: customId
    ..syncOnReady(); // This is needed if you want to sync commands on bot startup.
}
