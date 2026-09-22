import 'package:flutter_test/flutter_test.dart';
import 'package:sketchit/l10n/app_localizations.dart';

void main() {
  test('every supported locale provides all strings', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(l10n.appTitle, isNotEmpty);
      expect(l10n.toolSelect, isNotEmpty);
      expect(l10n.menuExportPng, isNotEmpty);
      expect(l10n.dialogClearBody, isNotEmpty);
    }
  });

  test('supported locales cover the shipped arb files', () {
    final codes =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    for (final code in ['en', 'zh', 'es', 'fr', 'de', 'ja', 'pt', 'ru', 'ar', 'ko']) {
      expect(codes, contains(code));
    }
  });
}
