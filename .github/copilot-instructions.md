# Copilot / Agent Instructions for this Repository

Purpose
-------
This file helps AI assistants and contributors quickly understand how to work with this Flutter project and which commands, conventions, and files matter most.

Quick setup
-----------
- Install Flutter SDK compatible with `sdk: ^3.9.2` (see `pubspec.yaml`).
- From repository root run:

```
flutter pub get
flutter analyze
flutter test
```

Build & run
-----------
- Android: `flutter run -d android` (or use Android Studio/Gradle wrappers in `android/`).
- iOS/macOS: Xcode or `flutter run -d ios` / `flutter run -d macos` on macOS hosts.
- Web: `flutter run -d chrome`.
- Windows/Linux: `flutter run -d windows` / `flutter run -d linux`.

Tests
-----
- Unit/widget tests: `flutter test` (see `test/`).

Conventions & notable files
---------------------------
- Dart SDK: defined in `pubspec.yaml` as `^3.9.2`.
- App entry: `lib/main.dart`.
- Platform folders: `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`.
- CI: None detected. If adding CI, include `flutter pub get`, `flutter analyze`, and `flutter test` steps.

How an AI agent can help
------------------------
- Run quick repo scans for TODOs, lint issues, and failing tests.
- Suggest and add unit/widget tests for uncovered widgets in `lib/` and `test/`.
- Generate or update README sections with platform-specific run instructions.
- Create focused helpers (formatting, analysis options) and small refactors on request.

Scope and applyTo
-----------------
Keep these instructions general to the whole repo. For component-specific guidance (packages, plugins, or subfolders), add `applyTo` sections or separate instruction files under `.github/`.

Example prompts
---------------
- "Run `flutter test` and summarize failures." 
- "Add a widget test for `lib/main.dart` that verifies the home screen loads." 
- "List top 10 TODO/FIXME comments across `lib/` and `test/`."

If you edit this file
---------------------
Keep it concise. Preserve any existing contributor guidance that mentions environment setup or platform-specific steps.

Contact
-------
If you need clarification about project intent or conventions, open an issue or a PR describing the proposed change.
