import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/settings_controller.dart';

/// Top-right hamburger menu: file io, view toggles, theme, language, about.
class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.settings,
    required this.gridEnabled,
    required this.onToggleGrid,
    required this.onOpen,
    required this.onSave,
    required this.onExportPng,
    required this.onClear,
  });

  final SettingsController settings;
  final bool gridEnabled;
  final VoidCallback onToggleGrid;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onExportPng;
  final VoidCallback onClear;

  /// Displayed in the language submenu in each locale's own name.
  static const localeNames = <String, String>{
    'en': 'English',
    'zh': '中文',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ja': '日本語',
    'pt': 'Português',
    'ru': 'Русский',
    'ar': 'العربية',
    'ko': '한국어',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = settings.themeMode;
    final currentLocale = settings.locale;

    return MenuAnchor(
      builder: (context, menu, _) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.folder_open_outlined),
          onPressed: onOpen,
          child: Text(l10n.menuOpen),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.save_outlined),
          onPressed: onSave,
          child: Text(l10n.menuSave),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.image_outlined),
          onPressed: onExportPng,
          child: Text(l10n.menuExportPng),
        ),
        const Divider(height: 8),
        MenuItemButton(
          leadingIcon: Icon(gridEnabled
              ? Icons.grid_on
              : Icons.grid_off_outlined),
          onPressed: onToggleGrid,
          child: Text(l10n.menuGrid),
        ),
        SubmenuButton(
          leadingIcon: const Icon(Icons.brightness_6_outlined),
          menuChildren: [
            for (final (mode, label) in [
              (ThemeMode.system, l10n.themeSystem),
              (ThemeMode.light, l10n.themeLight),
              (ThemeMode.dark, l10n.themeDark),
            ])
              MenuItemButton(
                leadingIcon: theme == mode
                    ? const Icon(Icons.check, size: 18)
                    : const SizedBox(width: 18),
                onPressed: () => settings.setThemeMode(mode),
                child: Text(label),
              ),
          ],
          child: Text(l10n.menuTheme),
        ),
        SubmenuButton(
          leadingIcon: const Icon(Icons.translate),
          menuChildren: [
            for (final entry in localeNames.entries)
              MenuItemButton(
                leadingIcon: currentLocale?.languageCode == entry.key
                    ? const Icon(Icons.check, size: 18)
                    : const SizedBox(width: 18),
                onPressed: () => settings.setLocale(Locale(entry.key)),
                child: Text(entry.value),
              ),
          ],
          child: Text(l10n.menuLanguage),
        ),
        const Divider(height: 8),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete_outline),
          onPressed: onClear,
          child: Text(l10n.menuClearCanvas),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.info_outline),
          onPressed: () => _showAbout(context, l10n),
          child: Text(l10n.menuAbout),
        ),
      ],
    );
  }

  void _showAbout(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aboutTitle),
        content: Text(l10n.aboutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogClose),
          ),
        ],
      ),
    );
  }
}
