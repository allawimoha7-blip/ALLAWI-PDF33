# ALLAWI PDF Reader

**Read PDFs Faster, Smarter, Better.**

A clean, modern, Material 3 PDF reader built with Flutter — Android, iOS,
and Web from a single codebase, using a fully open-source PDF engine
([pdfrx](https://pub.dev/packages/pdfrx), built on PDFium) with no paid
licenses required.

---

## Status & honest scope

This is a real, working Flutter project with the core experience fully
wired up: splash screen, theming (light/dark), Arabic/English with RTL,
file picking, a SQLite-backed library (recents/favorites/all files),
and a full-featured PDF viewer (zoom/scroll, search, bookmarks,
thumbnails, night mode, full-screen, password-protected PDFs, share).

A few "premium" items from the original spec — **highlight text, draw
on PDF, add notes/annotations, extract text, convert pages to images,
print** — have their data model and repository (`AnnotationEntity`,
`AnnotationRepository`) already in place, but **not yet wired into the
viewer UI**. Print/share currently route through the OS share sheet
rather than a dedicated print pipeline. These are flagged with `TODO`
intent in the code structure (annotation toolbar, etc.) as the natural
next slice of work — see "Roadmap" below.

## Architecture

```
lib/
  core/          # theme, localization, routing, shared widgets/utils — no business logic
  domain/        # entities (PdfFileEntity, BookmarkEntity, AnnotationEntity) — pure Dart, no Flutter/IO imports
  data/          # repositories + datasources (SQLite, filesystem, web bytes store)
  presentation/  # screens, widgets, Riverpod providers — one folder per screen
```

- **State management:** Riverpod (`flutter_riverpod`, pinned to the 2.x
  line — see the comment in `pubspec.yaml` for why).
- **Routing:** `go_router`, one route table in `core/routing/app_router.dart`.
- **Persistence:** SQLite via `sqflite` (native) / `sqflite_common_ffi_web`
  (Web, IndexedDB-backed) — single schema in `data/datasources/app_database.dart`.
- **PDF rendering:** `pdfrx` — fully open-source, PDFium-based, no
  commercial license needed, works on Android/iOS/Web/desktop.

## Getting started

### Prerequisites
- Flutter SDK ≥ 3.3 (stable channel recommended)
- For Android: Android Studio + an SDK platform installed
- For iOS: Xcode (macOS only) + CocoaPods
- For Web: any modern browser; Chrome recommended for dev

### Install dependencies
```bash
flutter pub get
```

### Run on each platform
```bash
flutter run -d android      # or just `flutter run` with a device/emulator booted
flutter run -d ios          # macOS only
flutter run -d chrome       # Web
```

### Generate app icon & splash screen (optional, needs real PNGs first)
The project ships a vector logo (`assets/icons/app_logo.svg`) and a
`CustomPainter` version used live in the in-app splash screen, so the
app runs and looks correct with **zero image assets**. To also generate
native app icons / native splash (the OS-level flash before Flutter's
first frame), add `assets/images/app_icon.png` and
`assets/images/splash_logo.png` (see `assets/images/README.md` for
exact specs), then:
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Platform notes

### Android
- `minSdkVersion 23`, `targetSdkVersion 34`.
- Storage permission is requested via `permission_handler`; on Android
  13+ the OS file picker (Storage Access Framework) generally doesn't
  require it, but it's requested for the device-scan ("All Files")
  feature to work on older versions.
- Release builds use `signingConfigs.debug` as a placeholder — **add
  your own signing config in `android/app/build.gradle` before
  publishing**.

### iOS
- Document types are registered so the app can appear as an "Open in…"
  target for `.pdf` files from Mail/Files/Safari.
- No special entitlements are required for the current feature set.

### Web
- There is no filesystem on Web. Picked PDFs are persisted as bytes in
  IndexedDB (via `sqflite_common_ffi_web`, see
  `data/repositories/web_file_bytes_repository.dart`), so a picked file
  survives a page reload — but note IndexedDB persistence isn't
  guaranteed across all browsers/private-browsing modes, and it is
  **not** cross-tab safe (per `sqflite_common_ffi_web`'s own docs).
- The "All Files" device scan is a no-op on Web (no filesystem to scan);
  the tab still shows everything you've explicitly opened before.
- Share/Print are disabled on Web for now, since there's no real file
  path to hand to a native share sheet — only explicit, already-opened
  files have bytes, not a path.

## Roadmap (natural next steps, not yet built)
1. Annotation toolbar in the viewer (highlight / note / draw), backed
   by the already-built `AnnotationRepository`.
2. Text extraction + "convert page to image" export actions.
3. A dedicated print pipeline (e.g. the `printing` package) instead of
   routing through the share sheet.
4. Tablet-specific responsive layout (two-pane: file list + viewer).

## License notes
All dependencies in `pubspec.yaml` are open-source (BSD/MIT/ISC/Apache-2.0
family licenses). No paid SDK or commercial license is required to build
or ship this app.
