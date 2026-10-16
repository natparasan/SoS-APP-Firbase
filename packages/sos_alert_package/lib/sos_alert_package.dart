/// A custom Flutter package that provides the core logic for an
/// Emergency SOS Alert application.
///
/// It bundles together:
///  - Location retrieval (via `geolocator`)
///  - Emergency contact storage (via `shared_preferences`)
///  - SOS message formatting
///  - Dispatching alerts (SMS / phone call) via `url_launcher`
library sos_alert_package;

export 'src/emergency_contact.dart';
export 'src/location_service.dart';
export 'src/contact_storage.dart';
export 'src/sos_dispatcher.dart';
export 'src/user_role.dart';
export 'src/account.dart';
export 'src/auth_service.dart';
export 'src/alert_log.dart';
export 'src/watched_user.dart';
