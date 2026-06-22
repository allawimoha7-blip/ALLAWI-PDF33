import 'package:go_router/go_router.dart';
import '../../domain/entities/pdf_file_entity.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/viewer/pdf_viewer_screen.dart';

/// Centralized route table. Using go_router gives the app deep-linkable,
/// URL-based navigation on Web for free while keeping a single
/// declarative source of truth for all screens.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/viewer',
      name: 'viewer',
      builder: (context, state) {
        final file = state.extra as PdfFileEntity;
        return PdfViewerScreen(file: file);
      },
    ),
  ],
);
