# Loc

Loc is a free and open-source arrival reminder for Android. Choose a destination,
set how close you want to be, and Loc alerts you when you get there.

## Features

- Multiple independently enabled reminders
- Background tracking while reminders are active
- Notification, vibration, or repeating alarm for each reminder
- Arrival radius from 100 m to 5 km
- High-speed crossing detection between GPS updates
- Place search, manual coordinates, and map selection
- Reusable saved places
- Light, dark, and system themes

## Privacy

Reminders, saved places, and preferences stay on your device. Loc has no
accounts, ads, or analytics.

While reminders are active, Loc uses your location in the background to check
whether you have reached a destination.

Place searches use Nominatim, and map tiles come from OpenStreetMap. These
services receive the request data and standard network information such as your
IP address.

See the full [Privacy Policy](https://loc.abdeltwab.xyz/privacy.html).

## Download

Get the latest APK from [GitHub Releases](https://github.com/AbdeltwabMF/loc/releases).
The `universal` APK works on all supported Android devices and is the recommended
download. Architecture-specific APKs are also available if you prefer a smaller
download and know which ABI your device uses.

The official signing certificate has this SHA-256 fingerprint:

```text
9e437ae632a5ea07688de12e0a0ea56eb6e5b4184585c86a27f5a4201ae4cc42
```

Older APKs were signed with a debug key and cannot be upgraded in place.
Uninstall the old version before installing a current release. This also removes
your saved reminders and settings.

## Development

Install [Flutter](https://docs.flutter.dev/get-started/install) and Android SDK
Platform 36, then run:

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build

Create a local APK with:

```powershell
flutter build apk --debug
```

See [`docs/architecture.md`](docs/architecture.md) for implementation details
and design decisions.

## License

Loc is licensed under the [GNU General Public License v3.0](LICENSE).
