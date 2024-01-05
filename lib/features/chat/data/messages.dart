class ChatMessage {
  final String senderName;
  final String senderImageUrl;
  final String text;
  final String sender;
  final DateTime sentTime;
  final bool isCurrentUser;
  final int messageId;

  // New property to determine if the message is from the current user

  ChatMessage({
    required this.senderName,
    required this.senderImageUrl,
    required this.messageId,
    required this.text,
    required this.sender,
    required this.sentTime,
    required this.isCurrentUser,
  });
}
