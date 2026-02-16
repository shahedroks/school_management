import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/widgets/language_selector_widget.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lang.t('profile.myProfile'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        ListTile(
          leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')),
          title: Text(user.name),
          subtitle: Text(user.email),
        ),
        const SizedBox(height: 16),
        Text(lang.t('profile.languagePreference'), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        const LanguageSelectorWidget(),
      ],
    );
  }
}
