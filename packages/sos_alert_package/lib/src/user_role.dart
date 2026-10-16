/// The two roles supported by the app.
///
/// - [user]: a person who can trigger SOS alerts.
/// - [monitor]: a guardian/family member who watches alerts raised by
///   the users linked to them (e.g. a parent, caregiver, or responder).
enum UserRole { user, monitor }

extension UserRoleX on UserRole {
  String get label => this == UserRole.user ? 'User' : 'Monitor';

  static UserRole fromString(String value) {
    return value == 'monitor' ? UserRole.monitor : UserRole.user;
  }

  String get storageValue => this == UserRole.user ? 'user' : 'monitor';
}
