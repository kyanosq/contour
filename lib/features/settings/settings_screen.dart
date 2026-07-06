import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/measure_api.dart';
import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final session = context.watch<Session>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Sp.x6),
          children: [
            if (session.isDemo) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sp.x4, vertical: Sp.x3),
                decoration: BoxDecoration(
                  color: brassOf(context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Corners.control),
                ),
                child: Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 18, color: brassOf(context)),
                    const SizedBox(width: Sp.x2),
                    Text(
                      l.settingsDemoBadge,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: brassOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sp.x5),
            ],

            SectionLabel(l.settingsSectionGeneral.toUpperCase()),
            const SizedBox(height: Sp.x3),
            ContourCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x5, vertical: Sp.x2),
              child: Column(
                children: [
                  _PickerRow<String>(
                    icon: Icons.translate_rounded,
                    label: l.settingsLanguage,
                    value: session.locale?.languageCode ?? '',
                    options: {
                      '': l.settingsLanguageSystem,
                      'zh': '中文',
                      'en': 'English',
                    },
                    onChanged: session.setLocaleTag,
                  ),
                  Divider(color: scheme.outlineVariant),
                  _PickerRow<ThemeMode>(
                    icon: Icons.brightness_6_outlined,
                    label: l.settingsTheme,
                    value: session.themeMode,
                    options: {
                      ThemeMode.system: l.settingsThemeSystem,
                      ThemeMode.light: l.settingsThemeLight,
                      ThemeMode.dark: l.settingsThemeDark,
                    },
                    onChanged: session.setThemeMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.x6),

            SectionLabel(l.settingsSectionPrivacy.toUpperCase()),
            const SizedBox(height: Sp.x3),
            ContourCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x5, vertical: Sp.x2),
              child: Column(
                children: [
                  _NavRow(
                    icon: Icons.verified_user_outlined,
                    label: l.settingsPermissions,
                    onTap: () => context.push('/settings/permissions'),
                  ),
                  Divider(color: scheme.outlineVariant),
                  _NavRow(
                    icon: Icons.policy_outlined,
                    label: l.settingsPrivacyPolicy,
                    onTap: () => context.push('/settings/privacy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.x6),

            SectionLabel(l.settingsSectionAccount.toUpperCase()),
            const SizedBox(height: Sp.x3),
            ContourCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x5, vertical: Sp.x2),
              child: Column(
                children: [
                  _NavRow(
                    icon: Icons.logout_rounded,
                    label: l.settingsSignOut,
                    onTap: () => _signOut(context),
                  ),
                  Divider(color: scheme.outlineVariant),
                  _NavRow(
                    icon: Icons.person_off_outlined,
                    label: l.settingsCancelAccount,
                    destructive: true,
                    onTap: () => _cancelAccount(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.x6),

            Center(
              child: Text(
                '${l.settingsVersion}  ${session.appVersion}',
                style: TextStyle(
                  fontSize: 12,
                  fontFeatures: Numerals.features,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final session = context.read<Session>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.card)),
        title: Text(l.settingsSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
    if (ok == true) await session.signOut();
  }

  Future<void> _cancelAccount(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final session = context.read<Session>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.card)),
        title: Text(l.settingsCancelConfirm),
        content: Text(l.settingsCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Atelier.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.settingsCancelAccount),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await session.api.cancelAccount();
      await session.signOut();
    } on ApiFailure catch (e) {
      if (context.mounted) showToast(context, e.message, error: true);
    }
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? Atelier.danger : scheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sp.x4),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: destructive ? Atelier.danger : scheme.onSurfaceVariant),
            const SizedBox(width: Sp.x4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: color),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _PickerRow<T> extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.x3),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: Sp.x4),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final e in options.entries)
                  GestureDetector(
                    onTap: () => onChanged(e.key),
                    child: AnimatedContainer(
                      duration: Motion.standard,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sp.x3, vertical: 6),
                      decoration: BoxDecoration(
                        color: value == e.key
                            ? scheme.onSurface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: value == e.key
                              ? scheme.surface
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
