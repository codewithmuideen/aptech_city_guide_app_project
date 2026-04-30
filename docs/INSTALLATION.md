# Installation Guide - City Guide

This guide walks through installing **every tool you need** to run the
City Guide Flutter app on a fresh Windows / macOS / Linux computer.

---

## 1. Prerequisites

| Tool                 | Minimum version | Purpose                                   |
|----------------------|-----------------|-------------------------------------------|
| Git                  | 2.30+           | Clone the project                         |
| Flutter SDK          | 3.10+           | Build & run the app                       |
| Dart                 | 3.0+            | Bundled with Flutter                      |
| Android Studio       | Latest          | Android build tools + emulator            |
| JDK                  | 17              | Required by Android Gradle Plugin         |
| VS Code (optional)   | Latest          | Lightweight editor with Flutter plugin    |
| Xcode (macOS only)   | 15+             | iOS build & simulator                     |

---

## 2. Install Flutter

### Windows
1. Download the zip from <https://docs.flutter.dev/get-started/install/windows>.
2. Extract to `C:\src\flutter` (avoid paths with spaces or admin-protected folders).
3. Add `C:\src\flutter\bin` to the **User PATH** environment variable.
4. Open a new *PowerShell* window and verify:
   ```powershell
   flutter --version
   flutter doctor
   ```
5. Resolve every red X reported by `flutter doctor` before proceeding.

### macOS
```bash
brew install --cask flutter
flutter doctor
```
Accept Xcode licenses when prompted:
```bash
sudo xcodebuild -license accept
```

### Linux
```bash
sudo snap install flutter --classic
flutter doctor
```

---

## 3. Install Android Studio
1. Download from <https://developer.android.com/studio>.
2. On first launch, install the latest **Android SDK**, **Platform-Tools**
   and **Emulator**.
3. In *Tools > SDK Manager > SDK Tools*, make sure **Android SDK Command-line
   Tools** is checked.
4. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```
5. Create a virtual device (*Tools > Device Manager > Create Device*). A
   Pixel 6 running API 34 is a good default.

### VS Code alternative
Install *Flutter* and *Dart* extensions from the VS Code marketplace; they
pick up the same Flutter SDK automatically.

---

## 4. Clone / copy the project

```bash
git clone <repo-url> city_guide_app       # or copy the folder manually
cd city_guide_app
```

---

## 5. Bootstrap platform folders

The repo ships source only (`lib/`, `assets/`, `docs/`, `pubspec.yaml`).
Create the Android / iOS / web scaffolding locally:

```bash
flutter create . --project-name city_guide_app --org com.eproject.cityguide
```

You'll now see `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`
folders next to `lib/`.

---

## 6. Install dependencies

```bash
flutter pub get
```

---

## 7. Run the app

### Android emulator
1. Start the emulator from *Android Studio > Device Manager*.
2. Run:
   ```bash
   flutter run
   ```

### iOS simulator (macOS only)
```bash
open -a Simulator
flutter run
```

### Physical Android device
1. Enable **Developer Mode** + **USB Debugging** on the phone.
2. Plug it in; accept the RSA prompt.
3. `flutter run`.

### Web (for quick evaluation)
```bash
flutter run -d chrome --web-port=8080
```
> **Important: always pass `--web-port=8080`** (or any other fixed port).
> Browser `localStorage` is keyed by origin (scheme + host + port). Flutter
> picks a *random* port by default, so running without `--web-port` gives
> you a brand-new storage bucket each time and previously created accounts,
> reviews and favorites will look like they vanished. Pin a port and all
> your data persists across launches.
>
> `shared_preferences` on web uses `localStorage`; all features work but
> image caching behaves differently.

---

## 8. Build release artefacts

### Android APK
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release
# then archive in Xcode
```

---

## 9. Demo accounts

| Role  | Email                  | Password   |
|-------|------------------------|------------|
| Admin | `admin@cityguide.com`  | `Admin@123`|
| User  | create via **Sign Up** | -          |

On first launch the app seeds 4 cities, 9 attractions and 1 admin user
into local storage. Subsequent launches read the persisted data.

To reset to a fresh seed, uninstall the app from the device/emulator
(which clears `SharedPreferences`) and relaunch.

---

## 10. Troubleshooting

| Symptom                                              | Fix                                                                |
|------------------------------------------------------|--------------------------------------------------------------------|
| `flutter doctor` complains about JDK                 | Install JDK 17 and set `JAVA_HOME`                                |
| Gradle download fails                                | Check proxy / retry: `flutter clean && flutter pub get`           |
| `Unable to locate Android SDK`                       | In Android Studio, install SDK and set path in *Preferences > Android SDK* |
| App shows blank screen after login                   | Ensure `flutter pub get` ran; check that images have internet     |
| Image caching errors in release                      | Add Internet permission (already in default AndroidManifest)      |
| Want to change admin credentials                     | Edit `lib/utils/constants.dart`                                   |
| Accounts/reviews **disappear** on next Chrome run    | You launched on a random port. Use `flutter run -d chrome --web-port=8080` to keep the same localStorage bucket. |
| Want to wipe all local data and re-seed              | Open Chrome DevTools -> Application -> Local Storage -> right-click the origin -> *Clear*, then relaunch. |

---

## 11. Next steps
- Read the [User Guide](USER_GUIDE.md) for a feature-by-feature walk-through.
- Read the [Project Report](PROJECT_REPORT.md) for SRS, design and testing.
