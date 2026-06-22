/// Global, static app constants.
/// Keeping these centralized avoids magic strings/numbers scattered
/// across the codebase and makes rebranding or tuning trivial.
class AppConstants {
  AppConstants._();

  static const String appName = 'ALLAWI PDF Reader';
  static const String appTagline = 'Read PDFs Faster, Smarter, Better.';

  // Local storage keys (SharedPreferences)
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLocale = 'pref_locale';
  static const String prefNightReadingMode = 'pref_night_reading_mode';
  static const String prefFirstLaunch = 'pref_first_launch';

  // Database
  static const String dbName = 'allawi_pdf_reader.db';
  static const int dbVersion = 1;

  static const String tableRecentFiles = 'recent_files';
  static const String tableFavorites = 'favorites';
  static const String tableBookmarks = 'bookmarks';
  static const String tableAnnotations = 'annotations';
  static const String tableReadingProgress = 'reading_progress';
  static const String tableWebFileBytes = 'web_file_bytes';

  // UI timings
  static const Duration splashDuration = Duration(milliseconds: 2200);
  static const Duration shortAnim = Duration(milliseconds: 180);
  static const Duration mediumAnim = Duration(milliseconds: 320);
  static const Duration longAnim = Duration(milliseconds: 520);

  // Limits
  static const int maxRecentFiles = 30;
  static const double minZoom = 1.0;
  static const double maxZoom = 5.0;
}
