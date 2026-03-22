# MedMinder

MedMinder is a Flutter application for medication reminders.

**Prerequisites**

- Install Flutter (stable channel) and ensure `flutter` is on your PATH: https://flutter.dev/docs/get-started/install
- Install platform tooling for targets you plan to run:
	- Android: Android Studio + Android SDK + an Android emulator or a device with USB debugging enabled.
	- iOS (macOS only): Xcode and command-line tools, a simulator or device.
	- Web: A modern browser (Chrome recommended).

**Setup**

1. Clone the repo and open the project root (this workspace).

```bash
git clone <repo-url>
cd MedMinder
```

2. Fetch Dart/Flutter packages:

```bash
flutter pub get
```

3. (Android only) If running on Android, ensure Android SDK licenses are accepted:

```bash
flutter doctor --android-licenses
```

4. Run `flutter doctor` and fix any reported issues before proceeding:

```bash
flutter doctor -v
```

**Run (development)**

- Run on the default connected device or emulator:

```bash
flutter run
```

- Run on a specific device (list devices first):

```bash
flutter devices
flutter run -d <device-id>
```

- Run for web (Chrome):

```bash
flutter run -d chrome
```

**Build (release)**

- Android APK:

```bash
flutter build apk --release
```

- iOS (macOS only):

```bash
flutter build ios --release
```

**Troubleshooting**

- If dependencies fail, delete `pubspec.lock` and run `flutter pub get` again.
- If an emulator/device isn't detected, run `flutter devices` and verify your platform tooling (Android Studio/Xcode) is installed and configured.
- For platform-specific issues, consult `flutter doctor -v` for hints.

**Helpful commands**

- `flutter clean` — remove build artifacts
- `flutter pub get` — fetch packages
- `flutter run --verbose` — verbose run output for debugging

If you'd like, I can also add platform-specific setup details (Android Studio SDK paths, signing configs) or update app metadata for distribution.
