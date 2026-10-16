# Emergency SOS Alert App (Flutter)

A colorful, multi-page Flutter starter for an emergency SOS app with
**two account types**: **User** (sends SOS alerts) and **Monitor**
(watches alerts from the people they protect). Built on a custom local
package plus several existing pub.dev packages.

## App flow

```
Splash (checks saved session)
  └─▶ Login (User / Monitor toggle)  ──▶ Register (User / Monitor toggle)
        │
        ├─▶ User shell (bottom nav)
        │     ├─ Home     — big SOS button, live-location alert, quick stats
        │     ├─ Contacts — manage emergency contacts
        │     ├─ History  — this user's past SOS alerts
        │     └─ Profile  — account info, logout
        │
        └─▶ Monitor shell (bottom nav)
              ├─ Dashboard — linked people, SAFE/ALERT status, stats
              ├─ Alerts    — full alert feed
              └─ Profile   — account info, logout
```

## Folder structure

```
emergency_sos_app/
├── lib/
│   ├── main.dart
│   ├── navigation/
│   │   ├── app_router.dart             # named routes, transitions, nav helpers
│   │   └── shell_back_handler.dart     # back-button behaviour for bottom-nav shells
│   ├── firebase_options.dart           # PLACEHOLDER — regenerate with `flutterfire configure`
│   ├── theme/app_theme.dart            # colors + gradients
│   ├── widgets/                        # gradient_scaffold, stat_card, role_toggle
│   └── screens/
│       ├── splash_screen.dart
│       ├── auth/login_screen.dart      # role toggle: User / Monitor
│       ├── auth/register_screen.dart
│       ├── user/                       # user_shell + home/contacts/history/profile
│       └── monitor/                    # monitor_shell + dashboard/alerts/profile
├── packages/
│   └── sos_alert_package/              # CUSTOM local package
│       └── lib/src/
│           ├── emergency_contact.dart
│           ├── location_service.dart   # geolocator wrapper
│           ├── contact_storage.dart    # shared_preferences persistence
│           ├── sos_dispatcher.dart     # builds + sends SOS via url_launcher
│           ├── user_role.dart          # User / Monitor enum
│           ├── account.dart            # login/register model
│           ├── auth_service.dart       # local auth (register/login/session)
│           ├── alert_log.dart          # alert history log
│           └── watched_user.dart       # Monitor's linked Users
├── android/app/AndroidManifest.xml     # permissions
└── pubspec.yaml
```

## Custom package: `sos_alert_package`

Everything reusable and backend-agnostic lives here so it can be
versioned or reused in another app later:

- `AuthService` — local register/login/logout/session, keyed by role
  (`User` vs `Monitor`), stored with `shared_preferences`.
- `ContactStorage` / `EmergencyContact` — a User's emergency contacts.
- `LocationService` — wraps `geolocator` for GPS + a Google Maps link.
- `SosDispatcher` — builds the alert message and opens `sms:`/`tel:`
  intents via `url_launcher`.
- `AlertLog` / `AlertEvent` — records each SOS trigger (status,
  timestamp) so it can show up in History (User) and the Alerts feed
  (Monitor).
- `WatchedUsersStore` / `WatchedUser` — the list of Users a Monitor has
  linked to and is watching.

## Existing pub.dev packages used

| Package | Purpose |
|---|---|
| `geolocator` | GPS location |
| `permission_handler` | Runtime permission requests |
| `url_launcher` | Launch SMS/call intents |
| `shared_preferences` | Local persistence (accounts, contacts, alerts) |
| `vibration` | Haptic feedback on SOS trigger |
| `flutter_local_notifications` | Local alert notifications |

## Setup

```bash
cd emergency_sos_app
flutter pub get
flutter run
```

If this folder doesn't already have `android/` and `ios/` platform
shells, run `flutter create .` inside it first, then keep the provided
`lib/`, `packages/`, and `pubspec.yaml`.

## Important limitation — read before demoing "monitoring"

This starter has **no backend**. `AuthService`, `AlertLog`, and
`WatchedUsersStore` all use on-device `shared_preferences`, which means:

- A **User** account and a **Monitor** account only "see" each other's
  alerts if they're tested **on the same device/emulator** (e.g. log in
  as a User, send an SOS, log out, log in as a Monitor with that User
  linked — you'll see it in the dashboard).
- For **real cross-device monitoring** (a parent's phone actually
  receiving alerts from their child's phone), swap `AuthService`,
  `AlertLog`, and `WatchedUsersStore` for a real backend — e.g.
  Firebase Auth + Cloud Firestore + Firebase Cloud Messaging for push
  notifications — while keeping the same method signatures, so the UI
  layer doesn't need to change.

## Other notes

- Update the emergency number in `user_home_screen.dart`
  (`_callEmergencyServices`) for your country (e.g. `911`, `112`, `100`).
- `url_launcher`'s `sms:` intent opens the native SMS composer
  pre-filled — the user still taps Send. For silent/automatic SMS
  sending you'd need an Android-only package like `telephony` instead,
  which has stricter store-review requirements.
- For iOS, add `NSLocationWhenInUseUsageDescription` to `Info.plist`.
- Passwords are stored in plain text locally for demo simplicity only —
  never do this in production; use a real auth provider with hashed
  credentials.

## Firebase setup (required)

This app uses **Firebase Authentication** (email/password) and **Cloud
Firestore** for accounts, contacts, the alert log, and monitor watch-lists.
`lib/firebase_options.dart` in this zip is a placeholder — the app will not
run until you replace it with your own project's config:

```bash
npm install -g firebase-tools      # if not already installed
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Pick/create your Firebase project, select Android (and iOS if needed), and
this generates the real `lib/firebase_options.dart` plus
`android/app/google-services.json` for you.

**If `flutterfire configure` adds a *second* `firebase_core:` line to
`pubspec.yaml`, delete the older one** — having two keys with the same name
is invalid YAML and will break `flutter pub get`.

Then in the Firebase console, enable:
- **Authentication → Sign-in method → Email/Password**
- **Firestore Database → Create database**

Firestore layout this app writes to:
```
users/{uid}                      — name, email, role
users/{uid}/contacts/{autoId}    — emergency contacts
alerts/{autoId}                  — all SOS events (triggeredBy, ownerUid, status, timestamp)
watchlists/{monitorEmail}/entries/{autoId} — people a Monitor watches
```

For quick testing, open **Firestore → Rules** and use:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
(Tighten this before shipping to production.)
