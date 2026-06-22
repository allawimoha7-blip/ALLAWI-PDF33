import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Visual mode for the PDF viewer page itself (independent of the app's
/// overall light/dark theme) — lets users read in a warm "night" tint
/// even while the rest of the app stays in light mode, and vice versa.
enum ReaderVisualMode { normal, night, sepia }

class ReaderSettingsNotifier extends StateNotifier<ReaderVisualMode> {
  ReaderSettingsNotifier() : super(ReaderVisualMode.normal) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefNightReadingMode);
    state = ReaderVisualMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ReaderVisualMode.normal,
    );
  }

  Future<void> setMode(ReaderVisualMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefNightReadingMode, mode.name);
  }
}

final readerVisualModeProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderVisualMode>((ref) => ReaderSettingsNotifier());

/// Whether the viewer chrome (app bar / bottom bar) is hidden for
/// distraction-free full-screen reading.
final isFullScreenProvider = StateProvider<bool>((ref) => false);

/// Current zoom level of the active viewer session.
final currentZoomProvider = StateProvider<double>((ref) => 1.0);
