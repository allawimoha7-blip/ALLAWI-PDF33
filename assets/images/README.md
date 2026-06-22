# Image assets needed

This folder is intentionally light on binary assets, since they can't be
generated in this environment. Before building release icons/splash
screens, add:

- `app_icon.png` — 1024×1024, used by `flutter_launcher_icons` to generate
  every platform's app icon. The vector source is at
  `assets/icons/app_logo.svg` — export it to PNG at 1024×1024 with the
  `#2F6FED` brand blue background (see `core/theme/app_colors.dart`).
- `splash_logo.png` — used by `flutter_native_splash` for the *native*
  splash screen shown for the few frames before Flutter's first frame
  renders. Recommended: 600×600, transparent background, just the
  document/"A" mark (no backdrop square) so it centers cleanly on the
  solid `#0E1116` background configured in `pubspec.yaml`.

After adding both files, run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Until these PNGs exist, the corresponding `flutter_launcher_icons` /
`flutter_native_splash` blocks in `pubspec.yaml` are inert — the app
still runs and shows the in-Dart `SplashScreen` (see
`lib/presentation/splash/splash_screen.dart`), which draws the logo
with `core/widgets/app_logo.dart` (a `CustomPainter`, no image needed).
