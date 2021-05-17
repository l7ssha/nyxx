import "dart:async" show Future, FutureOr, Stream;
import "package:nyxx/nyxx.dart" show IEmoji, TextChannel, Message, MessageBuilder, MessageReactionEvent, Nyxx, UnicodeEmoji;
import "../../emoji.dart" show filterEmojiDefinitions;
import "../utils.dart" show StreamUtils, StringUtils;

/// Handles data and constructing data
abstract class IPaginationHandler {
  /// Used to generate message based on given [page] number.
  FutureOr<MessageBuilder> generatePage(int page);

  /// Used to generate fist page of Paginated message.
  FutureOr<MessageBuilder> generateInitialPage();

  /// Return total number of pages
  int get dataLength;

  /// Emoji used to navigate to next page. Default: "▶"
  FutureOr<IEmoji> get nextEmoji async => (await filterEmojiDefinitions((emoji) => emoji.primaryName == "arrow_forward", cache: true)).toEmoji();

  /// Emoji used to navigate to previous page. Default: "◀"
  FutureOr<IEmoji> get backEmoji async => (await filterEmojiDefinitions((emoji) => emoji.primaryName == "arrow_backward", cache: true)).toEmoji();

  /// Emoji used to navigate to first page. Default: "⏮"
  FutureOr<IEmoji> get firstEmoji async => (await filterEmojiDefinitions((emoji) => emoji.primaryName == "track_previous", cache: true)).toEmoji();

  /// Emoji used to navigate to last page. Default: "⏭"
  FutureOr<IEmoji> get lastEmoji async => (await filterEmojiDefinitions((emoji) => emoji.primaryName == "track_next", cache: true)).toEmoji();
}

/// Basic pagination handler based on [String]. Each entry in [pages] will be different page.
class BasicPaginationHandler extends IPaginationHandler {
  /// Pages of paginated message
  List<String> pages;

  /// Generates new pagination from List of Strings. Each list element is single page.
  BasicPaginationHandler(this.pages);

  /// Generates pagination from String. It divides String into 250 char long pages.
  factory BasicPaginationHandler.fromString(String str, TextChannel channel) => BasicPaginationHandler(StringUtils.split(str, 250).toList());

  /// Generates pagination from String but with user specified size of single page.
  factory BasicPaginationHandler.fromStringLen(String str, int len, TextChannel channel) => BasicPaginationHandler(StringUtils.split(str, len).toList());

  /// Generates pagination from String but with user specified number of pages.
  factory BasicPaginationHandler.fromStringEq(String str, int pieces, TextChannel channel) => BasicPaginationHandler(StringUtils.splitEqually(str, pieces).toList());

  @override
  FutureOr<MessageBuilder> generatePage(int page) => MessageBuilder()..content = pages[page];

  @override
  FutureOr<MessageBuilder> generateInitialPage() =>
      generatePage(0) as MessageBuilder;

  @override
  int get dataLength => pages.length;
}

/// Handles pagination interactivity. Allows to create paginated messages from List<String>
/// Factory constructors allows to create message from String directly.
///
/// Pagination is sent by [paginate] method. And returns [Message] instance of sent message.
///
/// ```
/// var pagination = new Pagination(["This is simple paginated", "data. Use it if you", "want to partition text by yourself"], ctx,channel);
/// // It generated 2 equal (possibly) pages.
/// var paginatedMessage = new Pagination.fromStringEq("This is text for pagination", 2);
/// ```
class Pagination<T extends IPaginationHandler> {
  /// Channel where message will be sent
  TextChannel channel;

  /// [IPaginationHandler] which will handle generating messages.
  T paginationHandler;

  ///
  Pagination(this.channel, this.paginationHandler);

  /// Paginates a list of Strings - each String is a different page.
  Future<Message> paginate(Nyxx client, {Duration timeout = const Duration(minutes: 2)}) async {
    final nextEmoji = await paginationHandler.nextEmoji;
    final backEmoji = await paginationHandler.backEmoji;
    final firstEmoji = await paginationHandler.firstEmoji;
    final lastEmoji = await paginationHandler.lastEmoji;

    final msg = await channel.sendMessage(await paginationHandler.generateInitialPage());
    await msg.createReaction(firstEmoji);
    await msg.createReaction(backEmoji);
    await msg.createReaction(nextEmoji);
    await msg.createReaction(lastEmoji);

    await Future(() async {
      var currPage = 0;
      final group = StreamUtils.merge(
          [client.onMessageReactionAdded, client.onMessageReactionsRemoved as Stream<MessageReactionEvent>]);

      await for (final event in group) {
        final emoji = (event as dynamic).emoji as UnicodeEmoji;

        if (emoji == nextEmoji) {
          if (currPage <= paginationHandler.dataLength - 2) {
            ++currPage;
            await msg.edit(await paginationHandler.generatePage(currPage));
          }
        } else if (emoji == backEmoji) {
          if (currPage >= 1) {
            --currPage;
            await msg.edit(await paginationHandler.generatePage(currPage));
          }
        } else if (emoji == firstEmoji) {
          currPage = 0;
          await msg.edit(await paginationHandler.generatePage(currPage));
        } else if (emoji == lastEmoji) {
          currPage = paginationHandler.dataLength;
          await msg.edit(await paginationHandler.generatePage(currPage));
        }
      }
    }).timeout(timeout);

    return msg;
  }
}
