/// Represents the online status of a user
enum UserStatus {
  /// User is offline (not connected)
  offline,
  
  /// User is online (connected and active)
  online,
  
  /// User is away (connected but inactive)
  away,
  
  /// User is busy (connected but has set status to busy)
  busy;
  
  /// Convert UserStatus to a string representation
  String toDisplayString() {
    switch (this) {
      case UserStatus.offline:
        return 'Offline';
      case UserStatus.online:
        return 'Online';
      case UserStatus.away:
        return 'Away';
      case UserStatus.busy:
        return 'Busy';
    }
  }
}