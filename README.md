# Loc

Loc is an open-source Android arrival reminder. Pick a destination, choose an
arrival radius, and Loc sounds an alarm when the device enters that area.

The application uses OpenStreetMap tiles and Nominatim search. Reminders and
saved places stay on the device in Hive. There is no Loc account or analytics
backend.

## Features

- Multiple independently enabled arrival reminders
- Foreground-service tracking while reminders are active
- Per-reminder brief notifications, silent vibrations, or repeating alarms
- Configurable 100 m to 5 km arrival radius
- High-speed path-crossing detection between GPS samples
- Immediate arrival checks after editing or enabling a reminder
- Search, manual coordinates, and an interactive map picker
- Saved destinations with nearby-duplicate prevention
- Offline reminder editing and coordinate entry
- Gruvbox light/dark themes with system mode
- Persistent reminders and preferences

## Architecture

The codebase deliberately uses a small, feature-oriented architecture:

```text
lib/
├── app/                 # Application state and orchestration
├── data/
│   ├── models/          # Hive-compatible domain models
│   ├── services/        # Location and Nominatim boundaries
│   └── app_repository.dart
├── pages/               # Screens and route-specific UI
├── themes/              # Semantic Gruvbox Material theme
└── main.dart            # Composition root only
```

`AppController` owns the application lifecycle and coordinates narrow services.
Widgets do not open databases, create location streams, or call network APIs.
Writes are persisted immediately and keyed by reminder ID. Existing Hive
records remain readable, including reminders created before alert styles were
introduced, and legacy numeric keys are migrated when edited.

See [`docs/architecture.md`](docs/architecture.md) for behavior and design
decisions.

## Development setup

Android Studio does **not** bundle Flutter or a standalone Dart SDK. Dart is
included inside Flutter, which is why the IDE reports that Dart is not
downloaded when Flutter is missing.

1. Install the current stable Flutter SDK from
   [docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows).
2. Extract it to a user-writable path such as `C:\dev\flutter`. Do not place it
   under `Program Files`.
3. Add `C:\dev\flutter\bin` to the user `PATH`, then restart Android Studio and
   all terminals.
4. Install the **Flutter** plugin in Android Studio. It installs/enables the Dart
   IDE plugin; it does not install the SDK.
5. In Android Studio, set **Settings > Languages & Frameworks > Flutter > Flutter
   SDK path** to `C:\dev\flutter`. The Dart SDK should then resolve automatically
   to `C:\dev\flutter\bin\cache\dart-sdk`.
6. In **SDK Manager**, install Android SDK Platform 36, Android SDK Build-Tools,
   Android SDK Command-line Tools, and Android SDK Platform-Tools.
7. Accept licenses and validate the complete toolchain:

```powershell
flutter doctor -v
flutter doctor --android-licenses
flutter pub get
flutter analyze
flutter test
flutter run
```

Do not download Dart separately and do not manually create `android/local.properties`.
Flutter creates that local, ignored file when commands run with a valid SDK. The
repository does not vendor or pin a project-local Flutter SDK; local development
can use the latest stable release that satisfies `pubspec.yaml`. Distribution
builders such as F-Droid should pin a tested Flutter release for reproducibility.

## F-Droid

The listing metadata under `fastlane/metadata/android/en-US` follows F-Droid's
supported Fastlane structure. Changelog filenames match Android version codes.
Each release commit must be tagged with its version, for example `v1.0.0`.

Official F-Droid inclusion also requires a build recipe in the external
`fdroiddata` repository. The current `geolocator_android` dependency includes
Google Play Services Location even though Loc selects Android's framework
location manager at runtime. Replace that dependency with a fully free native
location implementation before requesting inclusion in F-Droid's main repo.

## OpenStreetMap usage

The app identifies itself to Nominatim, URL-encodes parameters, limits results,
debounces interactive search, and displays tile attribution. Nominatim is a
community service, not an unlimited production API. A high-volume release
should use a dedicated provider or self-hosted instance without changing the
UI/domain layers.

## Build

```powershell
flutter build apk --release
```

Release builds currently use debug signing. Configure a private release keystore
before publishing; never commit signing credentials.

## License

[GPL-3.0](LICENSE)
