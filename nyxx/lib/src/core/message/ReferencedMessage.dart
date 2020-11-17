part of nyxx;

/// Message wrapper that other message replies to.
/// [message] field can be null of two reasons: backend error or message was deleted.
/// In first case [isBackendFetchError] will be true and [isDeleted] in second case.
class ReferencedMessage {
  /// Message object of reply
  late final Message? message;

  /// If true the backend couldn't fetch the message
  late final bool isBackendFetchError;

  /// If true message was delted
  late final bool isDeleted;

  ReferencedMessage._new(Nyxx client, Map<String, dynamic> raw) {
    if (!raw.containsKey(raw["referencedMessage"])) {
      this.message = null;
      this.isBackendFetchError = true;
      this.isDeleted = false;
      return;
    }

    if (raw["referencedMessage"] == null) {
      this.message = null;
      this.isBackendFetchError = false;
      this.isDeleted = true;
      return;
    }

    this.message = Message._deserialize(client, raw);
    this.isBackendFetchError = false;
    this.isDeleted = false;
  }
}