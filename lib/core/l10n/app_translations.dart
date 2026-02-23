import 'package:high_school/core/l10n/translations_en.dart';
import 'package:high_school/core/l10n/translations_fr.dart';
import 'package:high_school/core/l10n/translations_ar.dart';

enum AppLanguage { en, fr, ar }

extension AppLanguageExt on AppLanguage {
  String get code => name;
  String get displayName {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.ar:
        return 'العربية';
    }
  }
}

final Map<AppLanguage, Map<String, dynamic>> _all = {
  AppLanguage.en: translationsEn,
  AppLanguage.fr: translationsFr,
  AppLanguage.ar: translationsAr,
};

String t(AppLanguage language, String key) {
  final keys = key.split('.');
  dynamic value = _all[language];
  for (final k in keys) {
    value = value is Map ? value[k] : null;
  }
  return value is String ? value : key;
}
