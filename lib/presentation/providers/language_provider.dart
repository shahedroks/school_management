import 'package:flutter/foundation.dart';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/core/l10n/app_translations.dart' as l10n;
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  LanguageProvider(this._prefs) {
    final code = _prefs.getString(AppConstants.languageKey) ?? 'en';
    _lang = l10n.AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => l10n.AppLanguage.en,
    );
  }

  final SharedPreferences _prefs;
  late l10n.AppLanguage _lang;

  l10n.AppLanguage get language => _lang;

  String t(String key) => l10n.t(_lang, key);

  Future<void> setLanguage(l10n.AppLanguage lang) async {
    _lang = lang;
    await _prefs.setString(AppConstants.languageKey, lang.code);
    notifyListeners();
  }
}
