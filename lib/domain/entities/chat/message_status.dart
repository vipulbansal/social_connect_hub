
/// Represents the status of a message
enum MessageStatus {
  /// Message is being sent
  sending,

  /// Message has been sent but not yet delivered
  sent,

  /// Message has been delivered to the recipient
  delivered,

  /// Message has been read by the recipient
  read,

  /// Message failed to send
  failed;

  /// Convert MessageStatus to a string representation
  String toDisplayString() {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }
}