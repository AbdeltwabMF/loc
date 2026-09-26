# Loc

Loc is a free and open-source location reminder for Android. 
Set your destination. Loc alerts you as you get nearby.

## Features

- Multiple independently enabled reminders
- Background tracking while reminders are active
- Notification, vibration, or repeating alarm for each reminder
- Arrival radius from 20 m to 50 km
- High-speed crossing detection between GPS updates
- Built-in and external map selection, shared locations, and manual coordinates
- Pinned reminders for quick access
- Light, dark, and system themes

## Download

Get the latest APK from [GitHub Releases](https://github.com/AbdeltwabMF/loc/releases).
The `universal` APK works on all supported Android devices. Architecture-specific APKs are also available if you prefer a smaller
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

## License

Loc is licensed under the [GNU General Public License v3.0](LICENSE).
