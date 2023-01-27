# Loc

A location-based reminder for android and IOS.

## Development

### Tools required

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
- [Android studio](https://developer.android.com/studio). Follow these instruction to get it work on [windows](https://docs.flutter.dev/get-started/install/windows#android-setup).
- Visual Studio Code (Optional). You need to install [Flutter plugin](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

### Build

1. Clone the repository.

```shell
git clone https://github.com/AbdeltwabMF/Loc.git
cd Loc
```

2.  Generate the mobile specific files and download dependencies.

```shell
flutter create --platforms=ios,android .
flutter pub get
```

3. 

```shell
cd lib
```

Open `main.dart` and start from there and then click on the top-right play button to `RUN` the app.

## License

Licensed under the [GPL-v3+](LICENSE) License.
