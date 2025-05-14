/// Represents the type of a message
enum MessageType {
  /// Text message
  text,

  /// Image message
  image,

  /// Video message
  video,

  /// Audio message
  audio,

  /// File message
  file,

  /// Location message
  location,

  /// System message (join, leave, etc.)
  system;

  /// Convert MessageType to a string representation
  String toDisplayString() {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Audio';
      case MessageType.file:
        return 'File';
      case MessageType.location:
        return 'Location';
      case MessageType.system:
        return 'System';
    }
  }
}