import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/widgets/language_selector_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginBody();
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final auth = context.read<AuthProvider>();
    final lang = context.read<LanguageProvider>();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text;

    if (phone.isEmpty) {
      setState(() {
        _error = 'Please provide a phone number';
        _loading = false;
      });
      return;
    }

    final ok = await auth.login(phone, pin);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      final user = auth.user!;
      if (user.role.name == 'student') {
        context.go('/student/dashboard');
      } else {
        context.go('/teacher/dashboard');
      }
    } else {
      setState(() => _error = lang.t('auth.teacherAccountPending').contains('approval')
          ? 'Invalid credentials or account not approved yet.'
          : 'Invalid credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.school, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text('Nouadhibou High School', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(lang.t('auth.loginSubtitle'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              const LanguageSelectorWidget(),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: lang.t('auth.phoneNumber'),
                  hintText: 'XX XX XX XX',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: lang.t('auth.pin'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(lang.t('auth.loginButton')),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Text(lang.t('auth.noAccount') + ' ' + lang.t('auth.register')),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Demo Accounts', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _DemoRow(role: lang.t('auth.student'), phone: AppConstants.demoStudentPhone, pin: AppConstants.demoStudentPin),
                      _DemoRow(role: lang.t('auth.teacher'), phone: AppConstants.demoTeacherPhone, pin: AppConstants.demoTeacherPin),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoRow extends StatelessWidget {
  final String role;
  final String phone;
  final String pin;

  const _DemoRow({required this.role, required this.phone, required this.pin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(role, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text('Phone: $phone', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(width: 8),
          Text('PIN: $pin', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
