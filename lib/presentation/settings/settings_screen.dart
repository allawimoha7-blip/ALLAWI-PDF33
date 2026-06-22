import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/app_logo.dart';

/// App settings: appearance (theme), language, and about section.
/// Each setting persists immediately on change via its Riverpod
/// notifier — there is no separate "Save" step.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: s.t('appearance')),
          _SettingsTile(
            icon: LucideIcons.sun,
            title: s.t('lightMode'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
            ),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          _SettingsTile(
            icon: LucideIcons.moon,
            title: s.t('darkMode'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
            ),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
          _SettingsTile(
            icon: LucideIcons.smartphone,
            title: s.t('systemDefault'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
            ),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
          const Divider(height: 24),
          _SectionHeader(title: s.t('language')),
          _SettingsTile(
            icon: LucideIcons.languages,
            title: s.t('english'),
            trailing: Radio<String>(
              value: 'en',
              groupValue: locale?.languageCode,
              onChanged: (v) => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
            ),
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
          _SettingsTile(
            icon: LucideIcons.languages,
            title: s.t('arabic'),
            trailing: Radio<String>(
              value: 'ar',
              groupValue: locale?.languageCode,
              onChanged: (v) => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
            ),
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
          ),
          const Divider(height: 24),
          _SectionHeader(title: s.t('about')),
          const _AboutBlock(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.brand,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogoMark(size: 44, color: AppColors.brand),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.t('appName'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(s.t('tagline'), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              return Text(
                '${s.t('version')} $version',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
