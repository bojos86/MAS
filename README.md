MAS – AI Mobile Banking (Flutter Starter)
===============================================

Quick Start (Android via GitHub Actions):
1) Create a new Flutter repo (empty). Upload this ZIP content to the root.
2) Commit & push to 'main'. The workflow will:
   - `flutter create . --platforms=android`
   - `flutter pub get`
   - build the APK and upload as an artifact.
3) Download the APK from the workflow artifacts.

Local (optional):
- flutter create . --platforms=android
- flutter pub get
- dart run flutter_native_splash:create
- dart run flutter_launcher_icons:main
- flutter run (or) flutter build apk --release

Notes:
- OCR uses Google ML Kit (works on Android device builds).
- Camera requires runtime permissions.
- BIC/IBAN validators included; BIC dictionary is partial, pattern-based validation is enforced.
