import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/l10n/app_translations.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.read<LanguageProvider>().t('auth.selectLanguage'), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: AppLanguage.values.map((l) {
            final isSelected = lang.language == l;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(l.code.toUpperCase()),
                selected: isSelected,
                onSelected: (_) => lang.setLanguage(l),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
