import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/user_entity.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/widgets/language_selector_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegisterBody();
  }
}

class _RegisterBody extends StatefulWidget {
  const _RegisterBody();

  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String _role = 'student';
  String _grade = '';
  String _subject = '';
  String? _error;
  bool _success = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final auth = context.read<AuthProvider>();
    final lang = context.read<LanguageProvider>();

    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _error = 'PINs do not match';
        _loading = false;
      });
      return;
    }
    if (_pinController.text.length != 4) {
      setState(() {
        _error = 'PIN must be exactly 4 digits';
        _loading = false;
      });
      return;
    }
    if (_role == 'student' && _grade.isEmpty) {
      setState(() {
        _error = 'Please select your grade';
        _loading = false;
      });
      return;
    }
    if (_role == 'teacher' && _subject.isEmpty) {
      setState(() {
        _error = 'Please enter your subject';
        _loading = false;
      });
      return;
    }

    final ok = await auth.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      pin: _pinController.text,
      role: _role,
      grade: _grade.isEmpty ? null : _grade,
      subject: _subject.isEmpty ? null : _subject,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = ok;
    });
    if (ok && _role == 'student') {
      context.go('/student/dashboard');
    } else if (ok && _role == 'teacher') {
      // Teacher pending - stay on success message
    } else if (!ok) {
      setState(() => _error = 'Phone number already registered');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_success && _role == 'teacher') {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(lang.t('auth.registrationSuccessful'), style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(lang.t('auth.teacherAccountPending'), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: Text(lang.t('auth.goToLogin')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(lang.t('auth.createAccount'), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(lang.t('auth.registerSubtitle'), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              const LanguageSelectorWidget(),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: lang.t('auth.fullName'), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: lang.t('auth.enterPhoneNumber'), border: const OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Text(lang.t('auth.iAmA'), style: Theme.of(context).textTheme.labelMedium),
              Row(
                children: [
                  Radio<String>(value: 'student', groupValue: _role, onChanged: (v) => setState(() => _role = v!)),
                  Text(lang.t('auth.student')),
                  Radio<String>(value: 'teacher', groupValue: _role, onChanged: (v) => setState(() => _role = v!)),
                  Text(lang.t('auth.teacher')),
                ],
              ),
              if (_role == 'student') ...[
                TextField(
                  onChanged: (v) => setState(() => _grade = v),
                  decoration: InputDecoration(labelText: lang.t('classes.grade'), hintText: lang.t('auth.gradeExample'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
              ],
              if (_role == 'teacher') ...[
                TextField(
                  onChanged: (v) => setState(() => _subject = v),
                  decoration: InputDecoration(labelText: lang.t('classes.subject'), hintText: lang.t('auth.subjectExample'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _pinController,
                decoration: InputDecoration(labelText: lang.t('auth.enterPin'), border: const OutlineInputBorder()),
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _confirmPinController,
                decoration: InputDecoration(labelText: lang.t('auth.confirmPin'), border: const OutlineInputBorder()),
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
              ),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(lang.t('auth.registerButton')),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(lang.t('auth.noAccount') + ' ' + lang.t('auth.login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
