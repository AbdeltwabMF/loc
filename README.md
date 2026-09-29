<div align="center">
    <img src="assets/icons/app_icon.png" width="200px" height="200px" />
</div>

<h1 align="center">
    Loc
</h1>

<h4 align="center">
    The location-based reminder for Android. Set a destination. Get notified as you get nearby.
</h4>

<div align="center">
    <a href="https://loc.abdeltwab.xyz">
        Website
    </a>
    &middot;
    <a href="https://github.com/AbdeltwabMF/loc/releases/latest">
        Download
    </a>
</div>

## Preview

<p align="center">
      <img src="assets/screenshots/map-picker.png" width="30%">
      &nbsp;
      <img src="assets/screenshots/reminder-editor.png" width="30%">
      &nbsp;
      <img src="assets/screenshots/reminders.png" width="30%">
</p>

## Features

- Multiple independently enabled reminders
- Background tracking while reminders are active
- Notification, vibration, or repeating alarm for each reminder
- Arrival radius from 20 m to 50 km
- High-speed crossing detection between GPS updates
- Built-in and external map selection, shared locations, and manual coordinates
- Pinned reminders for quick access

## Download

Get the latest APK from [GitHub Releases](https://github.com/AbdeltwabMF/loc/releases).
The `universal` APK works on all supported Android devices. Architecture-specific APKs are also available if you prefer a smaller
download and know which ABI your device uses.

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
