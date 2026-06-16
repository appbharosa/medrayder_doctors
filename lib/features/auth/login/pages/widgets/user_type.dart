
enum UserType { online, offline }

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.online:
        return 'Online Doctor';
      case UserType.offline:
        return 'Offline Doctor';
    }
  }

  String get apiValue {
    switch (this) {
      case UserType.online:
        return 'online';
      case UserType.offline:
        return 'offline';
    }
  }
}