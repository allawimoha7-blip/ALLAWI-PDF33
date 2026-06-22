import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';

/// First screen shown on cold start. Displays the ALLAWI PDF Reader
/// logo with a refined entrance animation, then routes to Home.
///
/// The visual design intentionally avoids a flat static image — the logo
/// scales/fades in, the wordmark follows, and the tagline settles last,
/// giving the launch a premium, considered feel rather than a placeholder.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = context.s;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.brand,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogoMark(size: 96)
                .animate()
                .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack, duration: 600.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              s.t('appName'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ).animate(delay: 250.ms).fadeIn(duration: 400.ms).moveY(begin: 12, end: 0),
            const SizedBox(height: 10),
            Text(
              s.t('tagline'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 48),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Colors.white.withOpacity(0.85),
              ),
            ).animate(delay: 600.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
